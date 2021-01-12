//
//  LUTFilter.h
//  TrtcOjc
//
//  Created by kaoji on 2021/1/5.
//  Copyright © 2021 issuser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CIImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface LUTFilter : NSObject
-(void)nextFilter;
-(void)processTrtcFrame:(TRTCVideoFrame *)srcFrame to:(TRTCVideoFrame *)dstFrame;
@end

NS_ASSUME_NONNULL_END
