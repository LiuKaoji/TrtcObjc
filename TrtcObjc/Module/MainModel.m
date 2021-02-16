//
//  MainModel.m
//  TrtcObjc
//
//  Created by kaoji on 2021/1/9.
//  Copyright © 2021 issuser. All rights reserved.
//

#import "MainModel.h"

@implementation MainModel

+(instancetype)model:(NSString *)item Detail:(NSString *)detail className:(NSString *)name{
    
    MainModel *model = [[self alloc] init];
    model.item = item;
    model.detail = detail;
    model.className = name;
    
    return model;
}

@end
