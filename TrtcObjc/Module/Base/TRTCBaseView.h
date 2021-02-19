//
//  TRTCBaseView.h
//  TrtcObjc
//
//  Created by kaoji on 2021/1/8.
//  Copyright © 2021 issuser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TRTCBaseView : UIView

@property (nonatomic, strong) UIButton    *backBtn;// 返回

@property (nonatomic, strong) UILabel     *titleLabel;// 标题

@property (nonatomic, strong) UIButton    *cameraBtn;// 切换相机

@property (nonatomic, strong) UIButton    *logBtn; // 仪表盘

@property (nonatomic, strong) UILabel    *tipsLabel; // 操作提示

@property (nonatomic, strong) UIStackView *toastStack; // toast容器

@end

NS_ASSUME_NONNULL_END
