//
//  pssGLRender.h
//  pinut
//
//  Created by admin on 2017/1/13.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "pssMvFrame.h"

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

extern NSString *vertexShader(void);
extern NSString *rgbFragmentShader(void);

@protocol KxMovieGLRenderer
- (BOOL) isValid;
- (NSString *) fragmentShader;
- (void) resolveUniforms: (GLuint) program;
- (void) setFrame: (KxVideoFrame *) frame;
- (BOOL) prepareRender;
@end

@interface KxMovieGLRenderer_RGB : NSObject<KxMovieGLRenderer> {
    
    GLint _uniformSampler;
    GLuint _texture;
}

@end

@interface KxMovieGLRenderer_YUV : NSObject<KxMovieGLRenderer> {
    
    GLint _uniformSamplers[3];
    GLuint _textures[3];
}

@end


