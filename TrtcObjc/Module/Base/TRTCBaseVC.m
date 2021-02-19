//
//  TRTCBaseVC.m
//  TrtcObjc
//
//  Created by kaoji on 2020/8/22.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import "TRTCBaseVC.h"
#import "TRTCBaseView.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface TRTCBaseVC ()<TRTCCloudDelegate>

@property(nonatomic, strong)TRTCBaseView *baseView;

@end

@implementation TRTCBaseVC
{
    NSString *_demoTitle;
}
- (void)loadView{
    [super loadView];
    
    _baseView = [[TRTCBaseView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _baseView.titleLabel.text = self->_demoTitle;
    self.view = _baseView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

        _rtcManager = [[RTCLocalManager alloc] init];
        [_rtcManager setRtcDelegate:self];
        [_rtcManager.trtc setDebugViewMargin:USER_ID margin:UIEdgeInsetsMake(0.2, 0, 0.2 , 0.1)];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [_baseView.backBtn    addTarget:self action:@selector(onClickBack) forControlEvents:UIControlEventTouchUpInside];
    [_baseView.logBtn     addTarget:self action:@selector(onClickLog) forControlEvents:UIControlEventTouchUpInside];
    [_baseView.cameraBtn  addTarget:self action:@selector(onClickCamera) forControlEvents:UIControlEventTouchUpInside];
    
    [[_baseView.backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self onClickBack];
    }];
}

-(void)setDemoTitle:(NSString *)title{
    
    self->_demoTitle = title;
}

-(void)setLogBtnHidden:(BOOL)isHidden{
    
    self.baseView.logBtn.hidden = isHidden;
}

-(void)setTipsHidden:(BOOL)isHidden{
    
    self.baseView.tipsLabel.hidden = isHidden;
}

- (void)onClickBack{
    
}

- (void)onClickCamera{
    
    [_rtcManager switchCamera];
}

- (void)onClickLog{
    
    _showLogType ++;
    if (_showLogType > 2) {
        _showLogType = 0;
    }

    [self.rtcManager showDebugView:_showLogType];
    
}

- (void)toastTip:(NSString *)toastInfo, ... {
   
    va_list args;
    va_start(args, toastInfo);
    NSString *log = [[NSString alloc] initWithFormat:toastInfo arguments:args];
    va_end(args);
    __block UITextView *toastView = [[UITextView alloc] init];
    
    toastView.userInteractionEnabled = NO;
    toastView.scrollEnabled = NO;
    toastView.text = log;
    toastView.backgroundColor = [UIColor whiteColor];
    toastView.alpha = 0.5;

    [_baseView.toastStack addArrangedSubview:toastView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [toastView removeFromSuperview];
    });
}

#pragma mark - TRTCCloud Delegate

-(void)onEnterRoom:(NSInteger)result{
    
    if (result >= 0) {
       [self toastTip:@"进房成功\n"];
       [self toastTip:[NSString stringWithFormat:@"房间号:%d\n",ROOM_ID]];
       [self toastTip:[NSString stringWithFormat:@"用户名:%@\n",USER_ID]];
    } else {
       [self toastTip:@"进房失败\n"];
    }
}

- (void)onExitRoom:(NSInteger)reason{
    
    [self toastTip:[NSString stringWithFormat:@"已退房:%ld\n",(long)reason]];
}

- (void)onRemoteUserEnterRoom:(NSString *)userId{
    
    [self toastTip:[NSString stringWithFormat:@"成员进入:%@\n",userId]];
}

- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason{
    
    [self toastTip:[NSString stringWithFormat:@"成员离开:%@\n",userId]];
}

- (void)onSendFirstLocalAudioFrame:(NSString*)userId{
    
    [self toastTip:[NSString stringWithFormat:@"首帧本地音频数据已经被送出"]];
}

- (void)onSendFirstLocalVideoFrame: (TRTCVideoStreamType)streamType{
    
    [self toastTip:[NSString stringWithFormat:@"首帧本地视频数据已经被送出"]];
}

- (void)onError:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg extInfo:(nullable NSDictionary*)extInfo{
    
    [self toastTip:[NSString stringWithFormat:@"发生严重错误:%@\n",errMsg]];
}

#pragma mark - StatusBarStyle

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
