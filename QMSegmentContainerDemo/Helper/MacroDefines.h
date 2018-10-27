//
//  ColorDefine.h
//  QMSegmentContainerDemo
//
//  Created by 罗谨 on 2018/10/18.
//  Copyright © 2018年 finger. All rights reserved.
//

#ifndef ColorDefine_h
#define ColorDefine_h
#import "UIColor+ColorConvert.h"


// UIScreen related macros
#define SCREEN_BOUNDS           [UIScreen mainScreen].bounds
#define SCREEN_SCALE            [UIScreen mainScreen].scale
#define SCREEN_WIDTH            SCREEN_BOUNDS.size.width
#define SCREEN_HEIGHT           SCREEN_BOUNDS.size.height


#define UIColorFromHexValue(hexValue)       [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromHexString(hexString)     [UIColor colorWithHexString:hexString]
#define RGBAColor(r, g, b, a)               [UIColor colorWithRed:(r) / 255.0f green:(g) / 255.0f blue:(b) / 255.0f alpha:(a)]
#define RGBColor(r, g, b)                   RGBAColor(r, g, b, 1.0)


#endif /* ColorDefine_h */
