//
//  QMSementGradualItemView.h
//  juanpi3
//
//  Created by Alvin on 2017/11/16.
//  Copyright © 2017年 Alvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMSegmentMenuModel.h"
@interface QMSegmentGradualItemView : UIButton

/**
 渐变度
 */
@property (nonatomic, assign) CGFloat gradient;

- (instancetype)initWithFrame:(CGRect)frame item:(QMSegmentMenuModel *)item;
- (void)refreshItem:(QMSegmentMenuModel *)item;

@end

