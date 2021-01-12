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
@property GLKView *videoPreviewView;
@property CIContext *ciContext;
@property EAGLContext *eaglContext;
@property CGRect videoPreviewViewBounds;

//渲染
-(void)renderFrame:(TRTCVideoFrame *)frame;


@end

NS_ASSUME_NONNULL_END
