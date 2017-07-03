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

//未点击电话或者点击取消
typedef void(^DMContactStoreFitForYourAppBlock)(void);

@interface DMContactStore : NSObject

/**
 调用系统通讯录 获取所有人的通讯录信息.

 @param getAllHandler 获取所有联系人信息回调
 */
- (void)callContactStoreGetAllHandler:(DMContactStoreGetAllBlock)getAllHandler  unAuthorizedBlock:(void(^)(void))unAuthorizedBlock;


/**
 调用系统通讯录页面 选择并获取联系人信息.

 @param getSingleHandler 获取联系人的model
 @param unAuthorizedBlock 未授权时的处理，如果不实现block，则默认实现系统alertView弹框和跳转
 @param setFitForContactsUtilBlock 进入系统联系人页面的适配处理.如果不实现，则默认使用系统的设置
 @param fitForYourAppBlock 返回到app页面时候的重置navbar颜色等，必须实现
 @param cancelHandler 页面返回时的回调.用户取消，或者选中都会触发此block
 */
- (void)callContactsHandler:(DMContactStoreGetSingleBlock)getSingleHandler  unAuthorizedBlock:(void(^)(void))unAuthorizedBlock fitForContactsUtilBlock:(void(^)(void))setFitForContactsUtilBlock fitForYourAppBlock:(DMContactStoreFitForYourAppBlock)fitForYourAppBlock cancelContactsHandler:(DMContactStoreCancelBlock)cancelHandler;

@end
