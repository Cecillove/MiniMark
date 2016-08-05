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
        //这里需要初始化ImageView；
    }
    return self;
}
@end
