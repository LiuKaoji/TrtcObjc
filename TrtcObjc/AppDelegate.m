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
    
    MainTableVC *mainVC = [[MainTableVC alloc] init];
    _nav = [[UINavigationController alloc] initWithRootViewController:mainVC];
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    _window = [[UIWindow alloc] initWithFrame:screenBounds];
    _window.rootViewController = _nav;
    [_window makeKeyAndVisible];
    
    return YES;
}

@end
