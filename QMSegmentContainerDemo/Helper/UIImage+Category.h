//
//  UIImage+Category.h
//  Juanpi_2.0
//
//  Created by luoshuai on 14-2-24.
//  Copyright (c) 2014年 Juanpi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Category)


/**
 *  图片拉伸，返回一张新的拉伸图片
 *
 *  @param name 传入进来的图片
 *
 *  @return 返回新的图片
 */
+ (UIImage *)resizableImage:(NSString *)name;



//+ (UIImage *) captureScreen ;//截屏

/**
 *  压缩图片
 *
 *  @param image 需要压塑的图片
 *
 *  @return 压缩好的图片
 */
+ (UIImage *)compressionWithImage:(UIImage *)image toSize:(CGSize )size;

/**
 *  用一个颜色生成图片
 *
 *  @param color 图片颜色
 *
 *  @return 图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  用一个颜色生成图片
 *
 *  @param color 图片颜色
 *  @param size  图片大小
 *
 *  @return 图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

//==================================================

/**
 *  压缩要上传的图片
    算法:
    1.判断是否是长图(Width>2Height或者Height>2Width)
        是:不处理
        否:按照宽高比例压缩图片(长宽控制在2倍的屏幕的宽高以内)
    2.获取压缩图片的百分比,每次降低10%,直到小于最大图片上传大小
    3.按百分比压缩图片
 
 @param scale 压缩后的图像尺寸相对于屏幕尺寸的倍数
 */
+ (UIImage *)imageWithImageUpload:(UIImage *)image scale:(CGFloat)scale;
+ (NSData *)dataWithImageUpload:(UIImage *)image scale:(CGFloat)scale;

//==================================================


/**
 *  压缩要分享的图片
 *
 *  @param image 输入的image
 *
 *  @return 压缩后的image
 */
+ (UIImage *)imageWithShareImage:(UIImage *)image;


/**
 *  把分享的图片转成NSData
 *
 *  @param image 输入的image
 *
 *  @return NSData
 */
+ (NSData *)dataWithShareImage:(UIImage *)image;

/**
 *  截取图片
 *
 *  @param rect 区域
 *
 *  @return 图片
 */
- (UIImage *)cropImageInRect:(CGRect)rect;

/**
 *  图片的base64字符串
 */
- (NSString *)base64String;
@end


@interface UIImage (ImageEffects)

- (UIImage*)applyLightEffect;
- (UIImage*)applyExtraLightEffect;
- (UIImage*)applyDarkEffect;
- (UIImage*)applyTintEffectWithColor:(UIColor*)tintColor;
- (UIImage*)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor*)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage*)maskImage;

@end
