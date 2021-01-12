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

@interface  ProcessVC()<TRTCVideoFrameDelegate>
@property (nonatomic, strong) UISegmentedControl *filterSegment;//是否开启滤镜
@property (nonatomic, strong) CustomProcessFilter *textureFilter;//滤镜
@property (nonatomic, strong) LUTFilter *lutFilter;
@property (nonatomic, assign) NSInteger logType;//调试,0关闭,1精简,2.详细
@property (nonatomic, strong) UIView *localRenderView;//用于承载渲染画面
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
    
    //->初始配置在父类 参考TRTCBaseVC

    //显示画面
    _localRenderView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view insertSubview:_localRenderView atIndex:0];
    
    //TRTC开启预览内置渲染
    [self.trtc startLocalPreview:YES view:_localRenderView];
    [self.trtc startLocalAudio];
    
    
    //进房,并推流
    [self.trtc enterRoom:[self roomParam] appScene:TRTCAppSceneLIVE];
    
    //滤镜控制
    _filterSegment = [[UISegmentedControl alloc] initWithItems:@[@"纹理",@"NV12",@"BGRA",@"I420"]];
    _filterSegment.selectedSegmentIndex = 1;
    _filterSegment.tintColor = rgba(15, 168, 45, 1.0);
    [_filterSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:rgba(15, 168, 45, 1.0)} forState:UIControlStateNormal];
    _filterSegment.frame = CGRectMake( self.view.frame.size.width/2 - 125, self.view.frame.size.height - (isBangsDevice ?BOTTOM_LAYOUT_GUIDE:10) - 40, 250, 40);
    [_filterSegment addTarget:self action:@selector(onClickFilter:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_filterSegment];
    
    //默认开启自定义渲染
    [self onClickFilter:self.filterSegment];
    
    //设置调试信息的边界
    [self.trtc setDebugViewMargin:USER_ID margin:UIEdgeInsetsMake(0.2, 0, 0.2 , 0.1)];
}

-(void)onClickFilter:(UISegmentedControl *)segment{
    
    if(segment.selectedSegmentIndex == 0){

        [self.trtc setLocalVideoProcessDelegete:self pixelFormat:TRTCVideoPixelFormat_Texture_2D bufferType:TRTCVideoBufferType_Texture];
    }

    else if (segment.selectedSegmentIndex == 1){

        [self.trtc setLocalVideoProcessDelegete:self pixelFormat:TRTCVideoPixelFormat_NV12 bufferType:TRTCVideoBufferType_PixelBuffer];
    }
    
    else if (segment.selectedSegmentIndex == 2){

        [self.trtc setLocalVideoProcessDelegete:self pixelFormat:TRTCVideoPixelFormat_32BGRA bufferType:TRTCVideoBufferType_PixelBuffer];
    }
    else if (segment.selectedSegmentIndex == 3){
        
        [self.trtc setLocalVideoProcessDelegete:self pixelFormat:TRTCVideoPixelFormat_I420 bufferType:TRTCVideoBufferType_PixelBuffer];
    }
}

- (uint32_t)onProcessVideoFrame:(TRTCVideoFrame * _Nonnull)srcFrame dstFrame:(TRTCVideoFrame * _Nonnull)dstFrame {
    if (srcFrame.pixelFormat == TRTCVideoPixelFormat_Texture_2D) {

        dstFrame.textureId = [self.textureFilter renderToTextureWithSize:CGSizeMake(srcFrame.width, srcFrame.height) sourceTexture:srcFrame.textureId];
        
    } else if (srcFrame.data) {
        memcpy((void *)dstFrame.data.bytes, srcFrame.data.bytes, srcFrame.data.length);
    } else if (srcFrame.pixelFormat == TRTCVideoPixelFormat_NV12 || srcFrame.pixelFormat == TRTCVideoPixelFormat_32BGRA) {
        
        [self.lutFilter processTrtcFrame:srcFrame to:dstFrame];
        
    } else if (srcFrame.pixelFormat == TRTCVideoPixelFormat_I420) {
        dstFrame.pixelBuffer = srcFrame.pixelBuffer;
    }
    return 0;
}


#pragma mark - 父类重写
-(void)onClickBack{
    //页面关闭 退房
    [self.trtc stopLocalPreview];
    [self.trtc stopLocalAudio];
    [self.trtc exitRoom];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)onClickCamera{
    [self.trtc switchCamera];
}

-(void)onClickLog{
    _logType ++ ;
    _logType = (_logType > 2?0:_logType);
    [self.trtc showDebugView: _logType];
}

-(void)dealloc{
    
    [TRTCCloud destroySharedIntance];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSInteger selectedIndex = self.filterSegment.selectedSegmentIndex;
    if (selectedIndex == 1 || selectedIndex == 2) {
        [_lutFilter nextFilter];
    }
    
}

@end
