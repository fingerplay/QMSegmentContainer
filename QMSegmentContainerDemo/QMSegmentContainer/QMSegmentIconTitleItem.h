//
//  QMSegmentItemButton.h
//  juanpi3
//
//  Created by finger on 16/5/3.
//  Copyright © 2016年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QMSegmentIconTitleItem : UIButton

@property (nonatomic, strong) UIImageView *iconImageView;

@property (nonatomic, strong) UILabel *titleLbl;

@property (nonatomic, strong) UIImageView *typeImageView;


@property (nonatomic, strong) UILabel *typeLabel;

@property (nonatomic, copy) NSString *selectedBGColor;

@property (nonatomic, copy) NSString *normalBGColor;

@property (nonatomic) NSInteger cornerMaskType;

@end
