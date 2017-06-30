//
//  DMContactStore.h
//  DMContactStoreDemo
//
//  Created by 李二狗 on 2017/6/29.
//  Copyright © 2017年 YRHY Science and Technology (Beijing) Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMContactStoreModel.h"

//获取所有的联系人信息
typedef void(^DMContactStoreGetAllBlock)(NSArray *contactStoreModels);

//获取一个联系人的model
typedef void(^DMContactStoreGetSingleBlock)(DMContactStoreModel *contactStoreModel);

//未点击电话或者点击取消
typedef void(^DMContactStoreCancelBlock)(void);

@interface DMContactStore : NSObject

/**
 调用系统通讯录 获取所有人的通讯录信息.

 @param getAllHandler 获取所有联系人信息回调
 */
- (void)callContactStoreGetAllHandler:(DMContactStoreGetAllBlock)getAllHandler;

/**
 调用系统通讯录页面 选择并获取联系人信息.

 @param getSingleHandler 获取单个联系人的信息回调
 */
- (void)callContactsHandler:(DMContactStoreGetSingleBlock)getSingleHandler;

/**
 用户选择取消之后的数据处理

 @param cancelHandler 取消回调
 */
- (void)cancelContactsHandler:(DMContactStoreCancelBlock)cancelHandler;



@end
