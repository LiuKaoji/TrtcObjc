//
//  TRTCCustomVideoTest.m
//  TXLiteAVDemo
//
//  Created by rushanting on 2019/3/26.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TestSendCustomVideoData.h"
#import "TXLiteAVSDK.h"
#include <sys/time.h>

@interface TestSendCustomVideoData () {
    NSMutableData *_fileData;
    uint32_t _fileDataReadLen;
    uint32_t _dataSendTotalLen;
    uint64_t audioSendLastTime;
}
@property (nonatomic, strong) TRTCCloud* trtcCloud;
@property (nonatomic, strong) TCMediaFileReader* mediaReader;
@property (nonatomic, assign) BOOL isStart;
@property (nonatomic, assign) BOOL isRepeat;
@end

@implementation TestSendCustomVideoData

- (instancetype)initWithTRTCCloud:(TRTCCloud *)cloud mediaAsset:(AVAsset *)asset
{
    if (self = [super init]) {
        _trtcCloud = cloud;
        _mediaReader = [[TCMediaFileReader alloc] initWithMediaAsset:asset videoReadFormat:VideoReadFormat_NV12];
    }
    
    return self;
}

- (void)start
{
    NSLock *lock = [[NSLock alloc] init];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_group_enter(group);
    
    [self.mediaReader startVideoRead];
    __weak __typeof(self) weakSelf = self;
    [self.mediaReader readVideoFrameFromTime:0 toTime:(float)weakSelf.mediaReader.duration.value/weakSelf.mediaReader.duration.timescale fps:weakSelf.mediaReader.fps group:group readOneFrame:^(CMSampleBufferRef sampleBuffer) {
        __typeof(self) strongSelf = weakSelf;
        TRTCVideoFrame* videoFrame = [TRTCVideoFrame new];
        videoFrame.bufferType = TRTCVideoBufferType_PixelBuffer;
        videoFrame.pixelFormat = TRTCVideoPixelFormat_NV12;
        videoFrame.pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        TRTCVideoRotation rotation = TRTCVideoRotation_0;
        if (strongSelf.mediaReader.angle == 90) {
            rotation = TRTCVideoRotation_90;
        }
        else if (strongSelf.mediaReader.angle == 180) {
            rotation = TRTCVideoRotation_180;
        }
        else if (strongSelf.mediaReader.angle == 270) {
            rotation = TRTCVideoRotation_270;
        }
        videoFrame.rotation = rotation;
        [strongSelf.trtcCloud sendCustomVideoData:videoFrame];
        
        CMTime time = kCMTimeZero;
        time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        float pts = (float)time.value / time.timescale;
        
    } readFinished:^{
        // 视频播放结束是否循环播放逻辑
        __typeof(self) strongSelf = weakSelf;
        strongSelf.mediaReader.currentTime = 0;
        strongSelf.isStart = NO;
    }];
    
    if (self -> _fileData.length > 0) {
        dispatch_group_leave(group);
        self.isStart = YES;
    } else {
        self.isStart = YES;
        [weakSelf.mediaReader startAudioRead];
        [weakSelf.mediaReader readAudioFrameFromTime:0 toTime:(float)weakSelf.mediaReader.duration.value/weakSelf.mediaReader.duration.timescale group:group readOneFrame:^(CMSampleBufferRef sampleBuffer) {
            __typeof(self) strongSelf = weakSelf;
            if(sampleBuffer==NULL) return;
            AudioBufferList audioBufferList;
            NSMutableData *pcmData=[[NSMutableData alloc] init];
            CMBlockBufferRef blockBuffer;
            
            CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(sampleBuffer, NULL, &audioBufferList, sizeof(audioBufferList), NULL, NULL, 0, &blockBuffer);
            
            CMAudioFormatDescriptionRef formatDesc = (CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer);
            AudioStreamBasicDescription *asbd = (const *)CMAudioFormatDescriptionGetStreamBasicDescription(formatDesc);
            
            for( int y=0; y<audioBufferList.mNumberBuffers; y++ ) {
                AudioBuffer audioBuffer = audioBufferList.mBuffers[y];
                
                if (asbd->mBitsPerChannel == 32) {
                    fixedPointToSInt16((Float32 *)audioBuffer.mData, (SInt16 *)audioBuffer.mData, audioBuffer.mDataByteSize / (32 / 8));
                    
                    [pcmData appendBytes:audioBuffer.mData length:audioBuffer.mDataByteSize/2];
                }else{

                    [pcmData appendBytes:audioBuffer.mData length:audioBuffer.mDataByteSize];
                }
            }
            CFRelease(blockBuffer);
            blockBuffer=NULL;
            if (strongSelf->_fileData == nil) {
                strongSelf->_fileData = [NSMutableData dataWithData:pcmData];
            } else {
                [lock lock];
                [strongSelf->_fileData appendData:pcmData];
                [lock unlock];
            }
            
        } readFinished:^() {
            //__typeof(self) strongSelf = weakSelf;
            
        }];
    }
    
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __typeof(self) strongSelf = weakSelf;
        self->_fileDataReadLen = 0;
        int frameLenInBytes = self.mediaReader.audioSampleRate*0.02 *self.mediaReader.audioChannels*(16/8);
        struct timeval tv;
        gettimeofday(&tv,NULL);
        uint64_t currentTime = tv.tv_sec * 1000 + tv.tv_usec / 1000;
        self.mediaReader.currentTime = currentTime;
        while (self.isStart) {

            if (!(strongSelf->_isStart)) {
                [self->_fileData resetBytesInRange:NSMakeRange(0, [self->_fileData length])];
                [self->_fileData setLength:0];
                self->_fileData = nil;
                break;
            }
            
            if (self->_fileData) {
                struct timeval tv;
                gettimeofday(&tv,NULL);
                uint64_t currentTime1 = tv.tv_sec * 1000 + tv.tv_usec / 1000;
                if (strongSelf->audioSendLastTime / 1000 > currentTime1 - currentTime) {
                    //NSLog(@"audio sleep:%ld", audioSendLastTime - currentTime1 * 1000 + currentTime * 1000);
                    usleep(strongSelf->audioSendLastTime - currentTime1 * 1000 + currentTime * 1000);
                }
                
                strongSelf->audioSendLastTime += (20 * 1000);
                
                [lock lock];
                NSData *pcmData = [NSData dataWithBytes:self->_fileData.bytes+self->_fileDataReadLen length:frameLenInBytes];
                [lock unlock];
                
                TRTCAudioFrame * frame = [[TRTCAudioFrame alloc] init];
                frame.data = [NSData dataWithData:pcmData];
                frame.sampleRate = self.mediaReader.audioSampleRate;
                frame.channels = self.mediaReader.audioChannels;
                
                [self.trtcCloud sendCustomAudioData:frame];
               // NSLog([NSString stringWithFormat:@"\nssssssssss %ld", (tv.tv_sec * 1000 + tv.tv_usec / 1000)]);
            }
            self->_fileDataReadLen += frameLenInBytes;
            if (self->_fileDataReadLen+frameLenInBytes > self->_fileData.length) {
                self->_fileDataReadLen = 0;
            }
        }
        //        self->_fileData = nil;
    });
}

- (void)stop
{
    self.isStart = NO;
    [self.mediaReader stopVideoRead];
    [self.mediaReader stopAudioRead];
    self.mediaReader = nil;
}

- (TCMediaFileReader*)mediaReader
{
    return _mediaReader;
}

void fixedPointToSInt16(float *source, int16_t *target, int length) {
    for (int i = 0; i < length; i++) {
        source[i] *= 32768;
        if (source[i] > 32767) source[i] = 32767;
        if (source[i] < -32768) source[i] = -32768;
        target[i] = (int16_t)source[i];
    }
}
@end
