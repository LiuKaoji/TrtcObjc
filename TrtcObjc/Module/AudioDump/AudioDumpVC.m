//
//  AudioDumpVC.m
//  TrtcObjc
//
//  Created by kaoji on 2021/1/14.
//  Copyright © 2021 issuser. All rights reserved.
//

#import "AudioDumpVC.h"
#import "AudioDumpTool.h"
#import <Masonry.h>
#import "AudioEmbedView.h"
#import "AudioDumpConfig.h"
#import <AudioEffectSettingKit/AudioEffectSettingKit.h>

@interface AudioDumpVC ()<TRTCAudioFrameDelegate>
@property(nonatomic, strong)AudioEffectSettingView *bgmPanel;
@end

@implementation AudioDumpVC

-(void)viewDidLoad{
    [super viewDidLoad];
    [self createView];
    [self startRenderDemo];
}

-(void)createView{

    NSMutableArray *buttons = [NSMutableArray array];
    NSArray *titles  = @[@"转存",@"背景音",@"预览"];
    NSArray *actions = @[NSStringFromSelector(@selector(start:)),NSStringFromSelector(@selector(showBgm:)),NSStringFromSelector(@selector(preview))];

    for (NSInteger i = 0; i < 3; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.layer.cornerRadius = 5;
        [button setTitle:titles[i] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor whiteColor];
        [button addTarget:self action:NSSelectorFromString(actions[i]) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [buttons addObject:button];
    }

    [buttons mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:30 leadSpacing:15 tailSpacing:15];
    [buttons mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
        make.height.equalTo(@40);
    }];

}

-(void)startRenderDemo{
    
    /// 01.启用SDK音视频采集
    [self.rtcManager startCapture:SDKCapture Preview:self.view];
    
    /// 02.设置音频代理回调
    [self.rtcManager.trtc setAudioFrameDelegate:self];

    /// 03.进房,并推流
    [self.rtcManager enterRoomUsingDefautParam];
    
    //////////////////////////////////____BGM播放______///////////////////////////
    _bgmPanel = [[AudioEffectSettingView alloc]initWithType:AudioEffectSettingViewDefault];
    [_bgmPanel setAudioEffectManager:self.rtcManager.trtc.getAudioEffectManager];
    [self.view addSubview:_bgmPanel];
    
    //////////////////////////////////____音频采样______///////////////////////////
    [self.rtcManager setExperimentConfig:@"setAudioSampleRate" params:@{@"sampleRate":@(D_SampleRate)}];///采样率
    
    
    //////////////////////////////////____3A   设置_______////////////////////////
    ///AEC: 音频AEC开关
    ///[self.rtcManager setExperimentConfig:@"enableAudioAEC" params:@{@"enable":@(1)}];//AEC
    
    ///ANS : 可选参数，enable 为 1 时生效，用于指定 ANS 的级别，支持的取值有: 0、30、60、100，0 表示关闭 ANS，100 表示最高级别
    ///[self.rtcManager setExperimentConfig:@"enableAudioANS" params:@{@"enable":@(1),@"level":@(30)}];
    
    ///AGC: [Edu only / PC only] 可选参数，enable 为 1 时生效，用于指定 AGC 的级别，支持的取值有: 0、30、60、100，0 表示关闭 AGC，100 表示最高级别
    ///[self.rtcManager setExperimentConfig:@"enableAudioANS" params:@{@"enable":@(1),@"level":@(30)}];
}

-(void)start:(UIButton *)sender{
    sender.selected = !sender.isSelected;
    [sender setTitle:sender.isSelected ?@"停止":@"转存" forState:UIControlStateNormal];
    sender.isSelected ? [[AudioDumpTool sharedInstance] start]:[[AudioDumpTool sharedInstance] stop];
}

-(void)showBgm:(UIButton *)sender{
 
    [_bgmPanel show];
}

-(void)preview{
    
    ////  停止TRTC 开始预览
    [_bgmPanel stopPlay];
    [_bgmPanel resetAudioSetting];
    [self.rtcManager stopCapture];
    
    __weak __typeof__(self) weakSelf = self;
    [AudioEmbedView show:^{
        __strong __typeof(self) strongSelf = weakSelf;
        [strongSelf startRenderDemo];///恢复TRTC
    }];;
}


#pragma mark - TRTCAudioFrameDelegate
- (void)onCapturedRawAudioFrame:(TRTCAudioFrame *)frame{
    
    /// 04.原始数据回调
    [[AudioDumpTool sharedInstance] dumpCaptureData:frame];
}

- (void)onLocalProcessedAudioFrame:(TRTCAudioFrame *)frame{
    
    /// 05.混音数据回调
    [[AudioDumpTool sharedInstance] dumpProcessedData:frame];
}

#pragma mark - 父类重写
-(void)onClickBack{
    
    [self.rtcManager exitRoom];
    [self.rtcManager stopCapture];
    [RTCLocalManager destroySharedIntance];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 父类重写
-(void)dealloc{
    
    [RTCLocalManager destroySharedIntance];
}

@end

