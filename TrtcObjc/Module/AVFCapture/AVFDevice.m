//
//  AVFDevice.m
//  TrtcObjc
//
//  Created by kaoji on 2021/1/4.
//  Copyright © 2021 issuser. All rights reserved.
//

#import "AVFDevice.h"

@implementation AVFDevice

+ (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position{
    
    if (@available(iOS 10.0, *)) {
        return [[AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInTelephotoCamera,AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position].devices firstObject];
    } else {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices)
        {
            if ([device position] == position)
            {
                return device;
            }
        }
        return devices.firstObject;
    }
}

+ (void)setFps:(CGFloat)fps atDevice:(AVCaptureDevice *)device{
    NSError *error;
    [device lockForConfiguration:&error];
    if (!error) {
        CMTime frameDuration = CMTimeMake(1, (int)fps);
        NSArray *supportedFrameRateRanges = [device.activeFormat videoSupportedFrameRateRanges];
        BOOL frameRateSupported = NO;
        for (AVFrameRateRange *range in supportedFrameRateRanges) {
            if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) &&
                CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
                frameRateSupported = YES;
            }
        }
        
        if (frameRateSupported ) {
            [device setActiveVideoMaxFrameDuration:frameDuration];
            [device setActiveVideoMinFrameDuration:frameDuration];
            
        }
    }
    [device unlockForConfiguration];
}


+ (void)setZoom:(CGFloat)distance atDevice:(AVCaptureDevice *)device{
    
    NSError *error;
    [device lockForConfiguration:&error];
    if (!error) {
        device.videoZoomFactor = distance;
    }
    [device unlockForConfiguration];
}


+ (void)setISO:(NSInteger)level atDevice:(AVCaptureDevice *)device{
    
    CGFloat isoValue = 0;
    switch (level) {
        case 0:
            [device lockForConfiguration:nil];
            if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            } else if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
                device.exposureMode = AVCaptureExposureModeAutoExpose;
            }
            [device unlockForConfiguration];
            return;
            break;
        case 1:
            isoValue = 50;
            break;
        case 2:
            isoValue = 100;
            break;
        case 3:
            isoValue = 200;
            break;
        case 4:
            isoValue = 300;
            break;
        case 5:
            isoValue = 400;
            break;
        default:
            break;
    }
    float mx = device.activeFormat.maxISO;//1856
    float m = device.activeFormat.minISO;//29
    NSLog(@"Max ISO:%.0f",mx);
    if (isoValue < m) {
        isoValue = m;
    }
    if (isoValue > mx) {
        isoValue = mx;
    }
    if (isoValue > 0) {
        NSError *error;
        [device lockForConfiguration:&error];
        if (!error) {
            if (AVCaptureExposureModeLocked != device.exposureMode) {
                if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                    [device setExposureMode:AVCaptureExposureModeLocked];
                }
            }
            if (AVCaptureExposureModeLocked == device.exposureMode) {
                [device setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:isoValue completionHandler:^(CMTime syncTime) {
                    NSLog(@"Camera set ISO:%.1f",isoValue);
                }];
            } else {
                NSLog(@"Camera can't set ISO");
            }
        }
        [device unlockForConfiguration];
    }
}


+ (void)setWhiteBalance:(NSInteger)level atDevice:(AVCaptureDevice *)device{
    AVCaptureWhiteBalanceTemperatureAndTintValues tat;
    switch (level) {
        case 1:
            tat.temperature = 7500;//色温值在 2000-3000K (类似蜡烛或灯泡的暖光源) 到 8000K (纯净的蓝色天空) 之间
            break;
        case 2:
            tat.temperature = 5200;
            break;
        case 3:
            tat.temperature = 6000;
            break;
        case 4:
            tat.temperature = 3000;
            break;
        default:
            if (AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance != device.whiteBalanceMode) {
                if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]){
                    [device lockForConfiguration:nil];
                    [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
                    [device unlockForConfiguration];
                }
            }
            return;
            break;
    }
    NSError *error;
    [device lockForConfiguration:&error];
    if (!error) {
        if (AVCaptureWhiteBalanceModeLocked != device.whiteBalanceMode) {
            if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]){
                [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
            }
        }
        if (AVCaptureWhiteBalanceModeLocked == device.whiteBalanceMode) {
            tat.tint = 0;//色彩范围从最小的 -150 (偏绿) 到 150 (偏品红)。
            AVCaptureWhiteBalanceGains gains = [device deviceWhiteBalanceGainsForTemperatureAndTintValues:tat];
            [device setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains:gains completionHandler:^(CMTime syncTime) {
                NSLog(@"Camera set white belence");
            }];
            
        } else {
            NSLog(@"Camera can't set white belence");
        }
    }
    [device unlockForConfiguration];
}

+ (void)setEV:(NSInteger)value atDevice:(AVCaptureDevice *)device{
    NSError *error;
    [device lockForConfiguration:&error];
    if (!error) {
        float evMax = device.maxExposureTargetBias;//
        float evMin = device.minExposureTargetBias > -4 ? device.minExposureTargetBias:-4;
        float s = 1;
        float val = 0;
        switch (value) {
            case 0:
                val = evMin;
                break;
            case 1:
                val = evMin + s;
                break;
            case 2:
                val = evMin + s*2;
                break;
            case 3:
                val = evMin + s*3;
                break;
            case 4:
                val = evMin + s*4;
                break;
            case 5:
                val = evMin + s*5;
                break;
            case 6:
                val = evMin + s*6;
                break;
            case 7:
                val = evMin + s*7;
                break;
            case 8:
                val = evMin + s*8;
                break;
            default:
                break;
        }
        if (val < evMin) {
            val = evMin;
        }
        if (val > evMax) {
            val = evMax;
        }
        if (AVCaptureExposureModeContinuousAutoExposure != device.exposureMode) {
            if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
        }
        if (AVCaptureExposureModeContinuousAutoExposure == device.exposureMode) {
            [device setExposureTargetBias:val completionHandler:^(CMTime syncTime) {
                NSLog(@"Camera set EV:%.0f",val);
            }];
        } else {
            NSLog(@"Camera can't set EV");
        }
    }
    [device unlockForConfiguration];
}

+ (void)setEVFocus:(CGPoint)point Device:(AVCaptureDevice *)device{
    
    NSError *error;
    [device lockForConfiguration:&error];
    [device setExposurePointOfInterest:point];
    [device setExposureMode:device.exposureMode];
    [device unlockForConfiguration];
}

+ (void)setCameraFocus:(AVCaptureFocusMode)fMode atDevice:(AVCaptureDevice *)device{
    NSError *error;
    [device lockForConfiguration:&error];
    [device setFocusMode:fMode];
    [device unlockForConfiguration];
    
}

+ (void)setCameraFocusPosition:(CGPoint)point atDevice:(AVCaptureDevice *)device{
    
    NSError *error;
    [device lockForConfiguration:&error];
    [device setFocusPointOfInterest:point];
    [device setFocusMode:device.focusMode];
    [device unlockForConfiguration];
}

+ (void)defaultCameaFocusMode:(AVCaptureDevice *)device{
    [device lockForConfiguration:nil];
    
    if (device.smoothAutoFocusSupported ) {
        device.smoothAutoFocusEnabled = YES;
    }
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    } else if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
        device.focusMode = AVCaptureFocusModeAutoFocus;
    } else if ([device isFocusModeSupported:AVCaptureFocusModeLocked]){
        device.focusMode = AVCaptureFocusModeLocked;
    }
    [device unlockForConfiguration];
}


+ (void)adjustAt:(CGPoint)point atDevice:(AVCaptureDevice *)device{
    if (device.isFocusPointOfInterestSupported) {
        NSError *error;
        [device lockForConfiguration:&error];
        [device setFocusPointOfInterest:point];
        [device setFocusMode:device.focusMode];
        [device setExposurePointOfInterest:point];
        [device setExposureMode:device.exposureMode];
        [device unlockForConfiguration];
    }
}

+ (void)adjustDefaultAtDevice:(AVCaptureDevice *)device{
    if (device.isFocusPointOfInterestSupported) {
        CGPoint point = CGPointMake(0.5, 0.5);
        NSError *error;
        [device lockForConfiguration:&error];
        [device setFocusPointOfInterest:point];
        [device setFocusMode:device.focusMode];
        [device setExposurePointOfInterest:point];
        [device setExposureMode:device.exposureMode];
        [device unlockForConfiguration];
    }
}

+ (void)torchMode:(AVCaptureTorchMode)mode atDevice:(AVCaptureDevice *)device{
    if (device.isTorchAvailable) {
        [device lockForConfiguration:nil];
        [device setTorchMode:mode];
        [device unlockForConfiguration];
    }
}

+ (void)flashMode:(AVCaptureFlashMode)mode atDevice:(AVCaptureDevice *)device{
    if (device.flashAvailable) {
        [device lockForConfiguration:nil];
        
        [AVCapturePhotoSettings photoSettings].flashMode = mode;
    }
}

+ (void)hdrEnable:(BOOL)isEnable atDevice:(AVCaptureDevice *)device{
    NSError *error;
    if (device.activeFormat.isVideoHDRSupported) {
        [device lockForConfiguration:&error];
        device.automaticallyAdjustsVideoHDREnabled = NO;
        [device setVideoHDREnabled:isEnable];
        [device unlockForConfiguration];
    }
}
@end
