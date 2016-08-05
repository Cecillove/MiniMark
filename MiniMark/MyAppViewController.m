//
//  MyAppViewController.m
//  MiniMark
//
//  Created by  尹尚維 on 16/8/3.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import "MyAppViewController.h"
#import "DataOperator.h"
#import "MyApp.h"
#import "AppListTableViewController.h"
#import "LMApp.h"
#import "LMAppController.h"

@interface UIImage ()
+ (id)_iconForResourceProxy:(id)arg1 variant:(int)arg2 variantsScale:(float)arg3;
+ (id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(double)arg3;
@end

@interface MyAppViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)doAddBtn:(id)sender;
@property (nonatomic, strong) NSMutableArray *appArray;

@end

@implementation MyAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
    self.appArray = [DataOperator retrieveMyAppData];
    [self.tableView reloadData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.appArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myAppCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myAppCell"];
    }
    
    MyApp *myapp = self.appArray[indexPath.row];
    cell.textLabel.text = myapp.name;
    UIImage *icon = [UIImage _applicationIconImageForBundleIdentifier:myapp.bundleIdentifier format:10 scale:2.0];
    cell.imageView.image = icon;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MyApp *myapp = self.appArray[indexPath.row];
    [[LMAppController sharedInstance] openAppWithBundleIdentifier:myapp.bundleIdentifier];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MyApp *myapp = self.appArray[indexPath.row];
        [self.appArray removeObjectAtIndex:indexPath.row];
        [DataOperator deleteMyAppData:[myapp.row intValue]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    MyApp *myapp = self.appArray[sourceIndexPath.row];
    [self.appArray removeObject:myapp];
    [self.appArray insertObject:myapp atIndex:destinationIndexPath.row];
    
    for (int i = 0; i < self.appArray.count; i++) {
        MyApp *update = self.appArray[i];
        update.sortno = [NSString stringWithFormat:@"%d", i + 1];
        // Update SORTNO
        [DataOperator modifyMyAppData:update];
    }
}

- (IBAction)doAddBtn:(id)sender {
    AppListTableViewController *controller = (AppListTableViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"appListIdentifier"];
    controller.sortno = [NSString stringWithFormat:@"%lu", self.appArray.count + 1];
    controller.myapps = (NSArray *)self.appArray;
    [self.navigationController pushViewController:controller animated:YES];
//    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self presentViewController:controller animated:YES completion:nil];
}
@end
