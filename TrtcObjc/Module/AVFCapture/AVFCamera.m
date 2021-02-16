//
//  AVFCamera.m
//  TrtcObjc
//
//  Created by kaoji on 2021/1/4.
//  Copyright © 2021 issuser. All rights reserved.
//

#import "AVFCamera.h"
#import "AVFDevice.h"

@interface AVFCamera ()<AVCaptureVideoDataOutputSampleBufferDelegate,
                       AVCaptureAudioDataOutputSampleBufferDelegate>
@end

@implementation AVFCamera

-(instancetype)initWithLayer:(CALayer *)layer
                       Preset:(AVCaptureSessionPreset)preset
                       Position:(AVCaptureDevicePosition)position{
    
    if (self == [super init]) {
        
        _isFront = (position == AVCaptureDevicePositionFront);
        _isCaptureRunning = NO;
        _preset = preset;
       
        _captureSession = [[AVCaptureSession alloc]init];
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
        [_captureSession stopRunning];
        
        _videoDevice = _isFront ? [AVFDevice cameraWithPosition: AVCaptureDevicePositionFront]:
                                  [AVFDevice cameraWithPosition: AVCaptureDevicePositionBack];
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        _previewLayer.frame = layer.bounds;
        [layer addSublayer:_previewLayer];

        NSNotificationCenter *nCenter = [NSNotificationCenter defaultCenter];
        [nCenter addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
        [nCenter addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
        [nCenter addObserver:self selector:@selector(orientationDidChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }

    return self;
}

-(void)forbiddenAudioSessionControl{

    _captureSession.automaticallyConfiguresApplicationAudioSession = NO;
    _captureSession.usesApplicationAudioSession = true;
}

-(void)rotateCamera{
    
    NSError *error;
    AVCaptureDeviceInput *newVideoInput;
    AVCaptureDevicePosition currentCameraPosition = [[_videoInput device] position];
    
    if (currentCameraPosition == AVCaptureDevicePositionBack)
    {
        currentCameraPosition = AVCaptureDevicePositionFront;
    }
    else
    {
        currentCameraPosition = AVCaptureDevicePositionBack;
    }
    
    AVCaptureDevice *backFacingCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == currentCameraPosition)
        {
            backFacingCamera = device;
            self.videoDevice = device;
        }
    }
    newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:backFacingCamera error:&error];
    
    if (newVideoInput != nil)
    {
        [_captureSession beginConfiguration];
        
        [_captureSession removeInput:_videoInput];
        if ([_captureSession canAddInput:newVideoInput])
        {
            [_captureSession addInput:newVideoInput];
            _videoInput = newVideoInput;
        }
        else
        {
            [_captureSession addInput:_videoInput];
        }
        //captureSession.sessionPreset = oriPreset;
        [_captureSession commitConfiguration];
    }
    
}

-(BOOL)startCapture{
    
    if (_isCaptureRunning) {
        return YES;
    }
    NSError *error = nil;
    
    [_captureSession beginConfiguration];
    _videoInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
    if (error) {
        return NO;
    }
    if ([_captureSession canAddInput:_videoInput]) {
        [_captureSession addInput:_videoInput];
    }
    
//    _audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
//    _audioInput = [AVCaptureDeviceInput deviceInputWithDevice:_audioDevice error:&error];
//    if (error) {
//        return NO;
//    }
//    if ([_captureSession canAddInput:_audioInput]) {
//        [_captureSession addInput:_audioInput];
//    }
    
    if ([_captureSession canSetSessionPreset:self.preset]) {
        [_captureSession setSessionPreset:self.preset];
    }
    
    _videoOutput = [[AVCaptureVideoDataOutput alloc]init];
    [[_videoOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    _videoOutput.alwaysDiscardsLateVideoFrames = NO;
    _videoOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    _dataOutputQueue = dispatch_queue_create("com.kaoji.AVCaptureDataQueue", DISPATCH_QUEUE_CONCURRENT);
    [_videoOutput setSampleBufferDelegate:self queue:_dataOutputQueue];
    if ([_captureSession canAddOutput:_videoOutput]) {
        [_captureSession addOutput:_videoOutput];
        AVCaptureVideoOrientation orientation;
        if (self.isPortrait) {
            orientation = AVCaptureVideoOrientationPortrait;
        } else {
            orientation = AVCaptureVideoOrientationLandscapeRight;
        }
        /// 初始的方向
        //[[_videoOutput connectionWithMediaType:AVMediaTypeVideo]setVideoOrientation:orientation];
    }
    
//    _audioOutput = [[AVCaptureAudioDataOutput alloc]init];
//    [_audioOutput setSampleBufferDelegate:self queue:_dataOutputQueue];
//    if ([_captureSession canAddOutput:_audioOutput]) {
//        [_captureSession addOutput:_audioOutput];
//    }
    
    [_captureSession commitConfiguration];
    
    [_captureSession startRunning];
    _isCaptureRunning = YES;
    return YES;
}

-(void)stopCapture{
    
    [_captureSession stopRunning];
    _isCaptureRunning = NO;
    
}

- (void)removeAllInOutPut {
//    if (_audioOutput) {
//        [_captureSession removeOutput:_audioOutput];
//        _audioOutput = nil;
//    }
    if (_videoOutput) {
        [_captureSession removeOutput:_videoOutput];
        _videoOutput = nil;
    }
//    if (_audioInput) {
//        [_captureSession removeInput:_audioInput];
//        _audioInput = nil;
//    }
    if (_videoInput) {
        [_captureSession removeInput:_videoInput];
        _videoInput = nil;
    }
}

- (void)setIsPortrait:(BOOL)isPortrait{
    _isPortrait = isPortrait;
    if (_isPortrait) {
        [[_previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
        [_videoOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation = AVCaptureVideoOrientationPortrait;
    } else {
        [[_previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
        [_videoOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
}

#pragma mark notification
- (void)didEnterBackground:(id)sender {
    [_captureSession stopRunning];
}
- (void)willEnterForeground:(id)sender {
    if (_isCaptureRunning) {
        [_captureSession startRunning];
    }
}
- (void)orientationDidChanged:(id)sender {
    ///需要跟随设备旋转就打开这里
    UIDevice *device = [UIDevice currentDevice];
    //self.isPortrait = UIDeviceOrientationIsPortrait(device.orientation);
}

#pragma mark - AVCapture data output delegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (output == _videoOutput) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didOutputVideoSampleBuffer:)]) {
            [self.delegate didOutputVideoSampleBuffer:sampleBuffer];
        }
    } else {
        ///音频
//        if (self.delegate && [self.delegate respondsToSelector:@selector(didOutputAudioSampleBuffer:)]) {
//            [self.delegate didOutputAudioSampleBuffer:sampleBuffer];
//        }
    }
}
@end
