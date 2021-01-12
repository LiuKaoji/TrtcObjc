//
//  TRTCBaseVC.m
//  TrtcObjc
//
//  Created by kaoji on 2020/8/22.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import "TRTCBaseVC.h"
#import <GPUImageContext.h>


@interface TRTCBaseVC ()<TRTCCloudDelegate,TRTCLogDelegate>
@property(nonatomic,strong)UIButton *backBtn;
@property(nonatomic,strong)UIButton *titleBtn;
@property(nonatomic,strong)UIButton *cameraBtn;
@property(nonatomic,strong)UIButton *logBtn;
@property(nonatomic,strong)UITextView *logContentView;
@property(nonatomic,assign)int logType;
@end

@implementation TRTCBaseVC

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //公共界面配置
    [self publicUI];
    
    //基本初始化
    _trtc = [TRTCCloud sharedInstance];
    [self setupTRTC];
}

-(void)publicUI{
    
    self.view.userInteractionEnabled = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    _backBtn = [self buttonWithTitle:nil image:@"back" Selector:@selector(onClickBack)];
    _backBtn.frame = CGRectMake(10, STATUS_BAR_HEIGHT, 40, 40);
    [self.view addSubview:_backBtn];
    
    _titleBtn = [self buttonWithTitle:[NSString stringWithFormat:@"%d",ROOM_ID] image:nil Selector:nil];
    _titleBtn.frame = CGRectMake(self.view.frame.size.width/2 - 100, STATUS_BAR_HEIGHT, 200, 40);
    [_titleBtn setTitleColor:rgba(255, 255, 255, 0.8) forState:UIControlStateNormal];
    [self.view addSubview:_titleBtn];
    
    _cameraBtn = [self buttonWithTitle:nil image:@"camera" Selector:@selector(onClickCamera)];
    _cameraBtn.frame = CGRectMake(self.view.frame.size.width - 50, STATUS_BAR_HEIGHT, 40, 40);
    [self.view addSubview:_cameraBtn];
    
    _logBtn = [self buttonWithTitle:nil image:@"log" Selector:@selector(onClickLog)];
    _logBtn.frame = CGRectMake(CGRectGetMinX(_cameraBtn.frame), self.view.frame.size.height - BOTTOM_LAYOUT_GUIDE - 40, 40, 40);
    [self.view addSubview:_logBtn];
    
    _logContentView = [[UITextView alloc] initWithFrame:CGRectMake(10, TOP_LAYOUT_GUIDE, 300, self.view.frame.size.height*0.6)];
    _logContentView.editable = NO;
    _logContentView.backgroundColor = [UIColor clearColor];
    _logContentView.textColor = [UIColor whiteColor];
    _logContentView.font = [UIFont systemFontOfSize:15];
    _logContentView.layoutManager.allowsNonContiguousLayout = NO;
    [self.view addSubview:_logContentView];
}

-(UIButton *)buttonWithTitle:(NSString *)title image:(NSString *)imageName Selector:(SEL)selector{
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)setupTRTC{
    
    //视频
    TRTCVideoEncParam *encParam = [[TRTCVideoEncParam alloc] init];
    encParam.videoResolution = TRTCVideoResolution_640_360;
    encParam.videoFps = 18;
    encParam.videoBitrate = 800;
    encParam.resMode = TRTCVideoResolutionModePortrait;
    self.videoEncParam = encParam;
    
    [_trtc setVideoEncoderParam:encParam];
    [_trtc setLocalViewFillMode:TRTCVideoFillMode_Fill];
    [_trtc setLocalViewMirror:TRTCLocalVideoMirrorType_Auto];
    [_trtc setGSensorMode:TRTCGSensorMode_Disable];
    
    //音频
    //[self setExperimentConfig:@"setAudioSampleRate" params:@{ @"sampleRate": @(48000) }];
    
    
    //流控
    TRTCNetworkQosParam *qosParam = [[TRTCNetworkQosParam alloc] init];
    qosParam.preference = TRTCVideoQosPreferenceClear;
    [_trtc setNetworkQosParam:qosParam];
    
    //TRTC代理
    _trtc.delegate = self;
    
    //日志代理
    [TRTCCloud setLogDelegate:self];
    
}


- (void)setExperimentConfig:(NSString *)key params:(NSDictionary *)params {
    NSDictionary *json = @{
        @"api": key,
        @"params": params
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:NULL];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self.trtc callExperimentalAPI:jsonString];
}

//TRTC进房参数
-(TRTCParams *)roomParam{
    TRTCParams *param = [[TRTCParams alloc] init];
    param.sdkAppId = _SDKAppID;
    param.userId = USER_ID;
    param.roomId = ROOM_ID;
    param.userSig = [GenerateTestUserSig genTestUserSig:param.userId];
    param.privateMapKey = @"";
    param.role = TRTCRoleAnchor;
    return param;
}

-(void)onClickLog{
    _logContentView.hidden = !_logContentView.isHidden;
}

#pragma mark - ControlEvent
-(void)onClickBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onClickCamera{
  //子类继承实现
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)instertLog:(nullable NSString*)log{
   [self.logContentView insertText:log];
   [self.logContentView scrollRangeToVisible:NSMakeRange(self.logContentView.text.length, 1)];
}

#pragma mark - TRTCCloud Delegate
-(void)onEnterRoom:(NSInteger)result{
    if (result >= 0) {
       [self instertLog:@"进房成功\n"];
       [self instertLog:[NSString stringWithFormat:@"房间号:%d\n",ROOM_ID]];
       [self instertLog:[NSString stringWithFormat:@"用户名:%@\n",USER_ID]];
    } else {
       [self instertLog:@"进房失败\n"];
    }
}

- (void)onExitRoom:(NSInteger)reason{
    [self instertLog:[NSString stringWithFormat:@"已退房:%ld\n",(long)reason]];
}

- (void)onRemoteUserEnterRoom:(NSString *)userId{
    [self instertLog:[NSString stringWithFormat:@"成员进入:%@\n",userId]];
}

- (void)onRemoteUserLeaveRoom:(NSString *)userId reason:(NSInteger)reason{
    [self instertLog:[NSString stringWithFormat:@"成员离开:%@\n",userId]];
}

- (void)onSendFirstLocalAudioFrame:(NSString*)userId{
    [self instertLog:[NSString stringWithFormat:@"首帧本地音频数据已经被送出"]];
}

- (void)onSendFirstLocalVideoFrame: (TRTCVideoStreamType)streamType{
    [self instertLog:[NSString stringWithFormat:@"首帧本地视频数据已经被送出"]];
}

- (void)onError:(TXLiteAVError)errCode errMsg:(nullable NSString *)errMsg extInfo:(nullable NSDictionary*)extInfo{
    [self instertLog:[NSString stringWithFormat:@"发生严重错误:%@\n",errMsg]];
//    [self instertLog:[NSString stringWithFormat:@"5秒后页面关闭...\n"]];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.navigationController popViewControllerAnimated:YES];
//    });
}

@end
