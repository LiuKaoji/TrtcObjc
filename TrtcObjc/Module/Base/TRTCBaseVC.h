//
//  TRTCBaseVC.h
//  TrtcObjc
//
//  Created by kaoji on 2020/8/22.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTCLocalManager.h"
#import "GenerateTestUserSig.h"

NS_ASSUME_NONNULL_BEGIN

@interface TRTCBaseVC : UIViewController

@property(nonatomic,strong)RTCLocalManager *rtcManager;///TRTC管理类
@property(nonatomic,assign)int showLogType;///仪表盘
-(void)setLogBtnHidden:(BOOL)isHidden;
-(void)setDemoTitle:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
