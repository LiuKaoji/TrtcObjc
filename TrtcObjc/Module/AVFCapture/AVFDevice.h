//
//  AVFDevice.h
//  TrtcObjc
//
//  Created by kaoji on 2021/1/4.
//  Copyright © 2021 issuser. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVFDevice : NSObject
/**
*    摄像头
*
*   @param position 摄像头的位置
*   @note 前/后
*/
+ (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position;

/**
*    帧率(FPS)
*
*    @param fps 摄像头每秒采集的帧数
*    @note 推荐15 ~ 18
*/
+ (void)setFps:(CGFloat)fps atDevice:(AVCaptureDevice *)device;

/**
 * 焦距
 *
 * @param distance 焦距大小，取值范围1 - 5，默认值建议设置为1即可。
 * @note 当 distance 为1的时候为最远视角（正常镜头），当为5的时候为最近视角（放大镜头），最大值不要超过5，超过5后画面会模糊不清。
 */
+ (void)setZoom:(CGFloat)distance atDevice:(AVCaptureDevice *)device;

/**
 *  感光度(ISO)
 *
 * @param level 调整参数
 * @note 取值范围 0 - 5 对应 0 50 100 200 300 400感光度
*/
+ (void)setISO:(NSInteger)level atDevice:(AVCaptureDevice *)device;

/**
 *  白平衡/色温(White Balance)
 *
 * @param level 调整参数 暖色在 2000-3000K  到 8000K 冷色
 * @note 0->自动 1->50 2->100 3->200 4->300 5->400
*/
+ (void)setWhiteBalance:(NSInteger)level atDevice:(AVCaptureDevice *)device;

/**
 *  曝光量(EV)
 *
 * @param value 设置曝光偏差
 * @note 表示当前曝光偏差值的特殊常量
*/
+ (void)setEV:(NSInteger)value atDevice:(AVCaptureDevice *)device;

/**
 *  曝光点(EV)
 *
 * @param point Point取值范围是取景框左上角（0，0）到取景框右下角（1，1）之间
 *
 * CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
 * @note 前面是点击位置的y/PreviewLayer的高度，后面是1-点击位置的x/PreviewLayer的宽度
*/
+ (void)setEVFocus:(CGPoint)point Device:(AVCaptureDevice *)device;

/**
 *  焦距
 *
 * @param fMode 表示当前曝光偏差值的特殊常量
 * @note  1.焦点固定 2.仅仅扫描焦距然后恢复到锁定焦点 3.相机持续自动聚焦模式
*/
+ (void)setCameraFocus:(AVCaptureFocusMode)fMode atDevice:(AVCaptureDevice *)device;

/**
 *  焦距
 *
 * @param point 焦点位置
 * @note  设置相机的焦点未知
*/
+ (void)setCameraFocusPosition:(CGPoint)point atDevice:(AVCaptureDevice *)device;

/**
 *  焦距
 *
 * @note  默认的对焦模式
*/
+ (void)defaultCameaFocusMode:(AVCaptureDevice *)device;

/**
 *  聚焦曝光
 * @param point 点击的位置
 * @note 曝光要根据对焦点的光线状况而决定,所以和对焦一块写
*/
+ (void)adjustAt:(CGPoint)point atDevice:(AVCaptureDevice *)device;

/***
 * @note 聚焦曝光默认设置
*/
+ (void)adjustDefaultAtDevice:(AVCaptureDevice *)device;

/**
 * 背光模式
 * @note 电筒
*/
+ (void)torchMode:(AVCaptureTorchMode)mode atDevice:(AVCaptureDevice *)device;

/**
 * 闪光灯模式
*/
+ (void)flashMode:(AVCaptureFlashMode)mode atDevice:(AVCaptureDevice *)device;

/**
 * HDR
*/
+ (void)hdrEnable:(BOOL)isEnable atDevice:(AVCaptureDevice *)device;
@end

NS_ASSUME_NONNULL_END
