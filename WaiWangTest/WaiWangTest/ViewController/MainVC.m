//
//  MainVC.m
//  YueYaoWang
//
//  Created by apple on 16/1/20.
//  Copyright © 2016年 TW. All rights reserved.
//

#import "MainVC.h"
#import "ACETelPrompt.h"
#import "GradualProgressView.h"
#import "TWUpdateAppVersion.h"
#import "NSString+Utils.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "TWBaseNavigationController.h"
#import "LinkSkipViewController.h"
#import "TopView.h"
#import "Masonry.h"
#import "iPhoneInfo.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

@interface MainVC ()<UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate,UIAlertViewDelegate,QRCodeReaderDelegate>

@property (nonatomic, strong) QqcWebView* webView;
@property (nonatomic, strong) QqcWebViewJavascriptBridge bridge;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) NSUInteger loadCount;
@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic,   copy) NSString *userAgent;
@property (nonatomic,   copy) NSString *hostName;
@property (nonatomic,   copy) NSString *QRCodeRdsult;

@property (nonatomic, strong) GradualProgressView *bgGProgressView;
@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) UIButton *countdownBtn;    // 倒计时按钮
@property (nonatomic, strong) NSTimer *timer;            // 计时器
@property (nonatomic, assign) NSInteger count;           // 倒计时数
@property (nonatomic, assign) BOOL isFirstLoad;          // 是否第一次加载

@property (nonatomic, assign) BOOL isDispalyTopView;     // 是否显示顶部视图（假导航栏）
@property (nonatomic, assign) BOOL isReloadCart;         // 是否刷新采购车

@property (nonatomic, strong) QRCodeReaderViewController *reader;
@property (nonatomic, strong) TopView *topView;

@end

@implementation MainVC

/** 传入控制器、url、标题 */
+ (void)showWithContro:(UIViewController *)contro{
    MainVC *vc=[MainVC new];
    UIWindow *window=[[[UIApplication sharedApplication]delegate]window];
    window.rootViewController=vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //进度条
    [self setProgress];
    //加载webview
    [self setWebView];
    //标识符
//    [self setUserAgent];
    
    [self regJSApi];
    
    NSLog(@"新分支");
    
    NSLog(@"卡的一比");
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.backgroundColor = [UIColor redColor];
//    [button setTitle:@"授权" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(getAuthor:) forControlEvents:0];
//    button.frame = CGRectMake(10, 10, 100, 100);
//    [self.view addSubview:button];
    
}

#pragma mark - 初始化
- (UIButton *)dismissButton {
    if (!_dismissButton) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        _dismissButton.backgroundColor = [UIColor redColor];
        [_dismissButton addTarget:self action:@selector(dismissButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dismissButton;
}

- (QqcWebView *)webView
{
    if (nil == _webView) {
        if (NSClassFromString(@"WKWebView")) {
            if (iphoneX) {
                _webView = (QqcWebView*)[[WKWebView alloc] initWithFrame:CGRectMake(0, 44, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height-44-34)];
            }else {
                _webView = (QqcWebView*)[[WKWebView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height)];
            }
            
            if (@available(iOS 11.0, *))
            {//  防止无导航栏时顶部出现44高度的空白 (适配iPhone X)
                ((WKWebView *)_webView).scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
            
            [_webView allowDisplayingKeyboardWithoutUserAction]; // 唤起键盘
//            [_webView wkWebViewShowKeybord];
        }
        else {
            _webView = (QqcWebView*)[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height)];
        }
        
        [self.view insertSubview:_webView belowSubview:_progressView];
    }
    
    return _webView;
}

- (id)bridge
{
    if (nil == _bridge) {
        
        WVJBHandler handle = ^(id data, WVJBResponseCallback responseCallback) {
            responseCallback(@"我是天网原生");
        };
        
        if ([self.webView isKindOfClass:[UIWebView class]])
        {
            //            _bridge = [WebViewJavascriptBridge bridgeForWebView:(UIWebView*)self.webView webViewDelegate:self handler:handle resourceBundle:nil];
            _bridge = [WebViewJavascriptBridge bridgeForWebView:(UIWebView*)self.webView];
            [(WebViewJavascriptBridge *)_bridge setWebViewDelegate:self];
        }
        else if ([self.webView isKindOfClass:[WKWebView class]])
        {
            //            _bridge = [WKWebViewJavascriptBridge bridgeForWebView:(WKWebView*)self.webView webViewDelegate:self handler:handle resourceBundle:nil];
            _bridge = [WKWebViewJavascriptBridge bridgeForWebView:(WKWebView*)self.webView];
            [(WebViewJavascriptBridge *)_bridge setWebViewDelegate:self];
        }
    }
    
    return _bridge;
}

- (TopView *)topView {
    if (!_topView) {
        CGFloat marginY = 0;
        if (iphoneX) marginY = 44;
        
        self.topView = [[TopView alloc] initWithFrame:CGRectMake(0, marginY, Screen_width, 44)];
        self.topView.backgroundColor = [UIColor whiteColor];
        self.topView.hidden = YES;
        
        __weak typeof(self) weakself = self;
        self.topView.returnBlock = ^{
            if (NSClassFromString(@"WKWebView")) {
                if ([((WKWebView *)weakself.webView) canGoBack]) {
                    [((WKWebView *)weakself.webView) goBack];
                }
            }else {
                if ([((UIWebView *)weakself.webView) canGoBack]) {
                    [((UIWebView *)weakself.webView) goBack];
                }
            }
        };
    }
    return _topView;
}

#pragma mark - 注册JS接口
- (void)regJSApi
{
    WVJBHandler scannerhandle = ^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%s 扫码被触发", __FUNCTION__);
        //调用扫码方法
        [self scannerClick];
        if ([_webView isKindOfClass:[UIWebView class]]) {
            [(UIWebView *)_webView reload];
        }else if([_webView isKindOfClass:[WKWebView class]]){
            [(WKWebView *)_webView reload];
        }
    };
    
    WVJBHandler uuidhandle = ^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%s 获取UUID", __FUNCTION__);
        //获取UUID
        NSString *UUID = [iPhoneInfo getUUID];
        responseCallback(UUID);
    };
    
    
    if ([self.bridge isKindOfClass:[WebViewJavascriptBridge class]])
    {
        [(WebViewJavascriptBridge*)self.bridge registerHandler:@"scancode" handler:scannerhandle];
        [(WebViewJavascriptBridge*)self.bridge registerHandler:@"UUID" handler:uuidhandle];
    }else if ([self.bridge isKindOfClass:[WKWebViewJavascriptBridge class]]){
        [(WKWebViewJavascriptBridge*)self.bridge registerHandler:@"scancode" handler:scannerhandle];
        [(WKWebViewJavascriptBridge*)self.bridge registerHandler:@"UUID" handler:uuidhandle];
    }
}

#pragma mark - 禁止长按手势
- (WKWebViewConfiguration *)banLongPress
{
    // 禁止选择CSS
    NSString*css = @"body{-webkit-user-select:none;-webkit-user-drag:none;}";
    //css 选中样式取消
    NSMutableString*javascript = [NSMutableString string];
    [javascript appendString:@"var style = document.createElement('style');"];
    [javascript appendString:@"style.type = 'text/css';"];
    [javascript appendFormat:@"var cssContent = document.createTextNode('%@');", css];
    [javascript appendString:@"style.appendChild(cssContent);"];
    [javascript appendString:@"document.body.appendChild(style);"];
    [javascript appendString:@"document.documentElement.style.webkitUserSelect='none';"];   // 禁止选择
    [javascript appendString:@"document.documentElement.style.webkitTouchCallout='none';"]; // 禁止长按
    
    // javascript注入
    WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addUserScript:noneSelectScript];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;
    
    return configuration;
}

#pragma mark -- configMethod

- (void)setWebView {
    [self configBgView];
    
    [self.webView loadRequestWithString:WEB_URL];
    [_webView setScalesPageToFit:NO];
    _webView.backgroundColor=[UIColor clearColor];
    self.webView.opaque=NO;
    
    [self.view addSubview:self.topView]; // 设置顶部视图
}

//- (void)setUserAgent {
//    if ([self.userAgent rangeOfString:@"TWAPP"].location!=NSNotFound) {
//        
//        NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
//        
//        if ([self.webView isKindOfClass:[UIWebView class]]) {
//            UIWebView *webview = [[UIWebView alloc]initWithFrame:CGRectZero];
//            [webview evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
//                NSString *userAgent = result;
//                
//                NSString *newUserAgent = [userAgent stringByAppendingString:[NSString stringWithFormat:@" TWAPP:%@/ipa",version]];
//                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
//                [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
//            }];
//            
//        }else if ([self.webView isKindOfClass:[WKWebView class]]){
//            [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
//                NSString *userAgent = result;
//                
//                NSString *newUserAgent = [userAgent stringByAppendingString:[NSString stringWithFormat:@" TWAPP:%@/ipa",version]];
//                
//                if([_webView isKindOfClass:[WKWebView class]])  {
//                    [self.webView setValue:newUserAgent forKey:@"applicationNameForUserAgent"];
//                }
//            }];
//        }
//    }
//}

#pragma mark ----配置背景图片
- (void)configBgView {
    self.bgImgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height)];
    
    NSString * key = [NSString stringWithFormat:@"%dx%d", (int)Screen_width, (int)Screen_height];
    
    if (IS_SCREEN_61_INCH && [key isEqualToString:@"414x896"]) { // 为iPhoneXR
        self.bgImgView.image = [UIImage imageNamed:@"LaunchImage-1200-Portrait-1792h"];
    }else {
        self.bgImgView.image = [UIImage imageNamed:[Utility lanchImageInch:key]];
    }
    
//    if ([Utility isIPhone6Plus]) {
//        self.bgImgView.image=[UIImage imageNamed:@"LaunchImage-800-Portrait-736h@3x"];
//    }else if ([Utility isIPhone6]){
//        self.bgImgView.image=[UIImage imageNamed:@"LaunchImage-800-667h@2x"];
//    }else if ([Utility isIPhone5]){
//        self.bgImgView.image=[UIImage imageNamed:@"LaunchImage-700-568h@2x"];
//    }else{
//        self.bgImgView.image=[UIImage imageNamed:@"LaunchImage-700@2x"];
//    }
    
    self.bgImgView.userInteractionEnabled = YES;
    [self.view addSubview:self.bgImgView];
    
    // 添加立即开始按钮
//    [self.bgImgView addSubview:self.dismissButton];
//    [self.dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(@0);
//        make.height.equalTo(@(self.bgImgView.frame.size.height*0.16));
//        make.bottom.equalTo(self.bgImgView).offset(0);
//    }];

    [self congigBgCountDownBtn]; // 倒计时按钮
    //    [self configBgGProgress];
    self.count = 5; // 监听通知
    [self timer]; // 启动计时器
}

- (void)setProgress{
    // 进度条
    CGFloat topMargin = 0;
    if (iphoneX) topMargin = 44;
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, topMargin, Screen_width, 0)];
    progressView.tintColor = [UIColor orangeColor];
    progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:progressView];
    self.progressView = progressView;
}

#pragma mark ----计时器
- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

#pragma mark - 倒计时通知回调
- (void)timerAction
{
    --self.count;
    if (self.count < 1)
    {
        [self hiddenSkipBtn];
    }else
    {
        [self.countdownBtn setTitle:[NSString stringWithFormat:@"跳过%ld",(long)self.count] forState:0];
    }
}

// 倒计时按钮
- (void)congigBgCountDownBtn
{
    CGFloat topOrigin = 25;
    if (iphoneX) topOrigin = 35;
    self.countdownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.countdownBtn.frame = CGRectMake(Screen_width-60-20, topOrigin, 60, 30);
    self.countdownBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self.countdownBtn setTitleColor:[UIColor whiteColor] forState:0];
    self.countdownBtn.layer.cornerRadius = 5.0;
    self.countdownBtn.layer.masksToBounds = YES;
    [self.countdownBtn setTitle:@"跳过5" forState:0];
    self.countdownBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.bgImgView addSubview:self.countdownBtn];
    [self.countdownBtn addTarget:self action:@selector(hiddenSkipBtn) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configBgGProgress{
    GradualProgressView *bgGProgressView = [[GradualProgressView alloc] initWithFrame:CGRectMake(UISCREEN_BOUNCES.size.width/4, UISCREEN_BOUNCES.size.height/[HRIGHT_PROGRESS floatValue], UISCREEN_BOUNCES.size.width/2.0, 1.0)];
    bgGProgressView.layer.masksToBounds = YES;
    bgGProgressView.layer.cornerRadius = 0.5;
    
    [self.bgImgView addSubview:bgGProgressView];
    self.bgGProgressView = bgGProgressView;
    [bgGProgressView startAnimating];
    [self simulateProgress];
}

- (void)simulateProgress {
    dispatch_after(0, dispatch_get_main_queue(), ^(void){
        
        CGFloat increment = (arc4random() % 5) / 10.0f + 0.1;
        CGFloat progress  = [_bgGProgressView progress] + increment;
        [_bgGProgressView setProgress:progress];
        if (progress < 1.0) {
            
            [self simulateProgress];
        }
    });
}

#pragma mark--webViewDelegate
// 计算webView进度条
- (void)setLoadCount:(NSUInteger)loadCount {
    _loadCount = loadCount;
    if (loadCount == 0) {
        self.progressView.hidden = YES;
        [self.progressView setProgress:0 animated:NO];
    }else {
        self.progressView.hidden = NO;
        CGFloat oldP = self.progressView.progress;
        CGFloat newP = (1.0 - oldP) / (loadCount + 1) + oldP;
        if (newP > 0.95) {
            newP = 0.95;
        }
        [self.progressView setProgress:newP animated:YES];
    }
}

// 隐藏跳过按钮
- (void)hiddenSkipBtn {
    [_timer invalidate];
    _timer = nil;
    self.countdownBtn.hidden = YES;
    
    if (self.isFirstLoad)
    {// 加载结束
        [self loadFinishAnimation]; // 加载结束动画
    }
}

// 加载结束动画以及检测版本更新
- (void)loadFinishAnimation
{
    // 蒙版做动画操作
    [UIView animateWithDuration:1.0 animations:^{
        self.bgImgView.alpha = 0;
    } completion:^(BOOL finished){
        [self.bgImgView removeFromSuperview];
    }];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self hsUpdateApp]; // 检测app版本更新
    });
}

#pragma mark - UIWebView Delegate Methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *hostname = request.URL.absoluteString;
    NSString *urlString = [hostname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.hostName = hostname;
    
    // 调起微信支付时，将先前网页地址设置成app的标识，即不会跳回浏览器中
    if ([urlString containsString:@"wx.tenpay.com"])
    {// 判断是否有mweb_url微信支付跳转链接
        NSDictionary *headers = [request allHTTPHeaderFields];
        NSLog(@"headers = %@",headers);
        NSString *referer = [headers valueForKey:@"Referer"];
        if ([referer containsString:[NSString stringWithFormat:@"%@://",URL_DOMAIN_NAME]]) {
        } else {
            // relaunch with a modified request
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSURL *url = [request URL];
                    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                    //设置Referer为app的标识(即来路地址)
                    [request setHTTPMethod:@"GET"];
                    [request setValue:[NSString stringWithFormat:@"%@://",URL_DOMAIN_NAME] forHTTPHeaderField:@"Referer"];
                    [(UIWebView*)(self.webView) loadRequest:request];
                });
            });
            return NO;
        }
    }
    
    if (![urlString hasPrefix:@"http"]) { // 不包含http或https协议，为其他协议
        NSLog(@"urlStringsd = %@",urlString);
        
        NSDictionary *bundleDic = [[NSBundle mainBundle] infoDictionary];
        NSArray *schemes = [bundleDic objectForKey:@"LSApplicationQueriesSchemes"];
        
        NSString *scheme = request.URL.scheme; // 获取当前链接协议
        if ([schemes containsObject:scheme])
        {// 判断当前链接协议是否在设置的白名单中
            if ([[UIApplication sharedApplication] canOpenURL:request.URL])
            {// 跳转成功
                if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)])
                {
                    [[UIApplication sharedApplication] openURL:request.URL options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO} completionHandler:^(BOOL success) {}];
                }
                else
                {
                    [[UIApplication sharedApplication] openURL:request.URL];
                }
            }else
            {// 跳转失败
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                               message:@"未检测到应用，请安装后重试"
                                                              delegate:nil
                                                     cancelButtonTitle:@"确定"
                                                     otherButtonTitles:nil];
                [alert show];
            }
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    self.loadCount++;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.loadCount--;
    
    Utility *utility = [[Utility alloc]init];
    [utility catchError:error webView:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.loadCount--;
    self.view.backgroundColor=[UIColor whiteColor];
    
    if (_timer == nil && !self.isFirstLoad) {
        [self removeBgimageView]; // 移除背景图
    }
    
    if (!self.isFirstLoad) {
        self.isFirstLoad = YES;   // 首次加载
    }
    
    [self setWebViewReturnView:webView]; // 设置webview是否显示返回按钮视图
}

#pragma mark - WKWebView Delegate Methods
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSString *hostname = navigationAction.request.URL.absoluteString.lowercaseString;
    self.hostName = hostname;
    
    NSLog(@"urlString = %@",hostname);
    
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated
        && [hostname containsString:@"tel:"]) {
        // 对于跨域，需要手动跳转
        NSString *str = navigationAction.request.URL.absoluteString;
        NSString *telStr = [str substringFromIndex:4];
        
        [ACETelPrompt callPhoneNumber:telStr call:nil cancel:nil];
        // 不允许web内跳转
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }else {
        NSString *urlString = [hostname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // 调起微信支付时，将先前网页地址设置成app的标识，即不会跳回浏览器中
        if ([urlString containsString:@"wx.tenpay.com"])
        {// 判断是否有mweb_url微信支付跳转链接
            NSDictionary *headers = [navigationAction.request allHTTPHeaderFields];
            NSLog(@"headers = %@",headers);
            NSString *referer = [headers valueForKey:@"Referer"];
            if ([referer containsString:[NSString stringWithFormat:@"%@://",URL_DOMAIN_NAME]]) {
            } else {
                // relaunch with a modified request
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSURL *url = [navigationAction.request URL];
                        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
                        //设置Referer为app的标识(即来路地址)
                        [request setHTTPMethod:@"GET"];
                        [request setValue:[NSString stringWithFormat:@"%@://",URL_DOMAIN_NAME] forHTTPHeaderField:@"Referer"];
                        [(WKWebView*)(self.webView) loadRequest:request];
                    });
                });
            }
        }
        
        if (![urlString hasPrefix:@"http"]) { // 不包含http或https协议，为其他协议
            NSLog(@"urlStringsd = %@",urlString);
            
            NSDictionary *bundleDic = [[NSBundle mainBundle] infoDictionary];
            NSArray *schemes = [bundleDic objectForKey:@"LSApplicationQueriesSchemes"];
            
            NSString *scheme = navigationAction.request.URL.scheme; // 获取当前链接协议
            if ([schemes containsObject:scheme])
            {// 判断当前链接协议是否在设置的白名单中
                if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL])
                {// 跳转成功
                    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)])
                    {
                        [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO} completionHandler:^(BOOL success) {}];
                    }
                    else
                    {
                        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
                    }
                }else
                {// 跳转失败
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                                   message:@"未检测到应用，请安装后重试"
                                                                  delegate:nil
                                                         cancelButtonTitle:@"确定"
                                                         otherButtonTitles:nil];
                    [alert show];
                }
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }else if([urlString containsString:@"itunes.apple.com"]) { // 跳转到App Store
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge completionHandler:(nonnull void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    self.loadCount++;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    self.loadCount--;
    if (_timer == nil && !self.isFirstLoad) {
        [self removeBgimageView]; // 移除背景图
    }
    
    if (!self.isFirstLoad) {
        self.isFirstLoad = YES;   // 首次加载
    }
    
    [self setWebViewReturnView:webView]; // 设置webview是否显示返回按钮视图
}

//开始加载数据时失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    self.loadCount--;
    Utility *utility = [[Utility alloc]init];
    [utility catchError:error webView:webView];
    
    //    if (_timer == nil && !self.isFirstLoad) {
    //        [self removeBgimageView]; // 移除背景图
    //    }
    //
    //    if (!self.isFirstLoad) {
    //        self.isFirstLoad = YES;   // 首次加载
    //    }
    
}

//当main frame最后下载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    self.loadCount--;
    
    Utility *utility = [[Utility alloc]init];
    [utility catchError:error webView:webView];
}

//当web content处理完成时，会回调
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    NSLog(@"进程阻塞");
}

#pragma mark--设置webview是否显示顶部返回视图（用于某些页面无法返回）
- (void)setWebViewReturnView:(id)webView {
    
    NSLog(@"self.hostname = %@",self.hostName);
    
    if (![self.hostName hasPrefix:@"file"] &&
        (![self.hostName containsString:@"http"] ||
         ![self.hostName containsString:URL_DOMAIN_NAME] ||
         [self.hostName containsString:@"tscenter.alipay.com"] ||
         [self.hostName containsString:@"mclient.alipay.com"])) {
            self.topView.hidden = NO;
            self.isDispalyTopView = YES;
            
            self.webView.frame = CGRectMake(0, TopBarSafeHeight+self.topView.frame.size.height, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height-TopBarSafeHeight-BottomSafeHeight-self.topView.frame.size.height);
            
        }else {
            self.topView.hidden = YES;
            
            if (self.isDispalyTopView) {
                self.webView.frame = CGRectMake(0, TopBarSafeHeight, UISCREEN_BOUNCES.size.width, UISCREEN_BOUNCES.size.height-TopBarSafeHeight-BottomSafeHeight);
                
                self.isDispalyTopView = NO;
            }
        }
    
#pragma mark --- 暂时用于医药公司app
//    if ([self.hostName containsString:@"tscenter.alipay.com"] || [self.hostName containsString:@"mclient.alipay.com"])
//    {// 为支付宝页面时
//        self.isReloadCart = YES; // 设置刷新采购车
//    }
//
//    if ([self.hostName containsString:[NSString stringWithFormat:@"%@/order/success",URL_DOMAIN_NAME]])
//    {// 为采购车页面时
//        if (self.isReloadCart) {
//            if ([webView isKindOfClass:[WKWebView class]]) {
//                [(WKWebView *)webView reload]; // 手动刷新采购车
//            }else {
//                [(UIWebView *)webView reload]; // 手动刷新采购车
//            }
//            self.isReloadCart = NO;
//        }
//    }
}

#pragma mark--scannerClick
- (void)scannerClick{
    static QRCodeReaderViewController *reader = nil;
    static TWBaseNavigationController *nav = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        reader = [QRCodeReaderViewController new];
        reader.modalPresentationStyle = UIModalPresentationFormSheet;
        nav = [[TWBaseNavigationController alloc] initWithRootViewController:reader];
        reader.fd_prefersNavigationBarHidden = YES; //隐藏导航栏
    });
    reader.delegate = self;
    
    [reader setCompletionWithBlock:^(NSString *resultAsString) {
        NSLog(@"Completion with result: %@", resultAsString);
    }];
    
    self.reader = reader;
    
    [self presentViewController:nav animated:YES completion:^{
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:nil message:@"请在iPhone的“设置-隐私-相机”选项中，允许此APP访问你的相机" delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
            [alert show];
            return;
        }
    }];
}

#pragma mark --Action
- (void)dismissButtonTapped:(UIButton *)sender {
    [self removeBgimageView];
}

//移除背景图
- (void)removeBgimageView{
    //    [_bgImgView removeFromSuperview];
    //    [_bgGProgressView stopAnimating];
    
    [self loadFinishAnimation]; // 加载结束动画
}

#pragma mark ----检测app版本更新
- (void)hsUpdateApp
{
    __weak __typeof(&*self)weakSelf = self;
    [TWUpdateAppVersion hs_updateWithAPPID:APP_ID block:^(NSString *currentVersion, NSString *storeVersion, NSString *openUrl, BOOL isUpdate) {
        if (isUpdate == YES) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showStoreVersion:storeVersion openUrl:openUrl];
            });
        }
    }];
}

- (void)showStoreVersion:(NSString *)storeVersion openUrl:(NSString *)openUrl
{
    UIAlertController *alertConteoller = [UIAlertController alertControllerWithTitle:@"升级提示" message:[NSString stringWithFormat:@"发现最新版本(%@) ",storeVersion] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:openUrl];
        [[UIApplication sharedApplication] openURL:url];
    }];
    [actionYes setValue:[UIColor redColor] forKey:@"_titleTextColor"]; // 设置字体颜色
    [alertConteoller addAction:actionYes];
    [self presentViewController:alertConteoller animated:YES completion:nil];
//    UIAlertController *alercConteoller = [UIAlertController alertControllerWithTitle:@"版本有更新" message:[NSString stringWithFormat:@"检测到新版本(%@),是否更新?",storeVersion] preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        NSURL *url = [NSURL URLWithString:openUrl];
//        [[UIApplication sharedApplication] openURL:url];
//    }];
//    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//    }];
//    [alercConteoller addAction:actionYes];
//    [alercConteoller addAction:actionNo];
//    [self presentViewController:alercConteoller animated:YES completion:nil];
}

#pragma mark - QRCodeReaderDelegate
- (void)reader:(QRCodeReaderViewController *)reader didScanResult:(NSString *)result{
    [self QRCodeResult:result];
    
    //    [self dismissViewControllerAnimated:YES completion:^{
    //        if ([result isUrlString]) {// 为链接网址
    //            [self.webView loadRequestWithString:result];
    //        }else {
    //            NSString *urlStr = [NSString stringWithFormat:@"%@/xcode/decode?code=%@",WEB_URL,result];
    //            [self.webView loadRequestWithString:urlStr];
    //        }
    //    }];
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)reader:(QRCodeReaderViewController *)reader didImgPickerResult:(NSString *)result{
    [self QRCodeResult:result];
}

#pragma mark ----二维码/条形码识别结果
- (void)QRCodeResult:(NSString *)result {
    if ([result isUrlString]) {// 为链接网址
        if ([result containsString:URL_DOMAIN_NAME] && ![result containsString:@"appdown.html"]) {// 同一域名下直接跳转
            [self dismissViewControllerAnimated:YES completion:^{
                [self.webView loadRequestWithString:result];
            }];
        }else {// 不同域名做另外处理
            if (![self.QRCodeRdsult isEqualToString:result]) {// 保证每次扫码时只执行一次
                
                NSURL *url = [NSURL URLWithString:result];
                NSString *urlStr = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@://",url.scheme] withString:@""];
                
                if ([url.scheme containsString:@"http"]) {
                    [NSString alert:@"安全警告" tip:[NSString stringWithFormat:@"该链接将跳转到外部页面，可能存在风险\n%@",urlStr] cancelBtnTitle:@"取消" otherBtnTitle:@"打开链接" confirmBLock:^{
                        self.QRCodeRdsult = @"";
                        if ([[UIApplication sharedApplication] canOpenURL:url])
                        {// 跳转成功
                            if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)])
                            {
                                [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO} completionHandler:^(BOOL success) {}];
                            }
                            else
                            {
                                [[UIApplication sharedApplication] openURL:url];
                            }
                        }
                    } cancelBlock:^{
                        self.QRCodeRdsult = @"";
                    }];
                }else {
                    [NSString alert:@"二维码内容" tip:result cancelBtnTitle:nil otherBtnTitle:@"确定" confirmBLock:^{} cancelBlock:^{
                        self.QRCodeRdsult = @"";
                    }];
                }
                self.QRCodeRdsult = result;
            }
        }
    }else {
        [self dismissViewControllerAnimated:YES completion:^{
            NSString *urlStr = [NSString stringWithFormat:@"%@/xcode/decode?code=%@",WEB_URL,result];
            [self.webView loadRequestWithString:urlStr];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

