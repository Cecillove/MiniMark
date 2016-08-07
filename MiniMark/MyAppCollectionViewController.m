//
//  MyAppCollectionViewController.m
//  MiniMark
//
//  Created by  尹尚維 on 16/8/4.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import "MyAppCollectionViewController.h"
#import "DataOperator.h"
#import "MyApp.h"
#import "collectionCell.h"
#import "LMAppController.h"
#import "AppListTableViewController.h"

#define angelToRandian(x) ((x)/180.0*M_PI)

NS_ENUM(NSInteger, CellState) {
    //右上角编辑按钮的两种状态；
    //正常的状态，按钮显示“编辑”;
    NormalState,
    //正在删除时候的状态，按钮显示“完成”；
    DeleteState
};


@interface UIImage ()
+ (id)_iconForResourceProxy:(id)arg1 variant:(int)arg2 variantsScale:(float)arg3;
+ (id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(double)arg3;
@end

@interface MyAppCollectionViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addBtn;
- (IBAction)doAddBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (nonatomic, strong) NSMutableArray *appArray;
@property (nonatomic,assign) enum CellState;
- (IBAction)doTrashBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *trashBtn;
- (IBAction)doDeleteBtn:(id)sender;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;

@end

@implementation MyAppCollectionViewController

static NSString * const reuseIdentifier = @"collectionCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建长按手势监听
    self.longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(myHandleTableviewCellLongPressed:)];
    self.longPress.minimumPressDuration = 0.1;
    //将长按手势添加到需要实现长按操作的视图里
    [self.myCollectionView addGestureRecognizer:self.longPress];
}

- (void)viewWillAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
    [self.myCollectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) myHandleTableviewCellLongPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (CellState == NormalState) {
        return;
    }
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            NSIndexPath *selectedIndexPath = [self.myCollectionView indexPathForItemAtPoint:[gestureRecognizer locationInView:self.myCollectionView]];
            if (selectedIndexPath != nil) {
                [self.myCollectionView beginInteractiveMovementForItemAtIndexPath:selectedIndexPath];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self.myCollectionView updateInteractiveMovementTargetPosition:[gestureRecognizer locationInView:gestureRecognizer.view]];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self.myCollectionView endInteractiveMovement];
            break;
        }
        default:
            [self.myCollectionView cancelInteractiveMovement];
            break;
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    self.appArray = [DataOperator retrieveMyAppData];
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.appArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    collectionCell *cell = (collectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    MyApp *myapp = self.appArray[indexPath.row];
    UIImage *icon = [UIImage _applicationIconImageForBundleIdentifier:myapp.bundleIdentifier format:10 scale:2.0];
    cell.imageView.image = icon;
    cell.label.text = myapp.name;
    
    // 点击编辑按钮触发事件
    if (CellState == NormalState) {
        // 正常情况下，所有删除按钮都隐藏；
        cell.deleteBtn.hidden = YES;
        // 停止抖动动画
        [cell.imageView.layer removeAllAnimations];
    } else if (CellState == DeleteState) {
        //可删除情况下；
        cell.deleteBtn.hidden = NO;
        [cell addSubview:cell.deleteBtn];
        [cell.deleteBtn bringSubviewToFront:self.myCollectionView];
        // 抖动动画
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
        anim.keyPath = @"transform.rotation";
        anim.values = @[@(angelToRandian(-7)),@(angelToRandian(7)),@(angelToRandian(-7))];
        anim.repeatCount = MAXFLOAT;
        anim.duration = 0.2;
        [cell.imageView.layer addAnimation:anim forKey:nil];
        [cell.deleteBtn.layer addAnimation:anim forKey:nil];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (CellState == NormalState) {
        MyApp *myapp = self.appArray[indexPath.row];
        [[LMAppController sharedInstance] openAppWithBundleIdentifier:myapp.bundleIdentifier];
    }
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    // 更新sortno
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
/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/


/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (IBAction)doAddBtn:(id)sender {
    AppListTableViewController *controller = (AppListTableViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"appListIdentifier"];
    controller.sortno = [NSString stringWithFormat:@"%lu", self.appArray.count + 1];
    controller.myapps = (NSArray *)self.appArray;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)doTrashBtn:(id)sender {
    //从正常状态变为可删除状态；
    if (CellState == NormalState) {
        CellState = DeleteState;
        self.trashBtn.title = @"完成";
    }
    else if (CellState == DeleteState) {
        CellState = NormalState;
        self.trashBtn.title = @"编辑";
    }
    [self.myCollectionView reloadData];
}

- (IBAction)doDeleteBtn:(id)sender {
    collectionCell *cell = (collectionCell *)[sender superview];//获取cell
    NSIndexPath *indexpath = [self.myCollectionView indexPathForCell:cell];//获取cell对应的indexpath;
    MyApp *myapp = self.appArray[indexpath.row];
    //删除cell
    [DataOperator deleteMyAppData:[myapp.row intValue]];
    [self.myCollectionView reloadData];
}
@end
