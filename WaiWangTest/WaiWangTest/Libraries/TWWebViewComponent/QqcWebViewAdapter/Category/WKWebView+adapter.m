//
//  WKWebView+adapter.m
//  QqcWebViewAdapter
//
//  Created by qiuqinchuan on 15/9/21.
//  Copyright (c) 2015年 ZQ. All rights reserved.
//

#import <objc/runtime.h>
#import <WebKit/WebKit.h>
#import "WKWebView+adapter.h"

static void (*originalIMP)(id self, SEL _cmd, void* arg0, BOOL arg1, BOOL arg2, id arg3) = NULL;

void interceptIMP (id self, SEL _cmd, void* arg0, BOOL arg1, BOOL arg2, id arg3) {
    originalIMP(self, _cmd, arg0, TRUE, arg2, arg3);
}

@implementation WKWebView (adapter)

#pragma mark - 框架方法
+ (void) load
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(loadRequest:);
        SEL swizzledSelector = @selector(swizzlingLoadRequest:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL bIsDidAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (bIsDidAddMethod)
        {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }
        else
        {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - 属性
/*
 * Getter for the active request. UIWebView has this, but WKWebView does not, so we add it here.
 */
- (NSURLRequest *) request
{
    return objc_getAssociatedObject(self, @selector(request));
}

/*
 * Setter for the active request.
 */
- (void) setRequest: (NSURLRequest *) request
{
    objc_setAssociatedObject(self, @selector(request), request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    [self setNavigationDelegate: delegate];
    [self setUIDelegate: delegate];
}

/*
 * WKWebView  没有这个方法
 * UIWebView  有此方法
 */
- (void) setScalesPageToFit: (BOOL) bIsFit
{
    //WKWebView不支持这个方法
    return;
}

/**
 *  通过字符串 url 加载
 *
 *  @param strUrl url字符串
 */
- (void) loadRequestWithString: (NSString *) strUrl 
{
    [self loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString: strUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20]];
}

#pragma mark - 内部方法
/*
 * 用于 swizzled 实例方法 loadRequest 的方法 （保存request对象）
 * @param request 请求对象
 */
- (void) swizzlingLoadRequest: (NSURLRequest *) request
{
    [self setRequest: request];
    
    [self swizzlingLoadRequest: request];
}

//- (id) reload{
//    return [(WKWebView *)self reload];
//}

/**
 *  显示键盘
 *
 */
//- (void) wkWebViewShowKeybord {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Class cls = NSClassFromString(@"WKContentView");
//        SEL originalSelector = NSSelectorFromString(@"_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:");
//        Method originalMethod = class_getInstanceMethod(cls, originalSelector);
//        IMP impOvverride = (IMP) interceptIMP;
//        originalIMP = (void *)method_getImplementation(originalMethod);
//        method_setImplementation(originalMethod, impOvverride);
//    });
//}

/**
 *  web页面唤起键盘
 *
 */
- (void)allowDisplayingKeyboardWithoutUserAction {
    Class class = NSClassFromString(@"WKContentView");
    NSOperatingSystemVersion iOS_11_3_0 = (NSOperatingSystemVersion){11, 3, 0};
    
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_11_3_0]) {
        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
            ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
        });
        method_setImplementation(method, override);
    } else {
        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, id arg3) {
            ((void (*)(id, SEL, void*, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3);
        });
        method_setImplementation(method, override);
    }
}

@end






