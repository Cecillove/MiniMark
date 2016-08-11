//
//  WebsiteShowViewController.m
//  MiniMark
//
//  Created by  尹尚維 on 16/7/28.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import "WebsiteShowViewController.h"
#import "AFNetworking.h"
#import "Masonry.h"
#import "WebSite.h"

// 屏幕大小尺寸
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
// 控件
#define kDefualtHeight  20
#define kNavagationBarHeight  44

@interface WebsiteShowViewController ()

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UINavigationBar *navigationBar;
@property (nonatomic, assign) double loadCount;

@end

static NSString * const ConstEstProgress = @"estimatedProgress";

@implementation WebsiteShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化navigationBar
    self.navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kNavagationBarHeight)];
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = NO;
    // 初始化backItem
    UINavigationItem *backItem = [[UINavigationItem alloc]initWithTitle:self.website.name];
    NSMutableArray *mycustomButtons = [[NSMutableArray alloc]init];
    UIButton *left = [UIButton buttonWithType:UIButtonTypeCustom];
    [left setTitle:@"返回" forState:UIControlStateNormal];
    [left setFrame:CGRectMake(0, 0, 40, 30)];
    [left addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    UIImage *image = [UIImage imageNamed:@"back"];
//    [left setBackgroundImage:image forState:UIControlStateNormal];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithCustomView:left];
    [backItem setLeftBarButtonItem:leftButton];
    [mycustomButtons addObject:backItem];
    [self.navigationBar setItems:mycustomButtons];
    [self.view addSubview:self.navigationBar];
    [self.navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top).offset(kDefualtHeight);
        make.bottom.equalTo(self.view.mas_top).offset(kDefualtHeight + kNavagationBarHeight);
    }];
    // 初始化wkWebView
    WKWebView *webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    webView.allowsBackForwardNavigationGestures = YES;
    _wkWebView = webView;
    [self.view addSubview:self.wkWebView];
    [self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top).offset(kDefualtHeight + kNavagationBarHeight);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    // 初始化progressView
    self.progressView = [[UIProgressView alloc]initWithFrame:CGRectZero];
    [self.wkWebView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.wkWebView.mas_left).offset(0);
        make.right.equalTo(self.wkWebView.mas_right).offset(0);
        make.top.equalTo(self.wkWebView.mas_top).offset(0);
        make.bottom.equalTo(self.wkWebView.mas_top).offset(2);
    }];
    
    NSString *urlStr = self.website.url;
    if(![urlStr hasPrefix:@"http"]) {
        urlStr = [@"http://" stringByAppendingString:urlStr];
    }
    [self loadWebView:urlStr];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.loadCount = self.wkWebView.estimatedProgress;
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    // To void triggering default webpages events: zoom pages when doube-click
    NSString *javascript = @"var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);";
    [webView evaluateJavaScript:javascript completionHandler:nil];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.loadCount = self.wkWebView.estimatedProgress;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    // 获取并保存cookie
    [self getAndSaveCookie: (NSHTTPURLResponse *)navigationResponse.response];
    // 在收到响应后，决定是否跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.loadCount = self.wkWebView.estimatedProgress;
    NSString *message = [error localizedDescription];
    NSLog(@"didFailProvisionalNavigation error=%@",error);
    NSLog(@"message: %@", message);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSString *message = [error localizedDescription];
    NSLog(@"didFailProvisionalNavigation error=%@",error);
    NSLog(@"message: %@", message);
}

#pragma mark - 获取并保存Cookie
- (void)getAndSaveCookie:(NSHTTPURLResponse *)response {
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    // 存储归档后的cookie
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject: cookiesData forKey: @"cookie"];
    [userDefaults synchronize];
}

#pragma mark - 设置Cookie
- (void)setCookie {
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
    if([cookiesdata length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        NSHTTPCookie *cookie;
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
}

#pragma mark - 获取Cookie加载页面
- (void)loadWebView:(NSString *)urlStr {
    [self setCookie];
    
    // loop cookie for get cookieDic and
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        [cookieDic setObject:cookie.value forKey:cookie.name];
    }
    NSMutableString *cookieFormatKeyAndValue = [NSMutableString stringWithFormat:@""];
    for (NSString *key in cookieDic) {
        NSString *appendString = [NSString stringWithFormat:@"%@=%@;", key, [cookieDic valueForKey:key]];
        [cookieFormatKeyAndValue appendString:appendString];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    // set cookie
    [request addValue:cookieFormatKeyAndValue forHTTPHeaderField:@"Cookie"];
    [request setHTTPShouldHandleCookies:YES];
    
    [self.wkWebView loadRequest:request];
}

#pragma mark - wkWebView progress
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"loading"]) {
        
    } else if ([keyPath isEqualToString:@"title"]) {
        self.title = self.wkWebView.title;
    } else if ([keyPath isEqualToString:@"URL"]) {
        
    } else if ([keyPath isEqualToString:ConstEstProgress]) {
        self.progressView.progress = self.wkWebView.estimatedProgress;
    }
    
    CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
    if (object == self.wkWebView && [keyPath isEqualToString:ConstEstProgress]) {
        
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        } else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}

- (void)setLoadCount:(double)loadCount {
    _loadCount = loadCount;
    
    if (loadCount == 0 || loadCount == 1) {
        self.progressView.hidden = YES;
        [self.progressView setProgress:0 animated:NO];
    } else {
        self.progressView.hidden = NO;
        CGFloat oldProgress = self.progressView.progress;
        CGFloat newProgress = (1.0 - oldProgress) / (loadCount + 1.0) + oldProgress;
        if (newProgress > 0.95) {
            newProgress = 1;
        }
        [self.progressView setProgress:newProgress animated:YES];
    }
}

#pragma mark - Back Button
- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController popViewControllerAnimated:YES];
}


@end
