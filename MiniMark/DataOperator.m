//
//  DataOperator.m
//  MiniMark
//
//  Created by  尹尚維 on 16/7/29.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import "DataOperator.h"
#import <sqlite3.h>
#import "WebSite.h"
#import "MyApp.h"

@implementation DataOperator

#pragma mark Website数据操作

// 读取数据
+ (NSMutableArray *)retrieveWebsiteData {
    
    NSMutableArray *webSiteList = [[NSMutableArray alloc]init];
    
    // 建立表（程序第一次运行时建立）
    sqlite3 *database;
    if (sqlite3_open([[self getWebsiteDataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    // 建立表的SQL语句，主键为ROW，自增；其他键为NAME,URL
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS WebSiteTable (ROW INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, URL TEXT, SORTNO INTEGER, CATEGORY INTEGER);";
    // 将出错信心保存在errorMsg中
    char *errorMsg;
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        // 如果出错，则输出errorMsg
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    // 查询数据库，并以ROW排序
    NSString *query = @"SELECT ROW, NAME, URL, SORTNO, CATEGORY FROM WebSiteTable ORDER BY SORTNO";
    sqlite3_stmt *statement;//至于这个参数，网上的说法“这个相当于ODBC的Command对象，用于保存编译好的SQL语句”；
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        // 对表中的数据进行遍历，并转为website加入WebSiteList中
        while (sqlite3_step(statement) == SQLITE_ROW) {
            WebSite *website = [[WebSite alloc]init];
            int row = sqlite3_column_int(statement, 0);
            char *nameChar = (char *)sqlite3_column_text(statement, 1);
            char *urlChar = (char *)sqlite3_column_text(statement, 2);
            int sortno = sqlite3_column_int(statement, 3);
            int category = sqlite3_column_int(statement, 4);
            website.row = [[NSString alloc] initWithFormat:@"%d",row];
            website.name = [[NSString alloc] initWithUTF8String:nameChar];
            website.url = [[NSString alloc] initWithUTF8String:urlChar];
            website.sortno = [[NSString alloc] initWithFormat:@"%d",sortno];
            website.category = [[NSString alloc] initWithFormat:@"%d",category];
            [webSiteList addObject:website];
        }
        // 结束之前清除statement对象
        sqlite3_finalize(statement);
    }
    // 关闭数据库
    sqlite3_close(database);
    
    return webSiteList;
}

// 插入数据函数的实现，用的是绑定变量的方法。
+ (void)insertWebsiteData: (WebSite *)website {
    sqlite3 *database;
    if (sqlite3_open([[self getWebsiteDataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    //插入或更新一行，不指定主键ROW··则ROW会自增
    //INSERT OR REPLACE实现了插入或更新两个操作
    char *update = "INSERT OR REPLACE INTO WebSiteTable (NAME, URL, SORTNO, CATEGORY) VALUES (?, ?, ?, ?);";
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [website.name UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [website.url UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [website.sortno UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [website.category UTF8String], -1, NULL);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert(0, @"Error updating table: %s", errorMsg);
    }
    sqlite3_finalize(stmt);//结束之前清除statement变量
    sqlite3_close(database);//关闭数据库
}

// 删除表中row = rowId的那一行
+ (void)deleteWebsiteData:(int)rowId {
    sqlite3 *database;
    if (sqlite3_open([[self getWebsiteDataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    char *errmsg;
    NSString *deleteRow = [[NSString alloc]initWithFormat:@"DELETE FROM WebSiteTable WHERE ROW = %d",rowId];
    sqlite3_exec(database, [deleteRow UTF8String], NULL, NULL, &errmsg);
    if (errmsg != nil) {
        NSLog(@"%s",errmsg);
    }
    sqlite3_close(database);
}

// 修改表中row = rowId的那一行
+ (void)modifyWebsiteData:(WebSite *)website {
    sqlite3 *database;
    if (sqlite3_open([[self getWebsiteDataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    //更新操作
    char *update = "UPDATE WebSiteTable SET NAME = ?, URL = ?, SORTNO = ?, CATEGORY = ? WHERE ROW = ?;";
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [website.name UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [website.url UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [website.sortno UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [website.category UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [website.row UTF8String], -1, NULL);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert(0, @"Error updating table: %s", errorMsg);
    }
    sqlite3_finalize(stmt);//结束之前清除statement变量
    sqlite3_close(database);
}

// 获得DB文件路径
+ (NSString *)getWebsiteDataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"data.sqlite"];
}

// 使用懒加载，把WebSiteCategory.plist数据信息加载进来
+ (NSArray *)getWebsiteCategories {
    NSString *fullpath = [[NSBundle mainBundle]pathForResource:@"WebSiteCategory.plist" ofType:nil];
    NSArray *arrayM = [NSArray arrayWithContentsOfFile:fullpath];
    return arrayM;
}

# pragma mark MyAPP数据操作

// 获得DB文件路径
+ (NSString *)getMyAppDataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"myappdata.sqlite"];
}

// 读取数据
+ (NSMutableArray *)retrieveMyAppData {
    
    NSMutableArray *myappList = [[NSMutableArray alloc]init];
    
    // 建立表（程序第一次运行时建立）
    sqlite3 *database;
    if (sqlite3_open([[self getMyAppDataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    // 建立表的SQL语句，主键为ROW，自增；其他键为NAME,URL
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS MyAppTable (ROW INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, BUNDLEIDENTIFIER TEXT, SORTNO INTEGER);";
    // 将出错信心保存在errorMsg中
    char *errorMsg;
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        // 如果出错，则输出errorMsg
        NSAssert(0, @"Error creating table: %s", errorMsg);
    }
    // 查询数据库，并以ROW排序
    NSString *query = @"SELECT ROW, NAME, BUNDLEIDENTIFIER, SORTNO FROM MyAppTable ORDER BY SORTNO";
    sqlite3_stmt *statement;//至于这个参数，网上的说法“这个相当于ODBC的Command对象，用于保存编译好的SQL语句”；
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        // 对表中的数据进行遍历，并转为website加入WebSiteList中
        while (sqlite3_step(statement) == SQLITE_ROW) {
            MyApp *myapp = [[MyApp alloc]init];
            int row = sqlite3_column_int(statement, 0);
            char *nameChar = (char *)sqlite3_column_text(statement, 1);
            char *bundleChar = (char *)sqlite3_column_text(statement, 2);
            int sortno = sqlite3_column_int(statement, 3);
            myapp.row = [[NSString alloc] initWithFormat:@"%d",row];
            myapp.name = [[NSString alloc] initWithUTF8String:nameChar];
            myapp.bundleIdentifier = [[NSString alloc] initWithUTF8String:bundleChar];
            myapp.sortno = [[NSString alloc] initWithFormat:@"%d",sortno];
            [myappList addObject:myapp];
        }
        // 结束之前清除statement对象
        sqlite3_finalize(statement);
    }
    // 关闭数据库
    sqlite3_close(database);
    
    return myappList;
}

// 插入数据函数的实现，用的是绑定变量的方法。
+ (void)insertMyAppData: (MyApp *)myapp {
    sqlite3 *database;
    if (sqlite3_open([[self getMyAppDataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    //插入或更新一行，不指定主键ROW··则ROW会自增
    //INSERT OR REPLACE实现了插入或更新两个操作
    char *update = "INSERT OR REPLACE INTO MyAppTable (NAME, BUNDLEIDENTIFIER, SORTNO) VALUES (?, ?, ?);";
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [myapp.name UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [myapp.bundleIdentifier UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [myapp.sortno UTF8String], -1, NULL);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert(0, @"Error updating table: %s", errorMsg);
    }
    sqlite3_finalize(stmt);//结束之前清除statement变量
    sqlite3_close(database);//关闭数据库
}

// 删除表中row = rowId的那一行
+ (void)deleteMyAppData:(int)rowId {
    sqlite3 *database;
    if (sqlite3_open([[self getMyAppDataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    char *errmsg;
    NSString *deleteRow = [[NSString alloc]initWithFormat:@"DELETE FROM MyAppTable WHERE ROW = %d",rowId];
    sqlite3_exec(database, [deleteRow UTF8String], NULL, NULL, &errmsg);
    if (errmsg != nil) {
        NSLog(@"%s",errmsg);
    }
    sqlite3_close(database);
}

// 修改表中row = rowId的那一行
+ (void)modifyMyAppData:(MyApp *)myapp {
    sqlite3 *database;
    if (sqlite3_open([[self getMyAppDataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    //更新操作
    char *update = "UPDATE MyAppTable SET SORTNO = ? WHERE ROW = ?;";
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [myapp.sortno UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [myapp.row UTF8String], -1, NULL);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSAssert(0, @"Error updating table: %s", errorMsg);
    }
    sqlite3_finalize(stmt);//结束之前清除statement变量
    sqlite3_close(database);
}

// 使用懒加载，把WebSiteCategory.plist数据信息加载进来
+ (NSDictionary *)getMyAppList {
    NSString *fullpath = [[NSBundle mainBundle]pathForResource:@"MyAppList.plist" ofType:nil];
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:fullpath];
    return dictionary;
}

@end
