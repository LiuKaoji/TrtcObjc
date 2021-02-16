//
//  EmbedView.h
//  TrtcObjc
//
//  Created by kaoji on 2021/1/12.
//  Copyright © 2021 issuser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmbedView : UIView

+(instancetype)embedWithTitle:(NSString *)title Items:(NSArray *)items;

-(void)show;

-(void)hide;

@end

NS_ASSUME_NONNULL_END
