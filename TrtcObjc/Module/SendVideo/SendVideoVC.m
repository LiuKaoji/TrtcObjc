//
//  SendVideoVC.m
//  TrtcObjc
//
//  Created by issuser on 2020/10/20.
//  Copyright © 2020 issuser. All rights reserved.
//

#import "SendVideoVC.h"
#import "TestSendCustomVideoData.h"
#import "TCMediaFileReader.h"
#import "QBImagePickerController.h"
#import "GLRenderView.h"

@interface SendVideoVC()<QBImagePickerControllerDelegate,TRTCVideoRenderDelegate>
@property (strong, nonatomic) TestSendCustomVideoData *videoCaptureTester;//发送音视频数据
@property (strong, nonatomic) AVAsset* customSourceAsset;//从相册选择的视频文件
@property (nonatomic, strong) GLRenderView *glRenderView;//自定义渲染
@end

@implementation SendVideoVC

- (void)viewDidLoad{
    
    [super viewDidLoad];
    [self showMeidaPicker];
}

-(void)setupMVSender{
    
    /// 自定义渲染画面
    _glRenderView = [[GLRenderView alloc] initWithFrame:self.view.frame];
    _glRenderView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view insertSubview:_glRenderView atIndex:0];
    
    /// 告诉SDK自己发送音频和视频
    [self.rtcManager enableCustomVideoCapture:YES];
    [self.rtcManager enableCustomAudioCapture:YES];
    
    /// 初始化发送代理 内部使用TCMediaFileReader进行文件读取
    _videoCaptureTester = [[TestSendCustomVideoData alloc]
                               initWithTRTCCloud:self.rtcManager.trtc
                               mediaAsset:_customSourceAsset];
    /// 从视频里更新帧率
    self.rtcManager.encParam.videoFps = _videoCaptureTester.mediaReader.fps;
    [self.rtcManager setVideoEncoderParam: self.rtcManager.encParam];
    
    /// 开启自定义渲染画面
    [self.rtcManager setLocalVideoRenderDelegate:self pixelFormat:TRTCVideoPixelFormat_NV12 bufferType:TRTCVideoBufferType_PixelBuffer];
    
    /// 开始发送
    [self.videoCaptureTester start];
    
    /// 进入房间
    [self.rtcManager enterRoomUsingDefautParam];
}

#pragma mark - 相册选择
- (void)showMeidaPicker {
    
    QBImagePickerController* imagePicker = [[QBImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsMultipleSelection = NO;
    imagePicker.showsNumberOfSelectedAssets = YES;
    imagePicker.minimumNumberOfSelection = 1;
    imagePicker.maximumNumberOfSelection = 1;
    imagePicker.mediaType = QBImagePickerMediaTypeVideo;
    imagePicker.title = @"选择视频源";

    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - QBImagePickerControllerDelegate
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    PHVideoRequestOptions *options = [PHVideoRequestOptions new];
    // 最高质量的视频
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    // 可从iCloud中获取图片
    options.networkAccessAllowed = YES;
    
    __weak __typeof(self) weakSelf = self;
    [[PHImageManager defaultManager] requestAVAssetForVideo:assets.firstObject options:options resultHandler:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        weakSelf.customSourceAsset = avAsset;
        dispatch_async(dispatch_get_main_queue(), ^{
            @autoreleasepool {
                [weakSelf setupMVSender];

            };
        });
    }];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

-(void)onRenderVideoFrame:(TRTCVideoFrame *)frame userId:(NSString *)userId streamType:(TRTCVideoStreamType)streamType{
    
    /// 自定义渲染画面
    [_glRenderView renderFrame:frame];
 
}

-(void)onClickBack{
    
    /// 页面关闭 退房
    [self.videoCaptureTester stop];
    [self.rtcManager exitRoom];
    [RTCLocalManager destroySharedIntance];
    [self.navigationController popViewControllerAnimated:YES];
}


@end
