//
//  UIImage+RCDynamicImage.h
//  RongExtensionKit
//
//  Created by 张改红 on 2019/11/11.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (RCDynamicImage)

@property (nonatomic, copy) NSString *rc_imageLocalPath;

+ (UIImage *)rc_imageWithLocalPath:(NSString *)path;

- (BOOL)rc_needReloadImage;
/// 根据颜色生成一个指定尺寸的纯色图片
+ (UIImage *)rc_imageWithColor:(UIColor *)color size:(CGSize)size;

/// 快捷方法：生成 1x1 像素的纯色图片
+ (UIImage *)rc_imageWithColor:(UIColor *)color;

- (UIImage*)mirror;

@end

NS_ASSUME_NONNULL_END
