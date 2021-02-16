//
//  StepItem.h
//  TrtcObjc
//
//  Created by kaoji on 2021/1/5.
//  Copyright © 2021 issuser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StepItem : UIView

typedef void(^StepClourse)(CGFloat value,StepItem *item);

+(instancetype)sliderWithMin:(NSInteger)min Max:(NSInteger)max Title:(NSString *)title Clourse:(StepClourse)handler;


+(instancetype)sliderWithTitle:(NSString *)title Clourse:(StepClourse)handler;

-(void)setValueText:(NSString *)value;

@end



NS_ASSUME_NONNULL_END
