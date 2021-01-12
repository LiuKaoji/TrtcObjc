//
//  CaptureVC.m
//  TrtcObjc
//
//  Created by kaoji on 2020/8/23.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import "CaptureVC.h"
#import <GPUImage/GPUImage.h>
#import "TXCAudioCustomRecorder.h"
#import "GPUImagePixelBufferOutput.h"
#import "GPUImageBeautifyFilter.h"


@interface CaptureVC ()<TXCAudioCustomRecorderDelegate,TXLiveAudioSessionDelegate>
@property (nonatomic, strong) UISegmentedControl *filterSegment;//是否开启滤镜
@property GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *previewLayer;
@property (atomic,    strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic, strong) GPUImagePixelBufferOutput *cameraOutput;
@property (nonatomic, strong) TXCAudioCustomRecorder *audioRecorder;
@end

@implementation CaptureVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        AVAudioSession *session =  [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        [session setActive:YES error:nil];
        
        [TXLiveBase setAudioSessionDelegate:self];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self prepareTRTC];
    [self setupVideoCapture];
    [self setupAudioCapture];
    
}


-(void)prepareTRTC{
   
    //进房
    [self.trtc enterRoom:[self roomParam] appScene:TRTCAppSceneAudioCall];
    
    //显示预览
    _previewLayer = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    _previewLayer.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view insertSubview:_previewLayer atIndex:0];

}

#pragma mark -初始化输入视频流
-(void)setupVideoCapture{
    
    //开启视频自定义采集
    [self.trtc enableCustomVideoCapture:YES];
    
    self.filter = [[GPUImageBeautifyFilter alloc] init];
    
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.frameRate = 15;
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.horizontallyMirrorRearFacingCamera = NO;
    //处理输出数据
    _cameraOutput = [[GPUImagePixelBufferOutput alloc] initWithVideoCamera:self.videoCamera withImageSize:CGSizeMake(720, 1280)];
    __weak typeof(self) weakSelf = self;
    _cameraOutput.pixelBufferCallback = ^(CVPixelBufferRef  _Nullable pixelBufferRef) {
        [weakSelf sendMyCustomVideoData:pixelBufferRef];
    };
    
    [self.videoCamera startCameraCapture];
    [self.videoCamera addTarget:self.filter];
    [self.filter addTarget:self.previewLayer];
    [self.filter addTarget:self.cameraOutput];
    
}

#pragma mark -初始化音频输入流
-(void)setupAudioCapture{
    //开启麦克风采集
    [self.trtc enableCustomAudioCapture:YES];
    
    //开启麦克风采集
    _audioRecorder = [TXCAudioCustomRecorder sharedInstance];
    _audioRecorder.delegate = self;
    [_audioRecorder startRecord:44100 nChannels:1 nSampleLen:64];
}

-(void)filterChange{

    [self.videoCamera removeAllTargets];
    
    if(self.filterSegment.selectedSegmentIndex == 0){
       
        [self.videoCamera addTarget:self.filter];
        [self.filter addTarget:self.previewLayer];
        [self.filter addTarget:self.cameraOutput];
        
    }else{
        [self.videoCamera  addTarget:self.previewLayer];
        [self.videoCamera addTarget:self.cameraOutput];
    }
}


/// 自定义视频
-(void)sendMyCustomVideoData:(CVPixelBufferRef)pixelBufferRef{
    
    TRTCVideoFrame *frame = [[TRTCVideoFrame alloc] init];
    frame.pixelFormat = TRTCVideoPixelFormat_32BGRA;
    frame.bufferType  = TRTCVideoBufferType_PixelBuffer;
    frame.pixelBuffer = pixelBufferRef;
    frame.timestamp = 0;
    [self.trtc sendCustomVideoData:frame];
    
}

/// 自定义音频
- (void)onRecordPcm:(NSData *)pcmData {
    
    TRTCAudioFrame *frame = [[TRTCAudioFrame alloc] init];
    frame.data = pcmData;
    frame.sampleRate = 44100;
    frame.timestamp = 0;
    frame.channels = 1;
    [self.trtc sendCustomAudioData:frame];
}


#pragma mark - 父类重写
-(void)onClickBack{
    //页面关闭 退房
//    AVAudioSession *session =  [AVAudioSession sharedInstance];
//    [session setCategory:AVAudioSessionCategoryAmbient error:nil];
//    [session setActive:NO error:nil];
    
    _cameraOutput = nil;
    [self.videoCamera removeAllTargets];
    [self.videoCamera stopCameraCapture];
    [self.audioRecorder stopRecord];
    
    [TXLiveBase setAudioSessionDelegate:nil];
    
    [self.trtc exitRoom];

    [self.navigationController popViewControllerAnimated:YES];
}
-(void)onClickCamera{
    [self.videoCamera rotateCamera];
}

#pragma mark - getter
-(UISegmentedControl *)filterSegment{
    if (!_filterSegment) {
        _filterSegment = [[UISegmentedControl alloc] initWithItems:@[@"美颜",@"关闭"]];
        _filterSegment.selectedSegmentIndex = 0;
        _filterSegment.tintColor = rgba(15, 168, 45, 1.0);
        [_filterSegment setTitleTextAttributes:@{NSForegroundColorAttributeName:rgba(15, 168, 45, 1.0)} forState:UIControlStateNormal];
        _filterSegment.frame = CGRectMake( self.view.frame.size.width/2 - 100, self.view.frame.size.height - (isBangsDevice ?BOTTOM_LAYOUT_GUIDE:10) - 40, 200, 40);
        [_filterSegment addTarget:self action:@selector(filterChange) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_filterSegment];
    }
    return  _filterSegment;;
}

- (void)onExitRoom:(NSInteger)reason{
    [TRTCCloud destroySharedIntance];
    [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
    [[[GPUImageContext sharedImageProcessingContext] framebufferCache] purgeAllUnassignedFramebuffers];
}

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


@end
