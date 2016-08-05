//
//  WebsiteShowViewController.h
//  MiniMark
//
//  Created by  尹尚維 on 16/7/28.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"

@class WebSite;

@interface WebsiteShowViewController : UIViewController <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (nonatomic,strong) WebSite *website;

@end
