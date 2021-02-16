//
//  PCMUtils.h
//  TrtcObjc
//
//  Created by kaoji on 2021/2/15.
//  Copyright © 2021 issuser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCMUtils : NSObject
+ (void)pcm2Wav:(NSString *)pcmPath wavPath:(NSString *)wavPath;
@end

NS_ASSUME_NONNULL_END
