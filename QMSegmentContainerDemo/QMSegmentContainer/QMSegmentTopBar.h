//
//  QMSegmentTopBar.h
//  juanpi3
//
//  Created by Alvin on 16/6/3.
//  Copyright © 2016年 Alvin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMSegmentMenuModel.h"
#import "QMSegmentTopBarDelegate.h"
#import "QMSegmentTopBarProtocol.h"

#define itemCorner_width 20
#define itemCorner_height 10 //14
#define appletHeight 52

NS_ASSUME_NONNULL_BEGIN
@interface QMSegmentTopBar : UIView<QMSegmentTopBarProtocol>
- (instancetype)initWithFrame:(CGRect)frame topBarHeight:(CGFloat )topBarHeight;
@end
NS_ASSUME_NONNULL_END
