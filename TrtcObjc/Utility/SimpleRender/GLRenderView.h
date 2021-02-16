//
//  GLRenderView.h
//  TrtcObjc
//
//  Created by kaoji on 2020/8/12.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLRenderView : UILabel
@property(nonatomic,strong) GLKView      *displayView;///画面显示
@property(nonatomic,strong) CIContext    *ciContext;/// 处理图片
@property(nonatomic,strong) EAGLContext  *eaglContext;///openGL ES上下文
@property(nonatomic,assign) CGRect       displayBounds;/// 显示画面的范围

/*
* @param frame 参考TRTCCloudDef.h 描述一帧视频数据的模型
* @note 渲染显示一帧TRTC视频数据
*/
-(void)renderFrame:(TRTCVideoFrame *)frame;

@end

NS_ASSUME_NONNULL_END
