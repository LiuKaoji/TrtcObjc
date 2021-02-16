//
//  LUTFilter.h
//  TrtcOjc
//
//  Created by kaoji on 2021/1/5.
//  Copyright © 2021 issuser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CIImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface LUTFilter : NSObject
/*
* @note 初始化时加载了一组LUT图
* @note 用于切换下一个LUT图
*/
-(void)nextFilter;

/*
* @param srcFrame 原始数据(处理前的数据)
* @param dstFrame 目标数据(处理后的数据)
* @note 通过CIFilter加上LUT图滤镜效果 并回调给TRTC渲染/编码/发送
*/
-(void)processTrtcFrame:(TRTCVideoFrame *)srcFrame to:(TRTCVideoFrame *)dstFrame;
@end

NS_ASSUME_NONNULL_END
