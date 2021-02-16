//
//  AudioDumpConfig.h
//  TrtcObjc
//
//  Created by kaoji on 2021/2/14.
//  Copyright © 2021 issuser. All rights reserved.
//

#ifndef AudioDumpConfig_h
#define AudioDumpConfig_h

#define D_SampleRate    48000
#define D_BitsPerSample 16
#define D_Channels   1

///沙盒文稿目录
#define KJDocuments    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
/// Dump 文件主目录
#define D_RootFolder   [KJDocuments stringByAppendingPathComponent:@"AudioDump"]
#define D_Capture      @"CaptureRawData"
#define D_Process      @"ProcessRawData"
#endif /* AudioDumpConfig_h */

static NSString * formatTimeInterval(CGFloat seconds)
{
    seconds = MAX(0, seconds);
    
    if(seconds == 0){
        
        return @"--:--";
    }
    
    NSInteger s = seconds;
    NSInteger m = s / 60;
    NSInteger h = m / 60;
    
    s = s % 60;
    m = m % 60;
    
    NSMutableString *format = [(seconds <0 ? @"-" : @"") mutableCopy];
    
    if(h>0){
        
        [format appendFormat:@"%ld:%0.2ld", (long)h, (long)m];
        [format appendFormat:@":%0.2ld", (long)s];
        
        
    }else{
        
        [format appendFormat:@"%0.2ld", (long)m];
        [format appendFormat:@":%0.2ld", (long)s];
        
    }
    
    return format;
}
