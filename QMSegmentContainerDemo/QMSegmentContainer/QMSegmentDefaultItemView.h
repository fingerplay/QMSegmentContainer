//
//  QMSegmentDefaultItemView.h
//  juanpi3
//
//  Created by finger on 16/7/5.
//  Copyright © 2016年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMSegmentMenuModel.h"

@protocol QMSegmentDefaultItemViewDelegate <NSObject>
-(void)defaultItemViewDownLoadSuccess;
@end

@interface QMSegmentDefaultItemView : UIButton
@property (nonatomic, strong) UIButton *itemImageButton;
@property (nonatomic, strong) UIButton *itemTitleButton;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) QMSegmentMenuModel *item;
@property (nonatomic, strong) UIImageView *redPointView;
@property (nonatomic, weak) id<QMSegmentDefaultItemViewDelegate> delegate;
@property (nonatomic, strong) UILabel *markTag;

- (instancetype)initWithFrame:(CGRect)frame item:(QMSegmentMenuModel *)item isCanShowPopupMenu:(BOOL)isCanShowPopupMenu;

/**
 平分模式 重置内部视图
 */
- (void)averageItemView;
@end
