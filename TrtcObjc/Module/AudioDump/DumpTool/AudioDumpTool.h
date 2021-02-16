//
//  AudioDumpTool.h
//  AudioDumpTool
//
//  Created by kaoji on 2021/1/29.
//  Copyright © 2021 Kaoji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TXLiteAVSDK.h>


NS_ASSUME_NONNULL_BEGIN

@interface AudioDumpTool : NSObject

+ (instancetype) sharedInstance;

- (void)start;

- (void)stop;

/// 采集到的数据
///调用入口- (void)onCapturedRawAudioFrame:(TRTCAudioFrame *)frame
- (void)dumpCaptureData:(TRTCAudioFrame *)frame;

/// SDK处理后的数据
///从此接口调用- (void) onLocalProcessedAudioFrame:(TRTCAudioFrame *)frame
- (void)dumpProcessedData:(TRTCAudioFrame *)frame;

@end

NS_ASSUME_NONNULL_END
