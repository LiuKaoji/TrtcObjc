//
//  RTCLocalManager.m
//  TrtcObjc
//
//  Created by kaoji on 2021/1/6.
//  Copyright © 2021 issuser. All rights reserved.
//

#import "RTCLocalManager.h"
#import "GenerateTestUserSig.h"
#import "TXCAudioCustomRecorder.h"
#import "AVFCamera.h"
#import <GPUImage/GPUImage.h>
#import "GPUImagePixelBufferOutput.h"
#import "DotGPUImageBeautyFilter.h"
#import <AVFoundation/AVCaptureDevice.h>
#import "AVFDevice.h"


/// 采集参数定义
#define AudioSampleLen  64
#define AudioSampleRate 44100
#define AudioChannel    1

@interface RTCLocalManager ()<TXLiveAudioSessionDelegate, TXCAudioCustomRecorderDelegate, AVFCameraDataOutputDelegate>


@property (nonatomic, strong) GPUImageView *previewLayer;
@property (nonatomic, strong) TXCAudioCustomRecorder *audioRecorder;
@property (nonatomic, strong) GPUImagePixelBufferOutput *gpuOutput;

@property (nonatomic, strong) AVFCamera *avfCamera;
@property (nonatomic, strong) GPUImageVideoCamera *gpuCamera;
@property (nonatomic, strong) DotGPUImageBeautyFilter *beautyFilter;

@end

@implementation RTCLocalManager

///初始化
- (instancetype)init{
    self = [super init];
    if (self) {
        self.isFront = YES;
        self.trtc = [TRTCCloud sharedInstance];
        [self.trtc setGSensorMode:TRTCGSensorMode_Disable];
    }
    return self;
}

/// 进房默认参数
-(TRTCParams *)param{
    
    if(!_param){
        _param = [[TRTCParams alloc] init];
        _param.sdkAppId = _SDKAppID;
        _param.userId = USER_ID;
        _param.roomId = ROOM_ID;
        _param.userSig = [GenerateTestUserSig genTestUserSig:_param.userId];
        _param.privateMapKey = @"";
        _param.role = TRTCRoleAnchor;
    }
    return _param;
}

/// 视频编码参数
-(TRTCVideoEncParam *)encParam{
    
    if(_encParam){
        _encParam = [[TRTCVideoEncParam alloc] init];
        _encParam.videoResolution = TRTCVideoResolution_640_360;
        _encParam.videoFps = 18;
        _encParam.videoBitrate = 800;
        _encParam.resMode = TRTCVideoResolutionModePortrait;
    }
    return  _encParam;
}

/// 开启采集
-(id)startCapture:(RtcCaptureMode)mode Preview:(id)widget{
    
    self.captureMode = mode;
    
    id returnObj = nil;
    
    switch (mode) {
        case SDKCapture:
        
            [self startLocalPreview:YES view:(UIView *)widget];
            [self startLocalAudio];
            
            break;
            
        case AudioCapture:
            
            [self enableCustomAudioCapture:YES];
            
            [self startLocalPreview:YES view:(UIView *)widget];
            [self startCustomAudioCapture];
            
            break;
            
        case AVFVideoCapture:
            
            [self enableCustomVideoCapture:YES];
            
            [self startAVFCapture: (AVCaptureVideoPreviewLayer *)widget];
            [self startLocalAudio];
            returnObj = _avfCamera;
            break;
            
        case GPUVideoCapture:
            
            [self enableCustomVideoCapture:YES];
            
            [self startGPUCapture:(GPUImageView *)widget];
            [self startLocalAudio];
            returnObj = _beautyFilter;
            break;
            
        default:
            break;
    }
    
    return returnObj;
}

/// 关闭采集
-(void)stopCapture{
    
    switch (self.captureMode) {
        case SDKCapture:
        
            [self stopLocalPreview];
            [self stopLocalAudio];
            
            break;
            
        case AudioCapture:
            
            [self enableCustomAudioCapture: NO];
            
            [self stopLocalPreview];
            [self stopCustomAudioCapture];
            
            break;
            
        case AVFVideoCapture:

            [_avfCamera stopCapture];
            [self stopLocalAudio];
            
            break;
            
        case GPUVideoCapture:
            
            [self.gpuCamera stopCameraCapture];
            [self stopLocalAudio];
            
            break;
            
        default:
            break;
    }
    
}

/// 切换相机
- (void)switchCamera{
    
    self.isFront = !self.isFront;
    
    switch (self.captureMode) {
        case SDKCapture:
        
            [_trtc.getDeviceManager switchCamera: self.isFront];
            
            break;
            
        case AudioCapture:
            
            [_trtc.getDeviceManager switchCamera: self.isFront];
            
            break;
            
        case AVFVideoCapture:
     
            [_avfCamera rotateCamera];
            
            break;
            
        case GPUVideoCapture:
            
            [_gpuCamera rotateCamera];
            
            break;
            
        default:
            break;
    }
}



////////////////////////////////////////////////开启采集//////////////////////////////////////////////
/// 自定义音频采集
-(void)startCustomAudioCapture{
    
    /// MARK: 自定义音频采集必须接管AudioSession代理 否则采集没有回调
    [TXLiveBase setAudioSessionDelegate: self];
    AVAudioSession *session =  [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [session setActive:YES error:nil];
    
    //开启麦克风采集
    _audioRecorder = [TXCAudioCustomRecorder sharedInstance];
    _audioRecorder.delegate = self;
    [_audioRecorder startRecord:AudioSampleRate nChannels:AudioChannel nSampleLen:AudioSampleLen];
    
}

/// 自定义视频采集 AVCaptureSession
-(void)startAVFCapture:(AVCaptureVideoPreviewLayer *)layer{
    
    _avfCamera = [[AVFCamera alloc] initWithLayer:layer Preset:AVCaptureSessionPreset1280x720 Position:AVCaptureDevicePositionFront];
    _avfCamera.delegate = self;
    [_avfCamera startCapture];
}

/// GPUImage采集
-(void)startGPUCapture:(GPUImageView *)previewLayer{
    
    _previewLayer = previewLayer;
    
    /// 美颜滤镜
    _beautyFilter = [[DotGPUImageBeautyFilter alloc] init];
    
    /// 相机
    _gpuCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    _gpuCamera.frameRate = 15;
    _gpuCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _gpuCamera.horizontallyMirrorFrontFacingCamera = YES;
    _gpuCamera.horizontallyMirrorRearFacingCamera = NO;
    [_gpuCamera    startCameraCapture];
    
    /// 关系链
    _gpuOutput = [[GPUImagePixelBufferOutput alloc] initwithImageSize:CGSizeMake(720, 1280)];
    [_gpuCamera    addTarget:_beautyFilter];
    [_beautyFilter addTarget:_previewLayer];
    [_beautyFilter addTarget:_gpuOutput];

    /// 发送采集数据
    __weak typeof(self) weakSelf = self;
    _gpuOutput.pixelBufferCallback = ^(CVPixelBufferRef  _Nullable pixelBufferRef) {
        
        TRTCVideoFrame *frame = [[TRTCVideoFrame alloc] init];
        frame.pixelFormat = TRTCVideoPixelFormat_32BGRA;
        frame.bufferType  = TRTCVideoBufferType_PixelBuffer;
        frame.pixelBuffer = pixelBufferRef;
        frame.timestamp = 0;
        [weakSelf.trtc sendCustomVideoData:frame];
    };

}

////////////////////////////////////////////////关闭采集//////////////////////////////////////////////
/// 关闭自定义音频采集
-(void)stopCustomAudioCapture{
    
    [_audioRecorder stopRecord];
    
    AVAudioSession *session =  [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryAmbient error:nil];
    [session setActive:NO error:nil];
    
    [TXLiveBase setAudioSessionDelegate: nil];
    
}

/// 关闭自定义视频采集 AVCaptureSession
-(void)stopAVFCapture{
    
    [_avfCamera stopCapture];
    [_avfCamera setDelegate:nil];
    
}

/// 关闭GPUImage采集
-(void)stopGPUCapture{
    
    [self stopLocalAudio];
    
    [_gpuCamera stopCameraCapture];
    [[[GPUImageContext sharedImageProcessingContext] framebufferCache] purgeAllUnassignedFramebuffers];
    
    _beautyFilter = nil;
    _gpuOutput = nil;
    _gpuCamera = nil;
}

/// 使用默然参数进房
- (void)enterRoomUsingDefautParam{
    
    [_trtc enterRoom:self.param appScene:TRTCAppSceneLIVE];
}

/// 进入TRTC房间
- (void)enterRoom:(TRTCParams *)param appScene:(TRTCAppScene)scene{

    [_trtc enterRoom:param appScene:scene];
}

/// 退出房间
- (void)exitRoom{
    [_trtc exitRoom];
}
/// 开启本地预览
- (void)startLocalPreview:(BOOL)frontCamera view:(UIView *)view{
    
    [_trtc startLocalPreview:frontCamera view:view];
}

/// 音频自定义采集
- (void)startLocalAudio{

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

   [_trtc startLocalAudio];///8.0+使用 startLocalAudio(quality)

#pragma clang diagnostic pop
    
}

/// 停止SDK视频采集
- (void)stopLocalPreview{
    
    [_trtc stopLocalPreview];
}


///停止SDK音频采集
- (void)stopLocalAudio{
    
    [_trtc stopLocalAudio];
}

/// 视频自定义采集
- (void)enableCustomVideoCapture:(BOOL)enable{
    
    [_trtc enableCustomVideoCapture:enable];
}

/// 开启视频自定义采集
- (void)enableCustomAudioCapture:(BOOL)enable{

    [_trtc enableCustomAudioCapture:enable];
}

- (void)setVideoEncoderParam:(TRTCVideoEncParam *)param{
    
    _encParam = param;
    [_trtc setVideoEncoderParam:_encParam];
}

/// 本地画面渲染模式
- (void)setLocalViewFillMode:(TRTCVideoFillMode)mode{
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

  [_trtc setLocalViewFillMode:mode];/// 8.0用 setLocalViewRenderParams:streamType:params

#pragma clang diagnostic pop
    
}

/// 重力感应
- (void)setGSensorMode:(TRTCGSensorMode) mode{

  [_trtc setGSensorMode:mode];
    
}

/// 设置TRTC的状态回调
-(void)setRtcDelegate:(id<TRTCCloudDelegate>)delegate{
    
    [_trtc setDelegate:delegate];
}

/// 本地视频采集数据回调
- (void)setLocalVideoRenderDelegate:(id<TRTCVideoRenderDelegate>)delegate pixelFormat:(TRTCVideoPixelFormat)pixelFormat bufferType:(TRTCVideoBufferType)bufferType{

    [_trtc setLocalVideoRenderDelegate:delegate pixelFormat:pixelFormat bufferType:bufferType];
    
}

/// 第三方美颜数据回调
- (void)setLocalVideoProcessDelegete:(id<TRTCVideoFrameDelegate>)delegate pixelFormat:(TRTCVideoPixelFormat)pixelFormat bufferType:(TRTCVideoBufferType)bufferType{
    
    [_trtc setLocalVideoProcessDelegete:delegate pixelFormat:pixelFormat bufferType:bufferType];
}

/// 仪表盘
- (void)showDebugView:(NSInteger)showType{
    
    [_trtc showDebugView:showType];
}

/// 隐藏接口调用
- (void)setExperimentConfig:(NSString *)key params:(NSDictionary *)params{
    
    NSDictionary *json = @{
        @"api": key,
        @"params": params
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:NULL];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self.trtc callExperimentalAPI:jsonString];
}

/// 销毁TRTC
+ (void)destroySharedIntance{
    
    [TRTCCloud destroySharedIntance];
}

#pragma mark - TXLiveAudioSessionDelegate

- (BOOL)setActive:(BOOL)active error:(NSError **)outError{
    return NO;
}

- (BOOL)setActive:(BOOL)active withOptions:(AVAudioSessionSetActiveOptions)options error:(NSError **)outError{
    return NO;
}

- (BOOL)setMode:(NSString *)mode error:(NSError **)outError{
    return NO;
}

- (BOOL)setCategory:(NSString *)category error:(NSError **)outError{
    return NO;
}

- (BOOL)setCategory:(NSString *)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError **)outError{
    return NO;
}

- (BOOL)setCategory:(NSString *)category mode:(NSString *)mode options:(AVAudioSessionCategoryOptions)options error:(NSError **)outError{
    return NO;
}

- (BOOL)setPreferredIOBufferDuration:(NSTimeInterval)duration error:(NSError **)outError{
    return NO;
}

- (BOOL)setPreferredSampleRate:(double)sampleRate error:(NSError **)outError{
    return NO;
}

- (BOOL)setPreferredOutputNumberOfChannels:(NSInteger)count error:(NSError **)outError{
    return NO;
}

- (BOOL)overrideOutputAudioPort:(AVAudioSessionPortOverride)portOverride error:(NSError **)outError{
    return NO;
}

#pragma mark - TXCAudioCustomRecorderDelegate
- (void)onRecordPcm:(NSData *)pcmData {
    
    TRTCAudioFrame *frame = [[TRTCAudioFrame alloc] init];
    frame.data = pcmData;
    frame.sampleRate = AudioSampleRate;
    frame.timestamp = 0;
    frame.channels = AudioChannel;
    [self.trtc sendCustomAudioData:frame];
}

#pragma mark - AVFCameraDelegate
- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    
    TRTCVideoFrame *frame = [[TRTCVideoFrame alloc] init];
    frame.pixelFormat = TRTCVideoPixelFormat_NV12;
    frame.bufferType  = TRTCVideoBufferType_PixelBuffer;
    frame.pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    frame.timestamp = 0;
    [self.trtc sendCustomVideoData:frame];
}
@end
