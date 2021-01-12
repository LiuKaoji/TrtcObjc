//
//  GPUImagePixelBufferOutput.h
//  TrtcObjc
//
//  Created by kaoji on 2020/8/23.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GPUImageRawDataOutput.h"
#import <GPUImageVideoCamera.h>

@protocol GPUImagePixelBufferOutputDelegate <NSObject>

- (void)imagePixelBufferOutputCompleted:(CVPixelBufferRef _Nonnull )pixelBufferRef;

@end

typedef void (^GPUImageBufferOutputBlock) (CVPixelBufferRef _Nullable pixelBufferRef);

NS_ASSUME_NONNULL_BEGIN

@interface GPUImagePixelBufferOutput : GPUImageRawDataOutput <GPUImageInput,GPUImageVideoCameraDelegate>
@property(nonatomic, copy)GPUImageBufferOutputBlock pixelBufferCallback;
- (instancetype)initWithVideoCamera:(GPUImageVideoCamera *)camera withImageSize:(CGSize)newImageSize;
@end

NS_ASSUME_NONNULL_END
