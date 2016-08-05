//
//  WebsiteAddViewController.m
//  MiniMark
//
//  Created by  尹尚維 on 16/7/28.
//  Copyright © 2016年 迈思腾科技. All rights reserved.
//

#import "WebsiteAddViewController.h"
#import "WebSite.h"
#import "DataOperator.h"

@interface WebsiteAddViewController ()

@property(nonatomic,strong)NSArray *categories;

@end

@implementation WebsiteAddViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // 设置默认光标
    [self.nameTF becomeFirstResponder];
    self.nameTF.delegate = self;
    self.urlTF.delegate = self;
    self.addBtn.userInteractionEnabled = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(change:) name:UITextFieldTextDidChangeNotification object: self.nameTF];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(change:) name:UITextFieldTextDidChangeNotification object: self.urlTF];
    
    self.pickView.hidden = YES;
    self.categories = [DataOperator getWebsiteCategories];
    self.categoryBtn.titleLabel.text = @"个人";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
//    // 设定默认值
//    [self.pickView selectRow:0 inComponent:0 animated:NO];
}


- (IBAction)doAddBtn:(id)sender {
    WebSite *website = [[WebSite alloc]init];
    website.name = self.nameTF.text;
    website.url = self.urlTF.text;
    website.sortno = self.sortno;
    if ([self.categoryBtn.titleLabel.text isEqualToString:@"个人"]) {
        website.category = [NSString stringWithFormat:@"%d", 0];
    } else if ([self.categoryBtn.titleLabel.text isEqualToString:@"公司"]) {
        website.category = [NSString stringWithFormat:@"%d", 1];
    }
    // Insert Data
    [DataOperator insertWebsiteData:website];
    // 返回编辑界面
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
