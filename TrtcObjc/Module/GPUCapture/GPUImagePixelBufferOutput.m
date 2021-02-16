//
//  GPUImagePixelBufferOutput.m
//  TrtcObjc
//
//  Created by kaoji on 2020/8/23.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import "GPUImagePixelBufferOutput.h"

@implementation GPUImagePixelBufferOutput
{
   __weak GPUImageVideoCamera *_videoCamera;
}

- (instancetype)initwithImageSize:(CGSize)newImageSize{
 
  if (self == [super initWithImageSize:newImageSize resultsInBGRAFormat:YES]) {
    
  }
  return self;
}

#pragma mark - GPUImageInput protocol
- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
   [super newFrameReadyAtTime:frameTime atIndex:textureIndex];

    [self lockFramebufferForReading];

    CVPixelBufferRef pixelBuffer = NULL;
    CVPixelBufferCreateWithBytes(NULL,
                                 imageSize.width,
                                 imageSize.height,
                                 kCVPixelFormatType_32BGRA,
                                 self.rawBytesForImage,
                                 self.bytesPerRowInOutput,
                                 NULL,
                                 NULL,
                                 NULL,
                                 &pixelBuffer);
    
    if(self.pixelBufferCallback){
        self.pixelBufferCallback(pixelBuffer);
    }
    CVPixelBufferRelease(pixelBuffer);
    [self unlockFramebufferAfterReading];
}

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {}

- (void)processAudioBuffer:(CMSampleBufferRef)audioBuffer {}

- (BOOL)hasAudioTrack {return YES;}

@end
