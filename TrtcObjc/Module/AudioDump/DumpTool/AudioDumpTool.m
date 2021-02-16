//
//  AudioDumpTool.m
//  AudioDumpTool
//
//  Created by kaoji on 2021/1/29.
//  Copyright © 2021 Kaoji. All rights reserved.
//


#import "AudioDumpTool.h"
#import "AudioDumpConfig.h"

static AudioDumpTool *_instance;

@interface AudioDumpTool (){
    FILE *_captureAudioDumpFile; // 保存采集的音频数据
    FILE *_mixAudioDumpFile;// SDK混音处理后的数据
    BOOL _isStart;
}

@property (nonatomic, strong)NSDateFormatter *formatter;

@end

@implementation AudioDumpTool

+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _instance = [[AudioDumpTool alloc] initPrivate];
    });
    return _instance;
}

- (instancetype)initPrivate {
    self = [super init];
    if (nil != self) {
    
        _isStart = NO;
    }
    return self;
}

- (NSDateFormatter *)formatter{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
        [_formatter setDateFormat:@"yyyy_MM_DD HH_MM_SS_sss"];
    }
    return _formatter;
}

- (void)start{
    
    if (_isStart) {
        return;
    }
    
    /// 检查文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if(![fileManager fileExistsAtPath:D_RootFolder isDirectory:&isDir]){
        [fileManager createDirectoryAtPath:D_RootFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSLog(@"DDD_Path:%@",D_Capture);
    NSString *dateStr = [self.formatter stringFromDate:[NSDate date]];
    NSString *capturePath = [NSString stringWithFormat:@"%@/%@ %@.pcm",D_RootFolder,D_Capture,dateStr];
    NSString *processPath = [NSString stringWithFormat:@"%@/%@ %@.pcm",D_RootFolder,D_Process,dateStr];
    _captureAudioDumpFile = fopen([capturePath UTF8String], "wb");

    _mixAudioDumpFile = fopen([processPath UTF8String], "wb");
    
    _isStart = YES;
}

- (void)stop{
    
    if (!_isStart) {
        return;
    }
    
    _isStart = NO;
    
    fclose(_captureAudioDumpFile);
    fclose(_mixAudioDumpFile);
}

/// 采集到的数据
- (void)dumpCaptureData:(TRTCAudioFrame *)frame{
    if (!_isStart) {
        return;
    }
    fwrite(frame.data.bytes, 1, frame.data.length, _captureAudioDumpFile);
}

/// SDK处理后的数据
- (void)dumpProcessedData:(TRTCAudioFrame *)frame{
    if (!_isStart) {
        return;
    }
    fwrite(frame.data.bytes, 1, frame.data.length, _mixAudioDumpFile);
}

@end
