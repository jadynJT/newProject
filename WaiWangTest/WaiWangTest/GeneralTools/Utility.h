//
//  Utility.h
//  LaoBaiXingYaoFang
//
//  Created by admin on 16/4/28.
//  Copyright © 2016年 TW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+ (BOOL)isIPhone4;

+ (BOOL)isIPhone5;

+ (BOOL)isIPhone6;

+ (BOOL)isIPhone6Plus;

+ (NSString *)lanchImageInch:(NSString *)keySize;

//跳转 下个页面
+ (void)gotoNextVC:(UIViewController *)vc fromViewController:(UIViewController *)viewCtr;

//判断字符串为空
+ (BOOL) isBlankString:(NSString *)string;

//网页加载失败处理
- (void)catchError:(NSError *)error webView:(QqcWebView *)webview;

@end
