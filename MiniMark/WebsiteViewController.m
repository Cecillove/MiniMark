//
//  WebsiteViewController.m
//  MiniMark
//
//  Created by  尹尚維 on 16/8/3.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import <sqlite3.h>
#import "WebsiteViewController.h"
#import "WebsiteShowViewController.h"
#import "WebsiteEditorViewController.h"
#import "WebSite.h"
#import "DataOperator.h"

@interface WebsiteViewController ()

- (IBAction)doEditBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *webSiteList;
@property (strong, nonatomic) NSArray *categoryList;
@property (strong, nonatomic) NSMutableArray *personalList;
@property (strong, nonatomic) NSMutableArray *companyList;

@end

@implementation WebsiteViewController

#pragma mark - Prepare Data

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.myTableView.sectionHeaderHeight = 0;
    self.myTableView.sectionFooterHeight = 10;
}

- (void) viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
    
    NSMutableArray *list = [[NSMutableArray alloc]init];
    self.personalList = [[NSMutableArray alloc]init];
    self.companyList = [[NSMutableArray alloc]init];
    self.webSiteList = [[NSMutableArray alloc]init];
    
    list = [DataOperator retrieveWebsiteData];
    for (WebSite *website in list) {
        if ([website.category isEqualToString:@"0"]) {
            [self.personalList addObject:website];
        } else if ([website.category isEqualToString:@"1"]) {
            [self.companyList addObject:website];
        }
    }
    
    [self.webSiteList addObject:self.personalList];
    [self.webSiteList addObject:self.companyList];
    
    [self.myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

// 设置section数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.categoryList =[ DataOperator getWebsiteCategories];
    return self.categoryList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

// 设置tableView行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //根据分区号，获取对应的存放容器
    NSMutableArray *itemArray = [self.webSiteList objectAtIndex:section];
    return itemArray.count;
}

// 设置tableView的cell内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //根据分区号，获取对应的存放容器
    NSMutableArray *itemArray = [self.webSiteList objectAtIndex:indexPath.section];
    //指定置顶区的唯一标识符..
    static NSString *personalIdentifier = @"personalIdentifier";
    //指定正常区的唯一标识符
    static NSString *companyIdentifier = @"companyIdentifier";
    //声明返回的变量名
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case 0:// 私人
        {
            cell = [tableView dequeueReusableCellWithIdentifier:personalIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:personalIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            // 赋值
            WebSite *website = itemArray[indexPath.row];
            cell.textLabel.text = website.name;
            cell.detailTextLabel.text = website.url;
            break;
        }
        case 1:// 公司
        {
            cell = [tableView dequeueReusableCellWithIdentifier:companyIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:companyIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            // 赋值
            WebSite *website = itemArray[indexPath.row];
            cell.textLabel.text = website.name;
            cell.detailTextLabel.text = website.url;
            cell.backgroundColor = [UIColor whiteColor];
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    WebsiteShowViewController *controller = (WebsiteShowViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"websiteShowIdentifier"];
    WebsiteShowViewController *controller = [[WebsiteShowViewController alloc]init];
    //根据分区号，获取对应的存放容器
    NSMutableArray *itemArray = [self.webSiteList objectAtIndex:indexPath.section];
    controller.website = itemArray[indexPath.row];
//    [self.navigationController pushViewController:controller animated:YES];
    [controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [controller setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    switch (section) {
        case 0:
            title = @"个人";
            break;
        case 1:
            title = @"公司";
        default:
            break;
    }
    return title;
}

- (IBAction)doEditBtn:(id)sender {
    WebsiteEditorViewController *controller = (WebsiteEditorViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"websiteEditorIdentifier"];
    [self.navigationController pushViewController:controller animated:YES];
}
@end
