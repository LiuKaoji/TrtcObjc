//
//  DumpFileModel.m
//  TrtcObjc
//
//  Created by kaoji on 2021/2/17.
//  Copyright © 2021 issuser. All rights reserved.
//

#import "DumpFileModel.h"

@implementation DumpFileModel

+ (instancetype)modelWithPath:(NSString *)path Name:(NSString *)fileName;{
    
    DumpFileModel *model = [[self alloc] init];
    model.path = [path stringByAppendingPathComponent:fileName];
    model.name = fileName;
    
    NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:model.path error:nil];
    long long fileSize = [[attrs valueForKey:NSFileSize] longLongValue];
    model.size = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleMemory];
    
    model.date = [NSString stringWithFormat:@"%@",[attrs objectForKey: NSFileCreationDate]];
    
    return model;
}

@end
