//
//  DumpFileModel.h
//  TrtcObjc
//
//  Created by kaoji on 2021/2/17.
//  Copyright © 2021 issuser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DumpFileModel : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *path;
@property(nonatomic, copy) NSString *date;
@property(nonatomic, copy) NSString *size;

+ (instancetype)modelWithPath:(NSString *)path Name:(NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
