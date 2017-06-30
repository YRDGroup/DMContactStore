//
//  DMContactStoreModel.m
//  DMContactStoreDemo
//
//  Created by 李二狗 on 2017/6/29.
//  Copyright © 2017年 YRHY Science and Technology (Beijing) Co., Ltd. All rights reserved.
//

#import "DMContactStoreModel.h"

@implementation DMContactStoreModel

- (NSString *)description
{
    NSString * string = [NSString stringWithFormat:@"<Person: name = %@ phoneNumber = %@ address = %@ email = %@ company = %@>",self.name,self.phoneNumber,self.address,self.email,self.company];
    return string;
    
}

@end
