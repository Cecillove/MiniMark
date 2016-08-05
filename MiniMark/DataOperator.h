//
//  DataOperator.h
//  MiniMark
//
//  Created by  尹尚維 on 16/7/29.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebSite;
@class MyApp;
@interface DataOperator : NSObject

+ (NSMutableArray *)retrieveWebsiteData;
+ (void)insertWebsiteData: (WebSite *)website;
+ (void)deleteWebsiteData:(int)rowId;
+ (void)modifyWebsiteData:(WebSite *)website;
+ (NSArray *)getWebsiteCategories;

+ (NSMutableArray *)retrieveMyAppData;
+ (void)insertMyAppData: (MyApp *)myapp;
+ (void)deleteMyAppData:(int)rowId;
+ (void)modifyMyAppData:(MyApp *)myapp;

+ (NSDictionary *)getMyAppList;

@end
