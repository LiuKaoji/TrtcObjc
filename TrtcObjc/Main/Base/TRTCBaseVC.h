//
//  TRTCBaseVC.h
//  TrtcObjc
//
//  Created by kaoji on 2020/8/22.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TRTCCloud.h>
#import <TRTCCloudDef.h>
#import "GenerateTestUserSig.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCBaseVC : UIViewController
@property(nonatomic,strong)TRTCCloud *trtc;
@property(nonatomic,strong)TRTCVideoEncParam *videoEncParam;
-(TRTCParams *)roomParam;
-(void)setupTRTC;
@end

NS_ASSUME_NONNULL_END
