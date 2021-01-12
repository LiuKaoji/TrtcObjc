//
//  AppDelegate.m
//  TrtcObjc
//
//  Created by kaoji on 2020/4/23.
//  Copyright © 2020 kaoji. All rights reserved.
//

#import "AppDelegate.h"
#import "MainTableVC.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MainTableVC alloc] init]];
    [_window makeKeyAndVisible];
    
    return YES;
}

@end
