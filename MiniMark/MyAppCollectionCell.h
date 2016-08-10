//
//  MyAppCollectionCell.h
//  MiniMark
//
//  Created by  尹尚維 on 16/8/4.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAppCollectionCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet UIButton *deleteBtn;

@end
