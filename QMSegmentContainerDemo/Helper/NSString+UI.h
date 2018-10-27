//
//  NSString+UI.h
//  Juanpi_2.0
//
//  Created by Brick on 14-2-28.
//  Copyright (c) 2014年 Juanpi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (UI)
//获取字符串Size
- (CGSize)getUISize:(UIFont*)font limitWidth:(CGFloat)width;
- (NSString *)isDetailGoodsID;//扫描二维码 获取产品ID
/**获取带行间距的字符串Size*/
- (CGSize)getUISize:(UIFont*)font WithParagraphSpace:(CGFloat)space limitWidth:(CGFloat)width;
/**
 *  生成带“¥”符号的字符串
 */
- (NSString *)addCurrencySymbol;

/** 中文字符长度 */
- (NSInteger)byteLength;

/** 判断字符串字符个数 */
+ (int)getCharacterFromStr:(NSString *)tempStr;

/** 给不同的内容赋不同的字体 */
+ (NSArray *)descripteDifferentLabelWithFirstString:(NSString *)firstString  AndFirstFont:(UIFont *)fontF WithFirstColor:(UIColor *)firstColor WithSecondString:(NSString *)secondString AndSecondFont:(UIFont *)fontL AndSecondColor:(UIColor *)secondColor;

@end

//存首页栏目的数据
@interface NSString (File)
+ (NSString *)pathName;//文件名字
/**
 *  左侧菜单栏的存贮文件名
 *
 */
+ (NSString *)leftMenuPathName;
/**
 *  积分商城的存贮位置
 *
 */
+(NSString *)pointMallPathName;
@end

@interface NSString (LoginPassword)
+ (BOOL)checkPasswordValid:(NSString *)password;
@end
