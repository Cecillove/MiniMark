//
//  WebsiteShowViewController.h
//  MiniMark
//
//  Created by  尹尚維 on 16/7/28.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class WebSite;

@interface WebsiteShowViewController : UIViewController <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic,strong) WebSite *website;

@end
