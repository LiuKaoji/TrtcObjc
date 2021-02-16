//
//  MainModel.h
//  TrtcObjc
//
//  Created by kaoji on 2021/1/9.
//  Copyright © 2021 issuser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainModel : NSObject
@property(nonatomic, copy) NSString *item;
@property(nonatomic, copy) NSString *detail;
@property(nonatomic, copy) NSString *className;

+(instancetype)model:(NSString *)item Detail:(NSString *)detail className:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
