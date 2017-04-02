//
//  pssDocReaderViewController.m
//  pcKan
//
//  Created by admin on 17/3/24.
//  Copyright © 2017年 ybz. All rights reserved.
//

#import "pssDocReaderViewController.h"

@interface pssDocReaderViewController ()<UIDocumentInteractionControllerDelegate>
{
    NSURL *_url;
}
@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@end

@implementation pssDocReaderViewController
-(instancetype)initWithUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addHub:@"加载中" hide:NO];
    
    _documentController = [UIDocumentInteractionController interactionControllerWithURL:_url];
    [_documentController setDelegate:self];
    
    WeakSelf(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        //当前APP打开  需实现协议方法才可以完成预览功能
        [weakSelf.documentController presentPreviewAnimated:YES];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    //注意：此处要求的控制器，必须是它的页面view，已经显示在window之上了
    return self;
}

- (void)documentInteractionControllerWillBeginPreview:(UIDocumentInteractionController *)controller{
    WeakSelf(weakSelf);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf removeHub];
    });
}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller{
    [self backBtnPress];
}

@end
