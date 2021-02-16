//
//  RenderVC.m
//  TrtcObjc
//
//  Created by kaoji on 2020/8/22.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import "ProcessVC.h"
#import "CustomProcessFilter.h"
#import "LUTFilter.h"
#import "GLRenderView.h"

@interface  ProcessVC()<TRTCVideoFrameDelegate>

@property (nonatomic, strong) UISegmentedControl *filterSegment;/// 自定义回调类型
@property (nonatomic, strong) CustomProcessFilter *textureFilter;/// 纹理处理
@property (nonatomic, strong) LUTFilter *lutFilter;/// LUT图滤镜
@property (nonatomic, strong) UIView *localView;///用于承载预览画面
@property (nonatomic,strong)  GLRenderView *renderView;//发生美颜故障 时可以自定义渲染画面 对比美颜前美颜后 排查SDK问题还是第三方问题

@end

@implementation ProcessVC

-(CustomProcessFilter *)textureFilter{
    if(!_textureFilter){
        _textureFilter = [[CustomProcessFilter alloc] init];
    }
    return _textureFilter;
}

-(LUTFilter *)lutFilter{
    if(!_lutFilter){
        _lutFilter = [[LUTFilter alloc] init];
    }
    return _lutFilter;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self startTRTC];
}

-(void)startTRTC{

    /// 显示画面
    _localView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view insertSubview:_localView atIndex:0];
    
    /// 启用SDK音视频采集
    [self.rtcManager startCapture:SDKCapture Preview:_localView];
    
    /// 进房,并推流
    [self.rtcManager enterRoomUsingDefautParam];

    /// 默认开启自定义渲染
    [self onClickFilter:self.filterSegment];
    
    
    ///可以初始化一个GLRenderView来排查问题
}

-(void)onClickFilter:(UISegmentedControl *)segment{
    
    if(segment.selectedSegmentIndex == 0){

        [self.rtcManager setLocalVideoProcessDelegete:self pixelFormat:TRTCVideoPixelFormat_Texture_2D bufferType:TRTCVideoBufferType_Texture];
    }

    else if (segment.selectedSegmentIndex == 1){

        [self.rtcManager setLocalVideoProcessDelegete:self pixelFormat:TRTCVideoPixelFormat_NV12 bufferType:TRTCVideoBufferType_PixelBuffer];
    }
    
    else if (segment.selectedSegmentIndex == 2){

        [self.rtcManager setLocalVideoProcessDelegete:self pixelFormat:TRTCVideoPixelFormat_32BGRA bufferType:TRTCVideoBufferType_PixelBuffer];
    }
    else if (segment.selectedSegmentIndex == 3){
        
        [self.rtcManager setLocalVideoProcessDelegete:self pixelFormat:TRTCVideoPixelFormat_I420 bufferType:TRTCVideoBufferType_PixelBuffer];
    }
}

- (uint32_t)onProcessVideoFrame:(TRTCVideoFrame * _Nonnull)srcFrame dstFrame:(TRTCVideoFrame * _Nonnull)dstFrame {
    
    if (srcFrame.pixelFormat == TRTCVideoPixelFormat_Texture_2D) {

        dstFrame.textureId = [self.textureFilter renderToTextureWithSize:CGSizeMake(srcFrame.width, srcFrame.height) sourceTexture:srcFrame.textureId];

    } else if (srcFrame.data) {
        
        memcpy((void *)dstFrame.data.bytes, srcFrame.data.bytes, srcFrame.data.length);
        
    } else if (srcFrame.pixelFormat == TRTCVideoPixelFormat_NV12 || srcFrame.pixelFormat == TRTCVideoPixelFormat_32BGRA) {

        //[_renderView renderFrame:srcFrame];//// 发生美颜故障时可以自定义渲染画面 对比美颜前美颜后 排查SDK问题还是第三方问题

        [self.lutFilter processTrtcFrame:srcFrame to:dstFrame];

    } else if (srcFrame.pixelFormat == TRTCVideoPixelFormat_I420) {
        dstFrame.pixelBuffer = srcFrame.pixelBuffer;
    }
    return 0;
}


#pragma mark - 父类重写
-(void)onClickBack{
   
    [self.rtcManager exitRoom];
    [self.rtcManager stopCapture];
    [RTCLocalManager destroySharedIntance];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSInteger selectedIndex = self.filterSegment.selectedSegmentIndex;
    if (selectedIndex == 1 || selectedIndex == 2) {
        [_lutFilter nextFilter];
    }
}

#pragma mark - Getter
- (UISegmentedControl *)filterSegment{
    
    if(!_filterSegment){
        
        _filterSegment = [[UISegmentedControl alloc] initWithItems:@[@"Texture",@"NV12",@"BGRA",@"I420"]];
        _filterSegment.selectedSegmentIndex = 1;
        _filterSegment.tintColor = rgba(15, 168, 45, 1.0);
        [_filterSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:rgba(15, 168, 45, 1.0)} forState:UIControlStateNormal];
        _filterSegment.frame = CGRectMake(self.view.frame.size.width/2 - 125, self.view.frame.size.height - (isBangsDevice ?BOTTOM_LAYOUT_GUIDE:10) - 40, 250, 40);
        [_filterSegment addTarget:self action:@selector(onClickFilter:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_filterSegment];
    }
    return _filterSegment;
}
@end
