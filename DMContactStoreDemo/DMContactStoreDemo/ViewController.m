//
//  ViewController.m
//  DMContactStoreDemo
//
//  Created by 李二狗 on 2017/6/29.
//  Copyright © 2017年 YRHY Science and Technology (Beijing) Co., Ltd. All rights reserved.
//

#import "ViewController.h"
#import "DMContactStore.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取所有人的联系方式
    DMContactStore *store = [[DMContactStore alloc]init];
    [store callContactStoreGetAllHandler:^(NSArray *contactStoreModels) {
        for (DMContactStoreModel *model in contactStoreModels) {
            NSLog(@"%@",model);
        }
    }];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
