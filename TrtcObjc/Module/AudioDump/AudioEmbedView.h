//
//  AudioEmbedView.h
//  TrtcObjc
//
//  Created by kaoji on 2021/1/14.
//  Copyright © 2021 issuser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AudioEmbedView : UIView
@property(nonatomic, copy) dispatch_block_t hideHandle;

+(void)show:(dispatch_block_t)hideHandle;

@end

NS_ASSUME_NONNULL_END
