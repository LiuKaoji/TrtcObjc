//
//  AVFCamera.h
//  TrtcObjc
//
//  Created by kaoji on 2021/1/4.
//  Copyright © 2021 issuser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///  AVFCameraDataOutputDelegate
///  采集数据回调
///
@protocol AVFCameraDataOutputDelegate <NSObject>
@optional
- (void)didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
//- (void)didOutputAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end

@interface AVFCamera : NSObject
@property (nonatomic, weak) id<AVFCameraDataOutputDelegate> delegate;
@property (nonatomic, assign) BOOL isFront;///当前是否使用前置相机
@property (nonatomic, assign) BOOL isPortrait;///横竖屏

@property(nonatomic, assign) BOOL isCaptureRunning;/// 是否正在采集
@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, strong) AVCaptureDevice  *videoDevice;
@property(nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property(nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;

//@property(nonatomic, strong) AVCaptureDevice  *audioDevice;///不使用音频模块
//@property(nonatomic, strong) AVCaptureDeviceInput *audioInput;
//@property(nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;

@property(nonatomic, strong) dispatch_queue_t dataOutputQueue;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, copy) AVCaptureSessionPreset preset;///分辨率

- (instancetype)init NS_UNAVAILABLE;

/**
 *  初始化
 *  @param layer       用于承载画面的Layer预览页面
 *  @param preset     采集画面大小
 *  @param position 摄像头的位置
 *  @note 前/后
 */
-(instancetype)initWithLayer:(AVCaptureVideoPreviewLayer *)layer
                       Preset:(AVCaptureSessionPreset)preset
                       Position:(AVCaptureDevicePosition)position NS_DESIGNATED_INITIALIZER;
/**
 *  关闭预置的AudioSession
 *  @note 关闭AVFoudation对于音频的调控,抢占会导致TRTC声音断续/无声
 */
-(void)forbiddenAudioSessionControl;

/**
 *  切换摄像头
 *  @note 前后摄像头切换
 */
-(void)rotateCamera;

/**
 *  开始采集
 *  @Note 成功: YES 失败: NO
 */
-(BOOL)startCapture;

/**
 *  停止采集
 */
-(void)stopCapture;
@end

NS_ASSUME_NONNULL_END
