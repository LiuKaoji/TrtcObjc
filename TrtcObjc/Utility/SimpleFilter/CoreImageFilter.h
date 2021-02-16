//
//  CoreImageFilter.h
//  TrtcObjc
//
//  Created by kaoji on 2020/8/25.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoreImageFilter : NSObject

/*
* @note 用来绘制CIFilter所产生的目标图像的地方的对象
* @note 这个上下文可以是基于CPU也可以是基于GPU
*/
@property(nonatomic,strong) CIContext *fContex;

/*
* @param frame 参考TRTCCloudDef.h 描述一帧视频数据的模型
* @note 将一帧数据交给CIFilter处理 并返回CIImage
*/
-(CIImage *)filterPixelBuffer:(TRTCVideoFrame *)frame;

@end

NS_ASSUME_NONNULL_END
