//
//  UIColor+dm_color.m
//  DMContactStoreDemo
//
//  Created by 李二狗 on 2017/7/3.
//  Copyright © 2017年 YRHY Science and Technology (Beijing) Co., Ltd. All rights reserved.
//

#import "UIColor+dm_color.h"

@implementation UIColor (dm_color)

+ (UIColor*)dm_colorWithHex:(NSInteger)hexValue
{
    return [UIColor dm_colorWithHex:hexValue alpha:1.0];
}

+ (UIColor*)dm_colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

@end
