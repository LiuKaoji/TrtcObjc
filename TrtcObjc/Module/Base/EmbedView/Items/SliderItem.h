//
//  SliderItem.h
//  TrtcObjc
//
//  Created by kaoji on 2021/1/13.
//  Copyright © 2021 issuser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SliderItem : UIView

typedef void(^SliderClourse)(CGFloat value,UISlider *item);

+(instancetype)sliderWithMin:(NSInteger)min Max:(NSInteger)max Title:(NSString *)title Clourse:(SliderClourse)handler;


+(instancetype)sliderWithTitle:(NSString *)title Clourse:(SliderClourse)handler;

-(void)setValueText:(NSString *)value;


@end

NS_ASSUME_NONNULL_END
