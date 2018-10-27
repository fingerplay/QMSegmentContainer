//
//  QMSegmentMenuModel.m
//  juanpi3
//
//  Created by finger on 16/7/5.
//  Copyright © 2016年 finger. All rights reserved.
//

#import "QMSegmentMenuModel.h"

@implementation QMSegmentMenuModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    
    return @{@"showType":@"show_type",
             @"selectedIcon":@"act_icon",
             @"unselectedIcon":@"bg_icon",
             @"selectedTitleColor":@"act_color",
             @"unselectedTitleColor":@"color",
             @"selectedBgColor":@"act_bg_color",
             @"unselectedBgColor":@"bg_color",
             @"subMenus":@"subtab",
             @"topMenus":@"submenu",
             @"aspectRatio":@"wh_ratio",
             @"navLogo":@"top_icon"};
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    if ([selectedTitleColor isKindOfClass:[NSString class]]) {
        _selectedTitleColor = [UIColor colorWithHexString:(NSString *)selectedTitleColor];
    } else {
        _selectedTitleColor = selectedTitleColor;
    }
}

- (void)setUnselectedTitleColor:(UIColor *)unselectedTitleColor {
    if ([unselectedTitleColor isKindOfClass:[NSString class]]) {
        _unselectedTitleColor = [UIColor colorWithHexString:(NSString *)unselectedTitleColor];
    } else {
        _unselectedTitleColor = unselectedTitleColor;
    }
}

- (void)setSelectedBgColor:(UIColor *)selectedBgColor {
    if ([selectedBgColor isKindOfClass:[NSString class]]) {
        _selectedBgColor = [UIColor colorWithHexString:(NSString *)selectedBgColor];
    } else {
        _selectedBgColor = selectedBgColor;
    }
}

- (void)setUnselectedBgColor:(UIColor *)unselectedBgColor {
    if ([unselectedBgColor isKindOfClass:[NSString class]]) {
        _unselectedBgColor = [UIColor colorWithHexString:(NSString *)unselectedBgColor];
    } else {
        _unselectedBgColor = unselectedBgColor;
    }
}

@end

@implementation QMSegmentTag


@end
