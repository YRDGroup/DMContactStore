//
//  DMContactStoreModel.h
//  DMContactStoreDemo
//
//  Created by 李二狗 on 2017/6/29.
//  Copyright © 2017年 YRHY Science and Technology (Beijing) Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMContactStoreModel : NSObject

/** 姓名 */
@property (nonatomic, copy) NSString *name;
/** 手机号 */
@property (nonatomic, copy) NSString *phoneNumber;
/** 地址 */
@property (nonatomic, copy) NSString *address;
/** 邮箱 */
@property (nonatomic, copy) NSString *email;
/** 工作单位 */
@property (nonatomic, copy) NSString *company;


- (NSString *)description;

@end
