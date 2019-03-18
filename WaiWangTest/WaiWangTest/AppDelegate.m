//
//  AppDelegate.m
//  ModelDemo
//
//  Created by apple on 16/9/9.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "AppDelegate.h"
#import "TWUpdateAppVersion.h"
#import "MainVC.h"

@interface AppDelegate ()

@property (nonatomic, strong) MainVC *mvc;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self showLaunchImage];
    
    if (!iphoneX) {
        [[UIApplication sharedApplication]setStatusBarHidden:YES];
    }
    
    // 全局添加userAgent
    NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    UIWebView * tempWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString * userAgent = [tempWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newUserAgent = [userAgent stringByAppendingString:[NSString stringWithFormat:@" TWAPP:%@/ipa",version]];
    NSLog(@"newUserAgent = %@",newUserAgent);
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

- (void)showLaunchImage{
    self.mvc = [[MainVC alloc]init];
    self.window.rootViewController = self.mvc;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    TWUpdateAppVersion *appVersion = [TWUpdateAppVersion shareInstance];
    
    if (appVersion.appVersionInfo.count == 0) return;
    
    BOOL isUpdate = [appVersion.appVersionInfo[@"isUpdate"] boolValue];
    NSString *storeVersion = appVersion.appVersionInfo[@"storeVersion"];
    NSString *openUrl = appVersion.appVersionInfo[@"openUrl"];
    if (isUpdate) {
        [self.mvc showStoreVersion:storeVersion openUrl:openUrl];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
