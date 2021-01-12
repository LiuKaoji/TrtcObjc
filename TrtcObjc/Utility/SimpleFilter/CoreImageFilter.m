//
//  CoreImageFilter.m
//  TrtcObjc
//
//  Created by kaoji on 2020/8/25.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import "CoreImageFilter.h"

@interface CoreImageFilter ()
@property (nonatomic,strong) CIFilter * vignetteFilter;
@property (nonatomic,strong) CIFilter * effectFilter;
@end

@implementation CoreImageFilter

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupCoreImageFilter];
    }
    return self;
}

-(void)setupCoreImageFilter{
    //滤镜
    _vignetteFilter = [CIFilter filterWithName:@"CIVignetteEffect"];
    _effectFilter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
    
    //上下文
    _fContex = [CIContext contextWithOptions:nil];
}

-(CIImage *)filterPixelBuffer:(TRTCVideoFrame *)frame{
    
    //将buffer取出
    CVImageBufferRef imageBuffer = frame.pixelBuffer;
    CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];
    CGRect sourceExtent = sourceImage.extent;
    
    // 用coreImage加上滤镜 得到CIImage
    [_vignetteFilter setValue:sourceImage forKey:kCIInputImageKey];
    [_vignetteFilter setValue:[CIVector vectorWithX:sourceExtent.size.width/2 Y:sourceExtent.size.height/2] forKey:kCIInputCenterKey];
    [_vignetteFilter setValue:@(sourceExtent.size.width/2) forKey:kCIInputRadiusKey];
    CIImage *filteredImage = [_vignetteFilter outputImage];
    
    [_effectFilter setValue:filteredImage forKey:kCIInputImageKey];
    filteredImage = [_effectFilter outputImage];
    
    return filteredImage;
}

@end
