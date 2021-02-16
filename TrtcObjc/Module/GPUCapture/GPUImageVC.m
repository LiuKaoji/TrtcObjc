//
//  GPUImageVC.m
//  TrtcObjc
//
//  Created by kaoji on 2020/8/23.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import "GPUImageVC.h"
#import <GPUImage/GPUImageView.h>
#import "EmbedView.h"
#import "SliderItem.h"

@interface GPUImageVC ()
@property (nonatomic, strong)GPUImageView *previewLayer;
@property (strong, nonatomic)EmbedView *embedView;
@property (nonatomic, strong)DotGPUImageBeautyFilter *filter;
@end

@implementation GPUImageVC

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self startGPUCapture];
}

-(void)startGPUCapture{
    
    _previewLayer = [[GPUImageView alloc] initWithFrame:self.view.frame];
    _previewLayer.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view insertSubview:_previewLayer atIndex:0];
    
    self.filter = [self.rtcManager startCapture:GPUVideoCapture Preview:_previewLayer];
    
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
        _embedView = [EmbedView embedWithTitle:@"美颜滤镜调整" Items:@[
            [SliderItem sliderWithTitle:@"调强度" Clourse:^(CGFloat value, UISlider *item) {
               @strongify(self);
               [self.filter setBeautyLevel:value];
               NSLog(@"[Beauty]-强度:%.1f", value);
            }],
            
            [SliderItem sliderWithTitle:@"调亮度" Clourse:^(CGFloat value, UISlider *item) {
                @strongify(self);
                [self.filter setBrightLevel:value];
                NSLog(@"[Beauty]-亮度:%.1f", value);
            }],
            
            [SliderItem sliderWithTitle:@"调色调" Clourse:^(CGFloat value, UISlider *item) {
                @strongify(self);
                [self.filter setToneLevel:value];
                NSLog(@"[Beauty]-色调%.1f", value);
            }]
        
        ]];
        [self.view addSubview:_embedView];
    }
    
    return _embedView;
}

@end
