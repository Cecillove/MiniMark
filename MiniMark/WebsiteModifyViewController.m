//
//  WebsiteModifyViewController.m
//  MiniMark
//
//  Created by  尹尚維 on 16/7/29.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import "WebsiteModifyViewController.h"
#import "WebSite.h"
#import "DataOperator.h"

@interface WebsiteModifyViewController()

@property (nonatomic, retain) NSArray *categories;

@end

@implementation WebsiteModifyViewController


- (void) viewDidLoad {
    [super viewDidLoad];
    
    // 设置默认光标
    [self.nameTF becomeFirstResponder];
    self.nameTF.delegate = self;
    self.urlTF.delegate = self;
    self.nameTF.text = self.website.name;
    self.urlTF.text = self.website.url;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(change:) name:UITextFieldTextDidChangeNotification object: self.nameTF];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(change:) name:UITextFieldTextDidChangeNotification object: self.urlTF];
    
    self.categories = [DataOperator getWebsiteCategories];
    self.pickView.hidden = YES;
}

- (void) viewDidAppear:(BOOL)animated {
    if ([self.website.category isEqualToString:@"0"]) {
        self.categoryBtn.titleLabel.text = @"个人";
    } else if ([self.website.category isEqualToString:@"1"]) {
        self.categoryBtn.titleLabel.text = @"公司";
    }
}

-(void)change:(NSNotification *)notification {
    if (self.nameTF.text.length > 0 && self.urlTF.text.length > 0) {
        self.addBtn.userInteractionEnabled = YES;
        self.addBtn.alpha = 1;
    } else {
        self.addBtn.userInteractionEnabled = NO;
        self.addBtn.alpha = 0.5;
    }
}

- (IBAction)doAddBtn:(id)sender { 
    // 传值
    WebSite * website = [[WebSite alloc] init];
    website.name = self.nameTF.text;
    website.url = self.urlTF.text;
    website.row = self.website.row;
    if ([self.categoryBtn.titleLabel.text isEqualToString:@"个人"]) {
        website.category = [NSString stringWithFormat:@"%d", 0];
    } else if ([self.categoryBtn.titleLabel.text isEqualToString:@"公司"]) {
        website.category = [NSString stringWithFormat:@"%d", 1];
    }
    // Modify Data
    [DataOperator modifyWebsiteData:website];
    // 返回编辑界面
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameTF) {
        [self.urlTF becomeFirstResponder];
    }
    else if (textField == self.urlTF && self.addBtn.isUserInteractionEnabled) {
        [self doAddBtn:self.addBtn];
    }
    return NO;
}

#pragma mark- 设置数据
//一共多少列
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

//每列对应多少行
- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.categories.count;
}

//每列每行对应显示的数据是什么
- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.categories[row];
}

#pragma mark-设置下方的数据刷新
// 当选中了pickerView的某一行的时候调用
// 会将选中的列号和行号作为参数传入
// 只有通过手指选中某一行的时候才会调用
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //获取对应列，对应行的数据
    NSString *name=self.categories[row];
    //赋值
    self.categoryBtn.titleLabel.text = name;
    self.pickView.hidden = YES;
}

- (IBAction)doCategoryBtn:(id)sender {
    // 关闭键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:NO];
    // 打开PickerView
    self.pickView.hidden = NO;
}

@end
