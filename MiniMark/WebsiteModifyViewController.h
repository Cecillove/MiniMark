//
//  ModifyUIVC.h
//  MiniMark
//
//  Created by  尹尚維 on 16/7/29.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebSite;

@interface WebsiteModifyViewController : UIViewController <UITextFieldDelegate> {
}

@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *urlTF;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
- (IBAction)doAddBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *categoryBtn;
- (IBAction)doCategoryBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UIPickerView *pickView;
@property (strong, nonatomic) WebSite *website;

@end
