//
//  Utility.m
//  LaoBaiXingYaoFang
//
//  Created by admin on 16/4/28.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "Utility.h"


@implementation Utility

+ (BOOL)isIPhone4
{
    return CGRectGetHeight([UIScreen mainScreen].bounds) == 480.f;
}

+ (BOOL)isIPhone5
{
    return CGRectGetHeight([UIScreen mainScreen].bounds) == 568.f;
}

+ (BOOL)isIPhone6
{
    return CGRectGetHeight([UIScreen mainScreen].bounds) == 667.f;
}

+ (BOOL)isIPhone6Plus
{
    return CGRectGetHeight([UIScreen mainScreen].bounds) == 736.f;
}

+ (NSString *)lanchImageInch:(NSString *)keySize {
    NSDictionary * dict = @{@"320x480" : @"LaunchImage-700@2x",
                            @"320x568" : @"LaunchImage-700-568h@2x",
                            @"375x667" : @"LaunchImage-800-667h@2x",
                            @"414x736" : @"LaunchImage-800-Portrait-736h@3x",
                            @"375x812" : @"LaunchImage-1100-Portrait-2436h",
                            @"414x896" : @"LaunchImage-1200-Portrait-2688h"};
    
    return dict[keySize];
}

+ (void)gotoNextVC:(UIViewController *)vc fromViewController:(UIViewController *)viewCtr{
    
    [viewCtr.navigationController pushViewController:vc animated:YES];
    
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [viewCtr.navigationItem setBackBarButtonItem:backBtn];
}

+ (BOOL)isBlankString:(NSString *)string {
    
    if (string == nil || string == NULL || [string isEqual:@""]) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    //    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
    //        return YES;
    //    }
    
    return NO;
}


//超时处理
- (void)onTimeOutAction:(QqcWebView *)webview{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url=[[NSBundle mainBundle]URLForResource:@"fail" withExtension:@"html"];
        NSMutableURLRequest *tmpRequest=[[NSMutableURLRequest alloc] initWithURL:url];
        
        if ([webview isKindOfClass:[WKWebView class]]) {
            [(WKWebView *)webview loadRequest:tmpRequest];
        }else if ([webview isKindOfClass:[UIWebView class]]){
            [(UIWebView *)webview loadRequest:tmpRequest];
        }
        
    });
}

//加载失败处理
- (void)catchError:(NSError *)error webView:(QqcWebView *)webview{
    if ([error code] == -999) {
        return;
    }
    
    if (error.code == -22) {
        [self onTimeOutAction:webview];
    }else if (error.code == -1001){
        [self onTimeOutAction:webview];
    }else if (error.code == -1005){
        [self onTimeOutAction:webview];
    }else if (error.code == -1009){
        [self onTimeOutAction:webview];
    }
    
}




@end
