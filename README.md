# TrtcObjc

## 简介
实时音视频的自采集和渲染,CDN播放[Swift点这里](https://github.com/LiuKaoji/LiteAVSwift)
```none
┌──────────────┐    ┌──────────────┐
│   Capture    ├────▶   filter     │
└───────┬──────┘    └──────┬───────┘
        │                  │        
┌───────▼──────────────────▼───────┐    ┌───────────────────────────┐
│             TRTC                 ├────▶  AudioRawData Dump & Play │
└───────▲──────────────────▲───────┘    └──────-────────────────────┘
        │                  │         
┌───────┴──────┐    ┌──────┴───────┐
│Render/Process│    │     File     │
└──────────────┘    └──────────────┘
```

## 实时音视频
* **[自定义采集](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a76e8101153afc009f374bc2b242c6831)**: 通过采集+滤镜发送给移动直播/实时音视频
```bash
$ TRTCCloud.h:
$ - (void)enableCustomVideoCapture:(BOOL)enable;///开启实时音视频自定义视频采集
$ - (void)sendCustomVideoData:(TRTCVideoFrame *)frame{}///发送TRTCVideoFrame
```

* **[美颜老接口](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#aba3d309645d27304b6d4ea31b21a4cda)**: 实时音视频老版本渲染回调,支持数据回填实现美颜/滤镜 
```bash
$ TRTCCloud.h:
$ setLocalVideoRenderDelegate 
$ -(void)onRenderVideoFrame:(TRTCVideoFrame *)frame userId:(NSString *)userId streamType:(TRTCVideoStreamType)streamType{}
```
* **[美颜新接口](http://doc.qcloudtrtc.com/group__TRTCCloudDelegate__ios.html#protocolTRTCAudioFrameDelegate)**: 实时音视频8.0+数据回调,支持数据回填实现美颜/滤镜,性能更好
```bash
$ TRTCCloud.h:
$ setLocalVideoProcessDelegete 
$ - (uint32_t)onProcessVideoFrame:(TRTCVideoFrame * _Nonnull)srcFrame dstFrame:(TRTCVideoFrame * _Nonnull)dstFrame{}
```

* **[音频回调](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a2f73c33b1010a63bd3a06e639b3cf348)**: 采集与混音裸数据回调,dump pcm数据并进行播放,适用于音频排障
```bash
$ TRTCCloud.h:
$ setAudioFrameDelegate 
$ - (void) onCapturedRawAudioFrame:(TRTCAudioFrame *)frame
$ - (void) onLocalProcessedAudioFrame:(TRTCAudioFrame *)frame	
```

## 安装
```bash
$ pod install
```

## 配置
```bash
$ 填写你的sdkappid和secretKey->GenerateTestUserSig.h
```

## 参考
```bash
实时音视频:https://cloud.tencent.com/document/product/647
```


