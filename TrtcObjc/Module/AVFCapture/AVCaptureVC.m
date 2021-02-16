//
//  AVCaptureVC.m
//  TrtcObjc
//
//  Created by kaoji on 2021/1/4.
//  Copyright © 2021 issuser. All rights reserved.
//

#import "AVCaptureVC.h"
#import <ReactiveObjC.h>
#import "RTCLocalManager.h"
#import "EmbedView.h"
#import "StepItem.h"
#import "SliderItem.h"
#import "AVFDevice.h"

@interface AVCaptureVC ()

@property (strong, nonatomic) EmbedView *embedView;
@property (assign, nonatomic) BOOL isDisplay;
@property (assign, nonatomic) AVFCamera *camera;
@end

@implementation AVCaptureVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self startAVFCapture];
   
}

-(void)startAVFCapture{
    
    /// 承载预览画面
    CALayer *layer  = [[CALayer alloc] init];
    layer.frame = self.view.frame;
    [self.view.layer insertSublayer:layer atIndex:0];
    
     /// rtc
    _camera = [self.rtcManager startCapture:AVFVideoCapture Preview:layer];
    
    /// 视频编码
    [self.rtcManager setEncParam:self.rtcManager.encParam];
    
    /// 进房
    [self.rtcManager enterRoomUsingDefautParam];
    
}

#pragma mark - 父类重写
-(void)onClickBack{
    
    [self.rtcManager exitRoom];
    [self.rtcManager stopCapture];
    [RTCLocalManager destroySharedIntance];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
   
    [self.embedView show];
}

-(EmbedView *)embedView{
    
    if (!_embedView) {
        @weakify(self);
        _embedView = [EmbedView embedWithTitle:@"摄像头参数调整" Items:@[
            [StepItem sliderWithTitle:@"调曝光" Clourse:^(CGFloat value, StepItem *item) {
               @strongify(self);
               [AVFDevice setISO:value atDevice:self.camera.videoDevice];/// AVFDevice setEV 封装了5档
               NSLog(@"[AVDevice]-曝光:%.0f", value);
            }],
            
            [StepItem sliderWithTitle:@"白平衡" Clourse:^(CGFloat value, StepItem *item) {
                @strongify(self);
                [AVFDevice setWhiteBalance:value atDevice:self.camera.videoDevice];/// AVFDevice setWhiteBalance 封装了5档
                NSLog(@"[AVDevice]-白平衡:%.0f", value);
            }],
            
            [StepItem sliderWithTitle:@"调焦距" Clourse:^(CGFloat value, StepItem *item) {
                @strongify(self);
                NSInteger zoomValue = value + 1;/// zoom是(1...videoDevice.activeFormat.videoMaxZoomFactor) 不能为0 
                [AVFDevice setZoom:zoomValue atDevice:self.camera.videoDevice];/// zoom 1...5
                NSLog(@"[AVDevice]-焦距:%zd", zoomValue);
            }],
            
            [StepItem sliderWithTitle:@"调帧率" Clourse:^(CGFloat value, StepItem *item) {
                @strongify(self);
                [AVFDevice setFps:value + 15 atDevice:self.camera.videoDevice];/// fps 15 + (0...5)
                NSLog(@"帧率:%.0f", value + 15);
            }]
        
        ]];
        [self.view addSubview:_embedView];
    }
    
    return _embedView;
}

@end
