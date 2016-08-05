//
//  collectionCell.m
//  MiniMark
//
//  Created by  尹尚維 on 16/8/4.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import "collectionCell.h"

#define UISCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define CELL_WIDTH (([[UIScreen mainScreen] bounds].size.width - 40) / 3)

@implementation collectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        //这里需要初始化ImageView；
//        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - (UISCREEN_WIDTH - 40) / 6 - 20, self.frame.size.width-(UISCREEN_WIDTH - 40) / 6 - 20, 40, 40)];
//        [self.imageView setUserInteractionEnabled:true];
//        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.width - (UISCREEN_WIDTH - 40) / 6 + 20, (UISCREEN_WIDTH - 40) / 3, 20)];
//        self.label.textAlignment = NSTextAlignmentCenter;
//        self.label.text = @"111";
//        self.deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(CELL_WIDTH - 35, 5, 30, 30)];
//        [self.deleteBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
//        //先设置不可见；
//        [self.deleteBtn setHidden:true];
//        
//        self.layer.borderWidth = 0.5;
//        
//        [self addSubview:self.imageView];
//        [self addSubview:self.label];
//        [self addSubview:self.deleteBtn];
    }
    return self;
}
@end
