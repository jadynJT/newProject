//
//  QqcWebViewAdapter.h
//  QqcWebViewAdapter
//
//  Created by qiuqinchuan on 15/9/21.
//  Copyright (c) 2015年 ZQ. All rights reserved.
//

/**
 *  WKWebView的坑：
 *  1.无法加载本地的html
 *
 */

#ifndef QqcWebViewAdapter_QqcWebViewAdapter_h
#define QqcWebViewAdapter_QqcWebViewAdapter_h

#define QqcWebView UIView<QqcWebViewAdapter>

/**
 *  WKWebView UIWebView 的设配接口
 */
@protocol QqcWebViewAdapter <NSObject>

#pragma mark - 属性
/**
 *  WKWebView 中没有此属性，UIWebView 中有此属性
 */
@property (nonatomic, strong) NSURLRequest* request;

/**
 *  UIWebView 中没有此属性，WKWebView 中有此属性
 */
@property (nonatomic, strong, readonly) NSURL* URL;


#pragma mark - 方法
/**
 *  UIWebView 和 WKWebView 有不同的设置delegate的接口，这里做统一
 *  UIWebView 代理是 id <UIWebViewDelegate> delegate
 *  WKWebView 代理是 id <WKNavigationDelegate> navigationDelegate 和 id <WKUIDelegate> UIDelegate
 *  @param delegate id <UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate>
 */
- (void) setDelegateVC: (id) delegate;

/*
 * UIWebView 使用 stringByEvaluatingJavaScriptFromString
 * WKWebView 使用 evaluateJavaScript
 * 提供统一的接口
 */
- (void) evaluateJavaScript: (NSString *) javaScriptString completionHandler: (void (^)(id, NSError *)) completionHandler;

/*
 * WKWebView  没有这个方法
 * UIWebView  有此方法
 */
- (void) setScalesPageToFit: (BOOL) bIsFit;

/**
 *  通过字符串 url 加载
 *
 *  @param strUrl url字符串
 */
- (void) loadRequestWithString: (NSString *) strUrl;

//- (id)reload;

/**
 *  显示键盘
 *
 */
//- (void)wkWebViewShowKeybord;

- (void)allowDisplayingKeyboardWithoutUserAction;

@end

#endif
