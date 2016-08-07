//
//  WebsiteShowViewController.m
//  MiniMark
//
//  Created by  尹尚維 on 16/7/28.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import "WebsiteShowViewController.h"
#import "WebSite.h"

@interface WebsiteShowViewController ()

@property (retain, nonatomic) IBOutlet UIWebView *myWebView;

@end

@implementation WebsiteShowViewController {
    NJKWebViewProgressView *_webViewProgressView;
    NJKWebViewProgress *_webViewProgress;
}

@synthesize website;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webViewProgress = [[NJKWebViewProgress alloc] init];
    self.myWebView.delegate = _webViewProgress;
    _webViewProgress.webViewProxyDelegate = self;
    _webViewProgress.progressDelegate = self;
    
    CGRect navBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0,
                                 navBounds.size.height - 2,
                                 navBounds.size.width,
                                 2);
    _webViewProgressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _webViewProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [_webViewProgressView setProgress:0 animated:YES];
    
    // 设置title
    self.title = website.name;
    NSString *urlStr = website.url;
    if(![urlStr hasPrefix:@"http"]) {
        urlStr = [@"http://" stringByAppendingString:urlStr];
    }
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    [self.navigationController.navigationBar addSubview:_webViewProgressView];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [_webViewProgressView removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_webViewProgressView setProgress:progress animated:YES];
    self.title = [self.myWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

@end
