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
@property (nonatomic, strong) UISegmentedControl *filterSegment;//是否开启滤镜
@property (nonatomic, strong) CoreImageFilter *filter;//滤镜
@property (nonatomic, assign) NSInteger logType;//调试,0关闭,1精简,2.详细
@property (nonatomic, strong) GLRenderView *renderView;//用于承载渲染画面
@end

@implementation RenderVC

-(CoreImageFilter *)filter{
    if(!_filter){
        _filter = [[CoreImageFilter alloc] init];
    }
    return _filter;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self startTRTC];
}

-(void)startTRTC{
    
    //->初始配置在父类 参考TRTCBaseVC
    //显示画面
    _renderView  = [[GLRenderView alloc] initWithFrame:self.view.frame];
    //[self.view insertSubview:_renderView atIndex:0];
    
    //TRTC开启预览内置渲染
    [self.trtc startLocalPreview:YES view:self.view];
    [self.trtc startLocalAudio];
    
    //默认开启自定义渲染
    [self.trtc setLocalVideoRenderDelegate:self pixelFormat:TRTCVideoPixelFormat_NV12 bufferType:TRTCVideoBufferType_PixelBuffer];
    
    [self.trtc callExperimentalAPI:@"{\"api\":\"setCustomRenderMode\",\"params\" : {\"mode\":1}}"];
    
    //进房,并推流
    [self.trtc enterRoom:[self roomParam] appScene:TRTCAppSceneLIVE];
    
    //滤镜控制
    _filterSegment = [[UISegmentedControl alloc] initWithItems:@[@"原始",@"滤镜"]];
    _filterSegment.selectedSegmentIndex = 1;
    _filterSegment.tintColor = rgba(15, 168, 45, 1.0);
    [_filterSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:rgba(15, 168, 45, 1.0)} forState:UIControlStateNormal];
    _filterSegment.frame = CGRectMake( self.view.frame.size.width/2 - 75, self.view.frame.size.height - (isBangsDevice ?BOTTOM_LAYOUT_GUIDE:10) - 40, 150, 40);
    //[_filterSegment addTarget:self action:@selector(onClickFilter:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_filterSegment];
    
    //设置调试信息的边界
    [self.trtc setDebugViewMargin:USER_ID margin:UIEdgeInsetsMake(0.2, 0, 0.2 , 0.1)];
}


#pragma mark - 父类重写
-(void)onClickBack{
    //页面关闭 退房
    [self.trtc setLocalVideoRenderDelegate:nil pixelFormat:TRTCVideoPixelFormat_NV12 bufferType:TRTCVideoBufferType_PixelBuffer];
    [self.trtc stopLocalPreview];
    [self.trtc stopLocalAudio];
    [self.trtc exitRoom];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)onClickCamera{
    [self.trtc switchCamera];
}

-(void)onClickLog{
//    _logType ++ ;
//    _logType = (_logType > 2?0:_logType);
//    [self.trtc showDebugView: _logType];
    [self.trtc stopLocalPreview];
}

#pragma mark - TRTCVideoRenderDelegate
-(void)onRenderVideoFrame:(TRTCVideoFrame *)frame userId:(NSString *)userId streamType:(TRTCVideoStreamType)streamType{
    
    //将buffer 经滤镜处理后 传给SDK渲染 编码发送
    if (self.filterSegment.selectedSegmentIndex == 1) {
        CIImage *image = [self.filter filterPixelBuffer:frame];
        [self.filter.fContex render:image toCVPixelBuffer:frame.pixelBuffer];
    }
    [_renderView renderFrame:frame];
  
}


-(void)dealloc{
    
    [TRTCCloud destroySharedIntance];
}
@end
