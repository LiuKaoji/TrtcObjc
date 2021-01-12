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
@property(nonatomic,strong)CIContext *fContex;
//将buffer通过CoreImage进行修改
-(CIImage *)filterPixelBuffer:(TRTCVideoFrame *)frame;

@end

NS_ASSUME_NONNULL_END
