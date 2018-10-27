//
//  QMSegmentMenuModel.h
//  juanpi3
//
//  Created by finger on 16/7/5.
//  Copyright © 2016年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MacroDefines.h"
@class QMSegmentTag;
@interface QMSegmentMenuModel : NSObject

/**
 *  菜单ID
 */
@property (assign, nonatomic) NSInteger menuId;

/**
 *  菜单标题
 */
@property (strong, nonatomic) NSString *title;
/**
 *  1 纯图 2 纯文本 3图文结合
 */
@property (strong, nonatomic) NSNumber *showType;
/**
 *  选中时显示的图片
 */
@property (strong, nonatomic) NSString *selectedIcon;
/**
 *  未选中时显示的图片
 */
@property (strong, nonatomic) NSString *unselectedIcon;
/**
 *  选中时标题显示的颜色
 */
@property (strong, nonatomic) UIColor *selectedTitleColor;
/**
 *  未选中时标题显示的颜色
 */
@property (strong, nonatomic) UIColor *unselectedTitleColor;
/**
 *  选中时背景的颜色
 */
@property (strong, nonatomic) UIColor *selectedBgColor;
/**
 *  未选中时背景的颜色
 */
@property (strong, nonatomic) UIColor *unselectedBgColor;
/**
 *  全图模式下的宽高比
 */
@property (strong, nonatomic) NSNumber *aspectRatio;
/**
 *  字体大小
 */
@property (nonatomic, strong) UIFont *titleFont;
/**
 *  角标
 */
@property (nonatomic, strong) id cornerMark;

/**
 *  占位图 选中时显示的图片 
 */
@property (strong, nonatomic) NSString *phSelectedIcon;
/**
 *  占位图 未选中时显示的图片
 */
@property (strong, nonatomic) NSString *phUnselectedIcon;

/**
 角标
 */
@property (strong, nonatomic) QMSegmentTag *segmentTag;
@end

@interface QMSegmentTag : NSObject
@property (nonatomic,strong)NSString *bg_color;
@property (nonatomic,strong)NSString *text_color;
@property (nonatomic,strong)NSString *border_color;
@property (nonatomic,strong)NSString *text;
@end

