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

typedef void (^GPUImageBufferOutputBlock) (CVPixelBufferRef _Nullable pixelBufferRef);

NS_ASSUME_NONNULL_BEGIN

@interface GPUImagePixelBufferOutput : GPUImageRawDataOutput <GPUImageInput>

@property(nonatomic, copy)GPUImageBufferOutputBlock pixelBufferCallback;

- (instancetype)initwithImageSize:(CGSize)newImageSize;
@end

NS_ASSUME_NONNULL_END
