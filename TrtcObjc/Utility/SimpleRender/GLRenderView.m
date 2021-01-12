//
//  GLRenderView.m
//  TrtcObjc
//
//  Created by kaoji on 2020/8/12.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import "GLRenderView.h"
#import "AppDelegate.h"

@interface GLRenderView()

@end

@implementation GLRenderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup{
    self.backgroundColor = [UIColor clearColor];
    
    //配置 GLKView 用于显示画面
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _videoPreviewView = [[GLKView alloc] initWithFrame:self.bounds context:_eaglContext];
    _videoPreviewView.frame = self.bounds;
    [self addSubview:_videoPreviewView];
    [self sendSubviewToBack:_videoPreviewView];
    
    // 绑定 frame buffer 获取 buffer 的宽和高
    // CIContext在绘制GLKView时使用的边界以像素为单位（不是点）
    // 因此需要读取帧缓冲区的宽度和高度；
    [_videoPreviewView bindDrawable];
    _videoPreviewView.enableSetNeedsDisplay = YES;
    _videoPreviewViewBounds = CGRectZero;
    _videoPreviewViewBounds.size.width = _videoPreviewView.drawableWidth;
    _videoPreviewViewBounds.size.height = _videoPreviewView.drawableHeight;
    
    // 创建CIContext实例，这必须在videoPreviewView之后完成
    _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace : [NSNull null]} ];
    
}

-(void)layoutSubviews{
    [super layoutSubviews];

    [_videoPreviewView deleteDrawable];
    _videoPreviewView.frame = self.frame;
    [_videoPreviewView bindDrawable];
    _videoPreviewViewBounds = CGRectZero;
    _videoPreviewViewBounds.size.width = _videoPreviewView.drawableWidth;
    _videoPreviewViewBounds.size.height = _videoPreviewView.drawableHeight;
    [_videoPreviewView layoutIfNeeded];
}

-(void)renderFrame:(TRTCVideoFrame *)frame{
    
    CVImageBufferRef imageBuffer = frame.pixelBuffer;
    CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];
    CGRect sourceExtent = sourceImage.extent;
    
    
    CGFloat sourceAspect = sourceExtent.size.width / sourceExtent.size.height;
    CGFloat previewAspect = _videoPreviewViewBounds.size.width  / _videoPreviewViewBounds.size.height;
    
    //我们想保持屏幕大小的纵横比，所以我们剪辑视频图像
    CGRect drawRect = sourceExtent;
    if (sourceAspect > previewAspect)
    {
        // 使用视频图像的全高，并将宽度居中裁剪
        drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0;
        drawRect.size.width = drawRect.size.height * previewAspect;
    }
    else
    {
        //使用视频图像的全宽，并将高度居中裁剪
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0;
        drawRect.size.height = drawRect.size.width / previewAspect;
    }
    
    [_videoPreviewView bindDrawable];
    
    if (_eaglContext != [EAGLContext currentContext])
        [EAGLContext setCurrentContext:_eaglContext];
    
    // 将 eagl view 清除变为灰色
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 将混合模式设置为“源结束”，以便CI使用该模式
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    [_ciContext drawImage:sourceImage inRect:_videoPreviewViewBounds fromRect:drawRect];
        
    [_videoPreviewView display];
}

@end
