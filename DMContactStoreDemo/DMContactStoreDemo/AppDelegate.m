//
//  AppDelegate.m
//  DMContactStoreDemo
//
//  Created by 李二狗 on 2017/6/29.
//  Copyright © 2017年 YRHY Science and Technology (Beijing) Co., Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "UIImage+dm_image.h"
#import "UIColor+dm_color.h"
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UINavigationBar *navBar = [UINavigationBar appearance];
    // 1.2.设置导航栏背景
    UIColor *firstColor = [UIColor dm_colorWithHex:0x369aff];
    UIColor *lastColor = [UIColor dm_colorWithHex:0x39d7fc];
    [navBar setBackgroundImage:[UIImage dm_getImageFromColors:@[firstColor,lastColor] withFrame:CGRectMake(0, 0,kScreenWidth,64)] forBarMetrics:UIBarMetricsDefault];
    // 1.3.设置导航栏的文字
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
