//
//  RenderVC.m
//  TrtcObjc
//
//  Created by kaoji on 2020/8/22.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import "RenderVC.h"
#import "GLRenderView.h"
#import "CoreImageFilter.h"

@interface RenderVC ()<TRTCVideoRenderDelegate>
@property (nonatomic, strong) CoreImageFilter *filter;//滤镜
@property (nonatomic, strong) GLRenderView *renderView;//用于承载渲染画面
@end

@implementation RenderVC

-(void)viewDidLoad{
    [super viewDidLoad];
    [self startRenderDemo];
}

-(void)startRenderDemo{
    
    /// 自定义渲染画面 在onRenderVideoFrame处理
    _renderView  = [[GLRenderView alloc] initWithFrame:self.view.frame];
    [self.view insertSubview:_renderView atIndex:0];
    
    /// 启用SDK音视频采集
    [self.rtcManager startCapture:SDKCapture Preview:nil];
    
    /// 设置自定义渲染代理回调
    [self.rtcManager setLocalVideoRenderDelegate:self pixelFormat:TRTCVideoPixelFormat_NV12 bufferType:TRTCVideoBufferType_PixelBuffer];
    
    /// 设置渲染模式/美颜
    [self.rtcManager setExperimentConfig:@"setCustomRenderMode" params:@{@"mode":@1}];
    
    /// 进房,并推流
    [self.rtcManager enterRoomUsingDefautParam];
    
}


#pragma mark - 父类重写
-(void)onClickBack{
    
    [self.rtcManager exitRoom];
    [self.rtcManager stopCapture];
    [RTCLocalManager destroySharedIntance];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TRTCVideoRenderDelegate
-(void)onRenderVideoFrame:(TRTCVideoFrame *)frame userId:(NSString *)userId streamType:(TRTCVideoStreamType)streamType{
    
    /// 将buffer处理后写回SDK
    CIImage *image = [self.filter filterPixelBuffer:frame];
    [self.filter.fContex render:image toCVPixelBuffer:frame.pixelBuffer];
    
    /// 自定义渲染画面
    [_renderView renderFrame:frame];
}


-(void)dealloc{
    
    [RTCLocalManager destroySharedIntance];
}

#pragma mark - getter
-(CoreImageFilter *)filter{
    if(!_filter){
        _filter = [[CoreImageFilter alloc] init];
    }
    return _filter;
}

@end
