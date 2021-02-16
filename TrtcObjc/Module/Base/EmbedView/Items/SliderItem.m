//
//  SliderItem.m
//  TrtcObjc
//
//  Created by kaoji on 2021/1/13.
//  Copyright © 2021 issuser. All rights reserved.
//

#import "SliderItem.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface SliderItem ()

@property(nonatomic, strong)UISlider   *slider;
@property(nonatomic, strong)UILabel    *titleLabel;
@property(nonatomic, strong)UILabel    *valueLabel;
@property(nonatomic,   copy)SliderClourse changeHandler;
@end

@implementation SliderItem
{
    NSString *_title;
    NSInteger _min;
    NSInteger _max;
}

+(instancetype)sliderWithMin:(NSInteger)min Max:(NSInteger)max Title:(NSString *)title Clourse:(SliderClourse)handler{
    
    SliderItem *item = [[self alloc] init];
    item->_title = title;
    item->_min = min;
    item->_max = max;
    item.changeHandler = handler;
    [item setupSlider];
    return item;
}

+(instancetype)sliderWithTitle:(NSString *)title Clourse:(SliderClourse)handler{
    
    SliderItem *item = [[self alloc] init];
    item->_title = title;
    item->_min = 0;
    item->_max = 1;
    item.changeHandler = handler;
    [item setupSlider];
    return item;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        self.layer.cornerRadius = 5;
    }
    return self;
}

- (void)setupSlider{
    
    /// layout
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.2);
    }];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self);
        make.width.equalTo(@30);
    }];
    
   
//    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.titleLabel.mas_right);
//        make.right.equalTo(self.valueLabel.mas_left);
//        make.centerY.equalTo(self.titleLabel.mas_centerY);
//    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _slider.minimumValue = self->_min;
    _slider.maximumValue = self->_max;
    
    CGFloat x = CGRectGetMaxX(self.titleLabel.frame);
    CGFloat w = CGRectGetMinX(self.valueLabel.frame) - x;
    self.slider.frame = CGRectMake(x, 0, w, self.frame.size.height);
   
}

-(void)setValueText:(NSString *)value{
    
    self.valueLabel.text = value;
}

#pragma mark - getter
-(UISlider *)slider{
    
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        [_slider setThumbImage:[UIImage imageNamed:@"selected_dot"] forState:UIControlStateNormal];
        
        _slider.minimumValue = self->_min;
        _slider.maximumValue = self->_max;
      
        @weakify(self);
        [[_slider rac_signalForControlEvents: UIControlEventValueChanged] subscribeNext:^(__kindof UIControl * _Nullable x) {
            
            @strongify(self);
            UISlider *slider = x;
            if(self.changeHandler){
                self.changeHandler(slider.value,(UISlider *)slider);
            }
            self.valueLabel.text = [NSString stringWithFormat:@"%.1f",slider.value];
            
        }];
        [self addSubview:_slider];
    }
    return _slider;
}

-(UILabel *)titleLabel{
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = self->_title;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

-(UILabel *)valueLabel{
    
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.textColor = [UIColor whiteColor];
        _valueLabel.text = @"0";
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:_valueLabel];
    }
    return _valueLabel;
}

@end
