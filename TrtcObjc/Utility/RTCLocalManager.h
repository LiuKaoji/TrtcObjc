//
//  RTCLocalManager.h
//  TrtcObjc
//
//  Created by kaoji on 2021/1/6.
//  Copyright © 2021 issuser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AVFDevice.h"
#import "AVFCamera.h"
#import "DotGPUImageBeautyFilter.h"

typedef NS_ENUM(NSInteger,RtcCaptureMode)
{
    SDKCapture = 0,///音视频均使用SDK采集
    AudioCapture = 1,/// SDK视频采集,自定义音频采集
    AVFVideoCapture = 2,/// AVCaptureSession视频采集,SDK音频采集
    GPUVideoCapture = 3,/// GPUImageView 视频采集, ,SDK音频采集
};

@interface RTCLocalManager : NSObject

@property(nonatomic, strong)TRTCCloud *trtc;
@property(nonatomic, strong)TRTCParams *param; /// 进房参数
@property(nonatomic, strong)TRTCVideoEncParam *encParam; /// 编码参数
@property(nonatomic, assign)RtcCaptureMode captureMode; /// 采集类型
@property(nonatomic, assign)BOOL isFront; /// 是否前置


/*
* @param param mode 采集的方式
* @param Preview 承载的控件
*/
-(id)startCapture:(RtcCaptureMode)mode Preview:(id)widget;

/*
* @note Preview 关闭采集
*/
-(void)stopCapture;

/*
* @note 切换相机
*/
-(void)switchCamera;

/*
* @note 使用默然参数进房
*/
- (void)enterRoomUsingDefautParam;

/*
* @param param 进房参数，请参考 TRTCParams
* @param scene 视频通话（VideoCall）、连麦直播（Live）、语音通话（AudioCall）、语聊房（VoiceChatRoom)
*/
- (void)enterRoom:(TRTCParams *)param appScene:(TRTCAppScene)scene;

/*
* 退出房间
* @note 调用 exitRoom() 接口会执行退出房间的相关逻辑，例如释放音视频设备资源和编解码器资源等。
* @note 待资源释放完毕，SDK 会通过 TRTCCloudDelegate 中的 onExitRoom() 回调通知到您。
*/
- (void)exitRoom;

/*
 * @param frontCamera YES：前置摄像头；NO：后置摄像头。
 * @param view 承载视频画面的控件
*/
- (void)startLocalPreview:(BOOL)frontCamera view:(UIView *)view;

/*
* @note 该函数会启动麦克风采集，并将音频数据传输给房间里的其他用户。
*/
- (void)startLocalAudio;

/*
 * @note 停止SDK视频采集
*/
- (void)stopLocalPreview;

/*
* @note 停止SDK音频采集
*/
- (void)stopLocalAudio;

/*
* @param enable 是否启用，默认值：NO
* @note 开启该模式后，SDK 不在运行原有的视频采集流程，只保留编码和发送能力。
* @note 您需要用 sendCustomVideoData() 不断地向 SDK 塞入自己采集的视频画面。
*/
- (void)enableCustomVideoCapture:(BOOL)enable;

/*
* @param enable 是否启用, true：启用；false：关闭，默认值：NO
* @note 由于回声抵消（AEC）需要严格的控制声音采集和播放的时间，所以开启自定义音频采集后，AEC 能力可能会失效。
* @note [trtc callExperimentalAPI:@"{\"api\":\"setCustomRenderMode\",\"params\" : {\"mode\":1}}"];
*/
- (void)enableCustomAudioCapture:(BOOL)enable;

/**
 * 设置视频编码器相关参数
 *
 * 该设置决定了远端用户看到的画面质量（同时也是云端录制出的视频文件的画面质量）
 *
 * @param param 视频编码参数，详情请参考 TRTCCloudDef.h 中的 TRTCVideoEncParam 定义
 */
- (void)setVideoEncoderParam:(TRTCVideoEncParam*)param;

/*
* 本地画面渲染模式
*
* @param mode 填充（画面可能会被拉伸裁剪）或适应（画面可能会有黑边），默认值：TRTCVideoFillMode_Fill
*/
- (void)setLocalViewFillMode:(TRTCVideoFillMode)mode;

/*
* @param mode 重力感应模式，详情请参考 TRTCGSensorMode 的定义，默认值：TRTCGSensorMode_UIAutoLayout
*/
- (void)setGSensorMode:(TRTCGSensorMode) mode;

/*
* TRTC代理
* 参考TRTCCloudDelegate 状态通知等信息回调
*/
-(void)setRtcDelegate:(id<TRTCCloudDelegate>)delegate;

/*
* 设置本地视频数据回调
* @param delegate trtc的本地视频数据回调
* @note 渲染回调,支持修改buffer数据实现美颜
* @note 渲染回调,支持修改buffer数据实现美颜 
*/
- (void)setLocalVideoRenderDelegate:(id<TRTCVideoRenderDelegate>)delegate pixelFormat:(TRTCVideoPixelFormat)pixelFormat bufferType:(TRTCVideoBufferType)bufferType;

/**
 * 第三方美颜的视频数据回调
 * @param delegate 自定义预处理回调，详见 {@link TRTCVideoFrameDelegate}
 * @param pixelFormat 指定回调的像素格式，目前仅支持 {@link TRTCCloudDef#TRTCVideoPixelFormat_Texture_2D}
 * @param bufferType 指定回调的数据格式，目前仅支持 {@link TRTCCloudDef#TRTCVideoBufferType_Texture}
 * @return 0：成功；<0：错误
 * @note 此接口处理效率优于setLocalVideoRenderDelegate
 */
- (void)setLocalVideoProcessDelegete:(id<TRTCVideoFrameDelegate>)delegate pixelFormat:(TRTCVideoPixelFormat)pixelFormat bufferType:(TRTCVideoBufferType)bufferType;

/**
 * 12.7 显示仪表盘
 *
 * 仪表盘是状态统计和事件消息浮层 view，方便调试。
 * @param showType 0：不显示；1：显示精简版；2：显示全量版
 */
- (void)showDebugView:(NSInteger)showType;

/*
* 设置远端视频数据回调
* @param key 通常为api
* @param params 设置参数
* @note 调用Trtc的隐藏接口功能
*/
- (void)setExperimentConfig:(NSString *)key params:(NSDictionary *)params;

/**
*  销毁 TRTCCloud 单例
*/
+ (void)destroySharedIntance;

@end
