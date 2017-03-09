//
//  pssGLView.m
//  pinut
//
//  Created by admin on 17/1/7.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssGLView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

enum {
    ATTRIBUTE_VERTEX,
   	ATTRIBUTE_TEXCOORD,
};

#pragma mark - shaders

//编译渲染程序
static GLuint compileShader(GLenum type, NSString *shaderString)
{
    GLint status;
    const GLchar *sources = (GLchar *)shaderString.UTF8String;
    
    //创建一个代表shader 的OpenGL对象, 这时你必须告诉OpenGL，你想创建 fragment shader还是vertex shader
    GLuint shader = glCreateShader(type);
    if (shader == 0 || shader == GL_INVALID_ENUM) {
        NSLog(@"Failed to create shader %d", shader);
        return 0;
    }
    //让OpenGL获取到这个shader的源代码
    glShaderSource(shader, 1, &sources, NULL);
    //运行时编译shader代码
    glCompileShader(shader);
    
#ifdef DEBUG
    GLint logLength;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength>0) {
        //输出编译日志
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(shader, logLength, &logLength, log);
        free(log);
    }
#endif
    
    //查看编译是否成功
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status == GL_FALSE) {
        glDeleteShader(shader);
        NSLog(@"Failed to compile shader:\n");
        return 0;
    }
    
    return shader;
}

static BOOL validateProgram(GLuint prog)
{
    GLint status;
    
    glValidateProgram(prog);
    
#ifdef DEBUG
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == GL_FALSE) {
        NSLog( @"Failed to validate program %d", prog);
        return NO;
    }
    
    return YES;
}

static void mat4f_LoadOrtho(float left, float right, float bottom, float top, float near, float far, float* mout)
{
    float r_l = right - left;
    float t_b = top - bottom;
    float f_n = far - near;
    float tx = - (right + left) / (right - left);
    float ty = - (top + bottom) / (top - bottom);
    float tz = - (far + near) / (far - near);
    
    mout[0] = 2.0f / r_l;
    mout[1] = 0.0f;
    mout[2] = 0.0f;
    mout[3] = 0.0f;
    
    mout[4] = 0.0f;
    mout[5] = 2.0f / t_b;
    mout[6] = 0.0f;
    mout[7] = 0.0f;
    
    mout[8] = 0.0f;
    mout[9] = 0.0f;
    mout[10] = -2.0f / f_n;
    mout[11] = 0.0f;
    
    mout[12] = tx;
    mout[13] = ty;
    mout[14] = tz;
    mout[15] = 1.0f;
}

@interface pssGLView ()
{
    EAGLContext *   _glContext;
    GLuint          _framebuffer;
    GLuint          _renderbuffer;
    GLint           _backingWidth;
    GLint           _backingHeight;
    GLuint          _program;
    GLint           _uniformMatrix;
    GLfloat         _vertices[8];
    id<KxMovieGLRenderer> _render;
    
    float frameWidth;
    float frameHeight;
}
@end

@implementation pssGLView

-(instancetype)initWithFrame:(CGRect)frame format:(KxVideoFrameFormat)format
{
    if (self = [super initWithFrame:frame]) {
        if (format == KxVideoFrameFormatYUV) {
            _render = [[KxMovieGLRenderer_YUV alloc] init];
        }else{
            _render = [[KxMovieGLRenderer_RGB alloc] init];
        }
        
        //CAEAGLLayer是CALayer的一个子类，用来显示任意的OpenGL图形
        CAEAGLLayer *eagLayer = (CAEAGLLayer *)self.layer;
        eagLayer.opaque = YES;
        eagLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:@NO,
                                        kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
        //创建Opengl ES 2.0上下文
        _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:_glContext];
        
        //生成帧缓冲区, Frame Buffer Object(FBO)，被用于把数据渲染到纹理对像
        glGenFramebuffers(1, &_framebuffer);
        //绑定帧缓冲区对象
        glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);

        /*生成渲染的缓冲区， 一个渲染缓冲区，其实就是一个用来支持离屏渲染的缓冲区。通常是帧缓冲区的一部份，一般不具有纹理格式，
        常见的模版缓冲和深度缓冲就是这样一类对像，这里为我们的FBO指定一个渲染缓冲区。这样，当我们渲染的时候，我们便把这个渲染缓
        冲区作为帧缓冲区的一个缓存来使用*/
        glGenRenderbuffers(1, &_renderbuffer);
        //绑定渲染的缓冲区
        glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
        //分配渲染空间
        [_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
        //获取宽和高
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
        
        //把帧缓冲区和渲染缓冲区绑定
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
        
        //检测绑定状态是否成功
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (status != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"生成frame buff对象失败");
            self = nil;
            return nil;
        }

        if (![self loadShader]) {
            self = nil;
            return nil;
        }

        _vertices[0] = -1.0f;  // x0
        _vertices[1] = -1.0f;  // y0
        _vertices[2] =  1.0f;  // ..
        _vertices[3] = -1.0f;
        _vertices[4] = -1.0f;
        _vertices[5] =  1.0f;
        _vertices[6] =  1.0f;  // x3
        _vertices[7] =  1.0f;  // y3
        
        NSLog(@"OK setup GL");
    }
    return self;
}

-(void)dealloc
{
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    
    if (_renderbuffer) {
        glDeleteRenderbuffers(1, &_renderbuffer);
        _renderbuffer = 0;
    }
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    if ([EAGLContext currentContext] == _glContext) {
        [EAGLContext setCurrentContext:nil];
    }
    
    _glContext = nil;
}

-(void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
    [self updateVertices];
    if (_render.isValid) {
        [self render:nil];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    [_glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", status);
    }else{
        NSLog(@"OK setup GL framebuffer %d:%d", _backingWidth, _backingHeight);
    }
    
    [self updateVertices];
    [self render:nil];
}

+(Class)layerClass
{
    return [CAEAGLLayer class];
}

-(BOOL)loadShader
{
    //编译定点着色器
    GLuint vertShader = compileShader(GL_VERTEX_SHADER, vertexShader());
    if (vertShader == 0) {
        goto loadFail;
    }
    
    //编译片段着色器
    GLuint fragShader = compileShader(GL_FRAGMENT_SHADER, _render.fragmentShader);
    if (fragShader == 0) {
        goto loadFail;
    }
    
    //创建一个渲染程序
    _program = glCreateProgram();
    
    //连接 vertex 和 fragment shader成一个完整的program
    glAttachShader(_program, vertShader);
    glAttachShader(_program, fragShader);
    glBindAttribLocation(_program, ATTRIBUTE_VERTEX, "position");
    glBindAttribLocation(_program, ATTRIBUTE_TEXCOORD, "texcoord");
    glLinkProgram(_program);
    
    //检测是否成功
    GLint status;
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE) {
        NSLog(@"Failed to link program, %d", _program);
        goto loadFail;
    }

//    glUseProgram(_program);
    
    //获取指向 vertex shader传入变量的指针
//    _positionSlot = glGetAttribLocation(_program, "Position");
//    _colorSlot = glGetAttribLocation(_program, "SourceColor");
//    glEnableVertexAttribArray(_positionSlot);
//    glEnableVertexAttribArray(_colorSlot);
    
    BOOL result = validateProgram(_program);
    
    _uniformMatrix = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    [_render resolveUniforms:_program];
loadFail:
    if (vertShader) {
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDeleteShader(fragShader);
    }
    
    if (result) {
        NSLog(@"setup GL programm OK");
    }else{
        glDeleteProgram(_program);
        _program = 0;
    }
    
    return result;
}

-(void)render:(KxVideoFrame *)frame
{
    static const GLfloat texCoords[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };
    
    [EAGLContext setCurrentContext:_glContext];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glUseProgram(_program);
    
    if (frame) {
        [_render setFrame:frame];
    }
    
    if ([_render prepareRender]) {
        GLfloat modelViewProj[16];
        mat4f_LoadOrtho(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f, modelViewProj);
        glUniformMatrix4fv(_uniformMatrix, 1, GL_FALSE, modelViewProj);//更改一个矩阵或一个矩阵数组
        
        glVertexAttribPointer(ATTRIBUTE_VERTEX, 2, GL_FLOAT, 0, 0, _vertices);
        glEnableVertexAttribArray(ATTRIBUTE_VERTEX);
        glVertexAttribPointer(ATTRIBUTE_TEXCOORD, 2, GL_FLOAT, 0, 0, texCoords);
        glEnableVertexAttribArray(ATTRIBUTE_TEXCOORD);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    [_glContext presentRenderbuffer:GL_RENDERBUFFER];
}

-(void)setFrameWidth:(float)width height:(float)height
{
    frameWidth = width;
    frameHeight = height;
    [self updateVertices];
}

- (void)updateVertices
{
    const BOOL fit      = (self.contentMode == UIViewContentModeScaleAspectFit);
    const float width   = frameWidth;
    const float height  = frameHeight;
    const float dH      = (float)_backingHeight / height;
    const float dW      = (float)_backingWidth	  / width;
    const float dd      = fit ? MIN(dH, dW) : MAX(dH, dW);
    const float h       = (height * dd / (float)_backingHeight);
    const float w       = (width  * dd / (float)_backingWidth );
    
    _vertices[0] = - w;
    _vertices[1] = - h;
    _vertices[2] =   w;
    _vertices[3] = - h;
    _vertices[4] = - w;
    _vertices[5] =   h;
    _vertices[6] =   w;
    _vertices[7] =   h;
}

//-(void)testRender
//{
//    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
//    glClear(GL_COLOR_BUFFER_BIT);
//
//
//    //调用glViewport 设置UIView中用于渲染的部分
//    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
//
//    //为vertex shader的两个输入参数配置两个合适的值
//    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
//    glVertexAttribPointer(_colorSlot,   //声明这个属性的名称
//                          4,            //定义这个属性由多少个值组成
//                          GL_FLOAT,     //声明每一个值是什么类型
//                          GL_FALSE,
//                          sizeof(Vertex),//指 stride 的大小。这是一个种描述每个 vertex数据大小的方式
//                          (GLvoid*)(3*sizeof(float)));//这个数据结构的偏移量, 表示在这个结构中，从哪里开始获取我们的值
//
//    //每个vertex上调用我们的vertex shader，以及每个像素调用fragment shader，最终画出我们的矩形
//    glDrawElements(GL_TRIANGLES,    //声明用哪种特性来渲染图形, 有GL_LINE_STRIP 和 GL_TRIANGLE_FAN。然而GL_TRIANGLE是最常用
//                   sizeof(Indices)/sizeof(Indices[0]),//告诉渲染器有多少个图形要渲染
//                   GL_UNSIGNED_BYTE,    //指每个indices中的index类型
//                   0);  //它是一个指向index的指针
//
//    [_glContext presentRenderbuffer:GL_RENDERBUFFER];
//}
//
//-(void)setupVBOs
//{
//    GLuint vertexBuffer;
//    //创建一个Vertex Buffer对象, 传数据到OpenGL的话，最好的方式就是用Vertex Buffer对象
//    glGenBuffers(1, &vertexBuffer);
//    //告诉OpenGL我们的vertexBuffer 是指GL_ARRAY_BUFFER
//    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
//    //把数据传到OpenGL-land
//    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
//
//    GLuint indexBuffer;
//    glGenBuffers(1, &indexBuffer);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
//}
@end

