//
//  ViewController.m
//  DMContactStoreDemo
//
//  Created by 李二狗 on 2017/6/29.
//  Copyright © 2017年 YRHY Science and Technology (Beijing) Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import "DMContactStore.h"
#import "UIImage+dm_image.h"
#import "UIColor+dm_color.h"


@interface ViewController ()
@property (nonatomic, strong) DMContactStore *contactsStore;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)getAll:(id)sender {
    DMContactStore *store = [[DMContactStore alloc]init];
    [store callContactStoreGetAllHandler:^(NSArray *contactStoreModels) {
       
        for (DMContactStoreModel *model in contactStoreModels) {
            NSLog(@"%@",model);
        }
        
    } unAuthorizedBlock:^{
        
    }];
    
}


- (IBAction)getSingle:(id)sender {
    
    self.contactsStore = [[DMContactStore alloc]init];
    [self.contactsStore callContactsHandler:^(DMContactStoreModel *contactStoreModel) {
        
        NSLog(@"%@",contactStoreModel);
        
    } unAuthorizedBlock:nil fitForContactsUtilBlock:nil fitForYourAppBlock:^{
        //和初始化时保持一致,要不然会变成白色navbar
        UINavigationBar *navBar = [UINavigationBar appearance];
        // 1.2.设置导航栏背景
        [navBar setBackgroundImage:[UIImage imageNamed:@"newNarBar"] forBarMetrics:UIBarMetricsDefault];
        // 1.3.设置导航栏的文字
        [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        
        
    } cancelContactsHandler:^{
        
        NSLog(@"用户取消了选择");
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
