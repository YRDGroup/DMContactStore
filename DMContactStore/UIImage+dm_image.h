//
//  UIImage+dm_image.h
//  DMContactStoreDemo
//
//  Created by 李二狗 on 2017/7/3.
//  Copyright © 2017年 YRHY Science and Technology (Beijing) Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (dm_image)

+ (UIImage *)dm_imageWithColor:(UIColor *)color;

+ (UIImage*)dm_getImageFromColors:(NSArray*)colors withFrame: (CGRect)frame;

@end
