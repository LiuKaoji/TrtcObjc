//
//  EmbedView.m
//  TrtcObjc
//
//  Created by kaoji on 2021/1/12.
//  Copyright © 2021 issuser. All rights reserved.
//

#import "EmbedView.h"
#import <Masonry/Masonry.h>

@interface EmbedView()

@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UIStackView *itemStack;
@property (nonatomic, strong) UIView      *containView;

@end

@implementation EmbedView
{
    NSString *_title;
    NSArray  *_items;
}

+(instancetype)embedWithTitle:(NSString *)title Items:(NSArray *)items{
    
    EmbedView *view = [[self alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view->_title = title;
    view->_items = items;
    [view setupStackItems];
    
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickOutside)];
        [self addGestureRecognizer:closeTap];
    }
    return self;
}

-(void)setupStackItems{
    
    for (UIView *view in self->_items) {
        
        [self.itemStack addArrangedSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_itemStack.mas_left);
            make.width.equalTo(_itemStack.mas_width);
            make.height.equalTo(@44);
        }];
    }
}

-(void)onClickOutside{
    
    [self hide];
}

-(void)layoutSubviews{
    
    CGFloat space = 10;
    CGFloat rowHeght = 44;
    CGFloat containHeight = 48 + _items.count *(space + rowHeght) + (isBangsDevice ?34:10);
    [self.containView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(containHeight));
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.width.equalTo(self.mas_width);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.width.equalTo(self.mas_width);
        make.top.equalTo(@(0));
        make.height.equalTo(@48);
    }];
    
    [self.itemStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(15);
        make.right.equalTo(self.mas_right).offset(-15);
        make.top.equalTo(_titleLabel.mas_bottom).offset(8);
    }];
}


#pragma mark - Getter
-(UILabel *)titleLabel{
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = self->_title;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        [self.containView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UIStackView *)itemStack{
    
    if (!_itemStack) {
        _itemStack = [[UIStackView alloc] init];
        _itemStack.axis = UILayoutConstraintAxisVertical;
        _itemStack.alignment = UIStackViewAlignmentFill;
        _itemStack.distribution = UIStackViewDistributionFill;
        _itemStack.contentMode = UIViewContentModeScaleToFill;
        _itemStack.spacing = 10;
        [self.containView addSubview:_itemStack];
    }
    
    return _itemStack;
}

-(UIView *)containView{
    
    if (!_containView) {
        _containView = [[UIView alloc] init];
        _containView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        [self addSubview:_containView];
    }
    
    return _containView;
}

#pragma mark - Show & Hidde
-(void)show{
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
}

-(void)hide{
    
    [self removeFromSuperview];
}

@end
