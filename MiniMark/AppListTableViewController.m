//
//  AppListTableViewController.m
//  MiniMark
//
//  Created by  尹尚維 on 16/7/29.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import "AppListTableViewController.h"
#import "LMApp.h"
#import "LMAppController.h"
#import "MyApp.h"
#import "DataOperator.h"

@interface AppListTableViewController ()

@property (nonatomic, retain) NSMutableArray *apps;
@property (nonatomic, strong) NSMutableArray *addApps;
- (IBAction)doAddBtn:(id)sender;

@end

@implementation AppListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.apps = (NSMutableArray *)[LMAppController sharedInstance].installedApplications;
    NSMutableArray *tempyapps = [self.apps copy];

    for (MyApp *myapp in self.myapps) {
        for (LMApp *tempapp in tempyapps) {
            if ([myapp.bundleIdentifier isEqualToString:tempapp.bundleIdentifier]) {
                [self.apps removeObject:tempapp];
            }
        }
    }
    
    [self.tableView setEditing:YES animated:YES];
    self.addApps = [[NSMutableArray alloc]init];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = YES;
}

- (IBAction)startRefresh:(UIRefreshControl *)sender {
    [sender endRefreshing];
    self.apps = (NSMutableArray *)[LMAppController sharedInstance].installedApplications;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.apps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppTableViewCellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AppTableViewCellIdentifier"];
    }
    
    LMApp *app = (LMApp *)self.apps[indexPath.row];
    cell.imageView.image = app.icon;
    cell.textLabel.text = app.name;
    cell.detailTextLabel.text = app.bundleIdentifier;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LMApp *app = (LMApp *)self.apps[indexPath.row];
    MyApp *myapp = [[MyApp alloc]init];
    myapp.name = app.name;
    myapp.bundleIdentifier = app.bundleIdentifier;
    myapp.sortno = self.sortno;
    
    [self.addApps addObject:myapp];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (IBAction)doAddBtn:(id)sender {
    for (MyApp *myapp in self.addApps) {
        [DataOperator insertMyAppData:myapp];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
