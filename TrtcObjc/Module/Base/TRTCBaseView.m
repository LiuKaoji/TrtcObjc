//
//  TRTCBaseView.m
//  TrtcObjc
//
//  Created by kaoji on 2021/1/8.
//  Copyright © 2021 issuser. All rights reserved.
//

#import "TRTCBaseView.h"
#import <Masonry/Masonry.h>

@implementation TRTCBaseView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createBaseView];
    }
    return self;
}

-(void)createBaseView{
    
    self.backgroundColor = [UIColor blackColor];
    self.userInteractionEnabled = YES;
    
    self.titleLabel.text = @"标题";
    _backBtn   = [self createBtnWithImage:@"back"];
    _logBtn    = [self createBtnWithImage:@"log"];
    _cameraBtn = [self createBtnWithImage:@"camera"];
    
    _logBtn.hidden = YES;//默认隐藏 大多数场景都是自定义渲染/采集
    
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.top.equalTo(self).offset(STATUS_BAR_HEIGHT + 2);
        make.size.equalTo(@40);
    }];
    
    [_cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-15));
        make.top.equalTo(self).offset(STATUS_BAR_HEIGHT + 2);
        make.size.equalTo(@40);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_backBtn.mas_right);
        make.right.equalTo(_cameraBtn.mas_left);
        make.top.equalTo(self).offset(STATUS_BAR_HEIGHT + 2);
        make.height.equalTo(@40);
    }];
    
    [self.toastStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.equalTo(self);
        make.bottom.equalTo(self.mas_bottom).offset(-(isBangsDevice ?34:0) - 48);
    }];
    
    [_logBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.size.equalTo(@30);
        make.bottom.equalTo(self.mas_bottom).offset(-(isBangsDevice ?34:0));
    }];
}

#pragma mark - Getter
- (UILabel *)titleLabel{
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview: _titleLabel];
    }
    return _titleLabel;
}

- (UIStackView *)toastStack{
    
    if (!_toastStack) {
        _toastStack = [[UIStackView alloc] init];
        _toastStack.axis = UILayoutConstraintAxisVertical;
        _toastStack.alignment = UIStackViewAlignmentFill;
        _toastStack.distribution = UIStackViewDistributionFill;
        _toastStack.contentMode = UIViewContentModeScaleToFill;
        _toastStack.spacing = 0;
        [self addSubview:_toastStack];
    }
    return _toastStack;
}

-(UIButton *)createBtnWithImage:(NSString *)imageName{
    
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self addSubview:button];
    return button;
}

@end
