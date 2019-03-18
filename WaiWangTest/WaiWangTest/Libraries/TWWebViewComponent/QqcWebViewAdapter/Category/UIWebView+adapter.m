//
//  UIWebView+adapter.m
//  QqcWebViewAdapter
//
//  Created by qiuqinchuan on 15/9/21.
//  Copyright (c) 2015年 ZQ. All rights reserved.
//

#import "UIWebView+adapter.h"

@implementation UIWebView (adapter)

#pragma mark - 属性

/**
 *  UIWebView 中没有此属性，WKWebView 中有此属性
 */
- (NSURL *)URL
{
    return self.request.URL;
}


#pragma mark - 方法

/**
 *  UIWebView 和 WKWebView 有不同的设置delegate的接口，这里做统一
 *  UIWebView 代理是 id <UIWebViewDelegate> delegate
 *  WKWebView 代理是 id <WKNavigationDelegate> navigationDelegate 和 id <WKUIDelegate> UIDelegate
 *  @param delegate id <UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate>
 */
- (void) setDelegateVC: (id) delegate
{
    self.delegate = delegate;
}


/**
 *  通过字符串 url 加载
 *
 *  @param strUrl url字符串
 */
- (void) loadRequestWithString: (NSString *) strUrl
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    //[request setValue:@"qqc_value" forHTTPHeaderField:@"qqc_key"];
    
    [self loadRequest:request];
}

/*
 * UIWebView 使用 stringByEvaluatingJavaScriptFromString
 * WKWebView 使用 evaluateJavaScript
 * 提供统一的接口
 */
- (void) evaluateJavaScript: (NSString *) javaScriptString completionHandler: (void (^)(id, NSError *)) completionHandler
{
    NSString *string = [self stringByEvaluatingJavaScriptFromString: javaScriptString];
    
    if (completionHandler)
    {
        completionHandler(string, nil);
    }
}

//- (id) reload{
//    [(UIWebView *)self reload];
//    return nil;
//}

@end
