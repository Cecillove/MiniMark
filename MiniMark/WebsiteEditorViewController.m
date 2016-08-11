//
//  FouthUIVC.m
//  MiniMark
//
//  Created by  尹尚維 on 16/7/29.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import "WebsiteEditorViewController.h"
#import "DataOperator.h"
#import "WebSite.h"
#import "WebsiteAddViewController.h"
#import "WebsiteModifyViewController.h"

@interface WebsiteEditorViewController()

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *webSiteList;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editBtn;
- (IBAction)doEditBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
- (IBAction)doAddBtn:(id)sender;
@property (strong, nonatomic) NSArray *categoryList;
@property (strong, nonatomic) NSMutableArray *personalList;
@property (strong, nonatomic) NSMutableArray *companyList;

@end

@implementation WebsiteEditorViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.editBtn.style = UIBarButtonSystemItemEdit;
}

- (void) viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
    
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

// 设置编辑按钮动画
- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.myTableView setEditing:editing animated:animated];
}


#pragma mark - Table view data source

// 设置section数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.categoryList =[ DataOperator getWebsiteCategories];
    return self.categoryList.count;
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
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:personalIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
//                cell.textLabel.textColor = [UIColor redColor];
            }
        }
        case 1:// 公司
        {
            cell = [tableView dequeueReusableCellWithIdentifier:companyIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:companyIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
//                cell.textLabel.textColor = [UIColor redColor];
            }
            break;
        }
    }
    
    // 赋值
    WebSite *website = itemArray[indexPath.row];
    cell.textLabel.text = website.name;
    cell.detailTextLabel.text = website.url;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WebsiteModifyViewController *controller = (WebsiteModifyViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"websiteModifyIdentifier"];
    //根据分区号，获取对应的存放容器
    NSMutableArray *itemArray = [self.webSiteList objectAtIndex:indexPath.section];
    controller.website = itemArray[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
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

// 设置tableView的行是否能编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// 根据参数editingStyle执行删除或者插入
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WebSite *website = self.webSiteList[indexPath.row];
        [self.webSiteList removeObjectAtIndex:indexPath.row];
        [DataOperator deleteWebsiteData:[website.row intValue]];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// 打开编辑模式后，默认情况下每行左边会出现红的删除按钮
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 执行移动操作
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    WebSite *website = self.webSiteList[fromIndexPath.row];
    [self.webSiteList removeObject:website];
    [self.webSiteList insertObject:website atIndex:toIndexPath.row];
    
    for (int i = 0; i < self.webSiteList.count; i++) {
        WebSite *updateWebSite = self.webSiteList[i];
        updateWebSite.sortno = [NSString stringWithFormat:@"%d", i + 1];
        // Update SORTNO
        [DataOperator modifyWebsiteData:updateWebSite];
    }
}

// 告诉表格,这一行是否可以移动
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

// 允许Menu菜单
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 定义每个cell可以点击的Menu菜单选项
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(cut:)) {
        return NO;
    } else if (action == @selector(copy:)) {
        return YES;
    }
    else if (action == @selector(paste:)) {
        return NO;
    }
    else if (action == @selector(select:)) {
        return NO;
    }
    else if (action == @selector(selectAll:)) {
        return NO;
    }
    else {
        return [super canPerformAction:action withSender:sender];
    }
}

// 执行Menu菜单的选项
- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    WebSite *website = self.webSiteList[indexPath.section][indexPath.row];
    
    if (action ==@selector(copy:)) {
        [UIPasteboard generalPasteboard].string = website.url;
    }
}

- (IBAction)doEditBtn:(id)sender {
    if (self.editBtn.style == UIBarButtonSystemItemEdit) {
        self.editBtn.style = UIBarButtonSystemItemDone;
        [self setEditing:YES animated:YES];
    }
    else if (self.editBtn.style == UIBarButtonSystemItemDone) {
        self.editBtn.style = UIBarButtonSystemItemEdit;
        [self setEditing:NO animated:YES];
    }
}

- (IBAction)doAddBtn:(id)sender {
    WebsiteAddViewController *controller = (WebsiteAddViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"websiteAddIdentifier"];
    controller.sortno = [NSString stringWithFormat:@"%ld", self.webSiteList.count + 1];
    [self.navigationController pushViewController:controller animated:YES];
}
@end
