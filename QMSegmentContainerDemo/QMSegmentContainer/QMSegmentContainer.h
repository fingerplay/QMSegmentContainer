//
//  QMSegmentContainer.h
//  juanpi3
//
//  Created by finger on 15-1-6.
//  Copyright (c) 2015年 finger. All rights reserved.
//
/**
 *  顶部有选项条，每个选项对应不同内容的控件。
 *  使用时只需要通过代理提供总的选项数，每个选项的标题，及每个选项对应显示的内容控件，配置好需要需要的参数即可。
 */

#import <UIKit/UIKit.h>
#import "QMSegmentTopBar.h"
#import "QMSegmentScrollview.h"

@protocol QMSegmentContainerDelegate;
@interface QMSegmentContainer : UIView

@property (nonatomic, assign) BOOL shouldScrollAnimate;
/** 主容器 */
@property (nonatomic, strong) QMSegmentScrollview *containerView;

/** bar是否在底部，默认在顶部 */
@property (nonatomic, assign) BOOL isBottomBar;

/** 内容背景颜色 */
@property (nonatomic, strong) UIColor *containerBackgroundColor;

/**  顶部选项条的高度，默认和首页高度相同 */
@property (nonatomic, assign) CGFloat topBarHeight;
/**  顶部选项条背景颜色，默认是白色 */
@property (nonatomic, strong) UIColor *topBarBgColor;

/**
 顶部菜单选中指示器的颜色
 */
@property (nonatomic, strong) UIColor *indicatorColor;
/**
 *  是否可以通过滑动来切换选项，默认为YES
 */
@property (nonatomic, assign) BOOL allowGesture;

/**
 *  是否显示副标题，默认为NO
 */
//@property (nonatomic, assign) BOOL isShowSubTitle;

/** 上一次的index */
@property (nonatomic, assign, readonly) NSInteger lastIndex;

/**
 *  获取当前选中项的index
 */
@property (atomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) BOOL topBarHidden;

/**
 *  默认选中项的index,由服务器下发,缓存在Cache里
 */
@property (nonatomic, assign) NSInteger defaultIndex;
/**
 *  获取当前选中项的index,循环时为 currentIndex % 原item数量
 */
@property (nonatomic, assign, readonly) NSInteger safeCurrentIndex;

@property (nonatomic, assign, readonly) NSInteger safeLastIndex;
/**
 *  如果在代理方法- (id)segmentContainer:(QMSegmentContainer *)segmentContainer contentForIndex:(NSInteger)index;中返回的是UIViewController类型，再设置该属性时，会将代理提供的viewController添加为该属性的childViewController,这样在viewController中使用self.navigationController方法得到的就是parentVC.navigationController。
 */
@property (nonatomic, weak) UIViewController *parentVC;
@property (nonatomic, weak) id<QMSegmentContainerDelegate> delegate;

/**
 *  顶部的视图
 */
@property (nonatomic, strong) QMSegmentTopBar *segmentTopBar;

@property (nonatomic, strong) UIView<QMSegmentTopBarProtocol> *topBar;

/**
 *  类目页需求。当顶部项大于10个时，右边显示下拉箭头，点击显示下拉菜单
 */
@property (nonatomic, strong) NSArray *catogryArray;
/**
 *  是否进行预加载
 */
@property (nonatomic, assign) BOOL isPreLoad;
/**
 *  是否需要动弹效果
 */
@property (nonatomic, assign) BOOL bounces;

@property (nonatomic, assign, readonly) BOOL isTopBarOnWindow;

/**
 *  首页滑到底部切换tab
 */
- (void)switchTab;

/**
 *  手动设置选中的项
 *
 *  @param index    要选择项的index
 *  @param animated 切换过程是否使用动画
 */
- (void)setSelectedIndex:(NSInteger)index withAnimated:(BOOL)animated;

/**
 *  重新加载加载内容
 */
- (void)reloadData;

/**
 *  添加content到index签名，content内容从Delegate方法中根据index获取
 */
- (void)addContentAtIndex:(NSInteger)index;

/**
 *  删除指定位置的content
 */
- (void)removeContentAtIndex:(NSInteger)index;

/**
 *  获取第index项的内容
 *
 *  @param index 序号
 *
 *  @return index项对应的UIView或UIViewController对象
 */
- (id)contentAtIndex:(NSInteger)index;
#pragma mark -
/**
 *  在顶部topBar上添加自定义视图
 *
 *  @param customView 自定义视图
 *  @param onRight    视图位置，为yes在最右边，否则在最左边
 */
//- (void)addCustomViewToTopBar:(UIView *)customView onRight:(BOOL)onRight;

- (void)setTopBarEnable:(BOOL)enable;

/**
 重置当前segment的index到默认位置
 */
- (void)resetToDefaultIndex;


- (void)reloadContainerView;
@end




@protocol QMSegmentContainerDelegate <QMSegmentTopBarDelegate>
/**
 *  返回在第index项需要显示的内容，支持UIView和UIViewController类型，返回UIViewConroller类型时建议提供parentVC属性，parentVC应该是包含该控件的UIViewController对象
 *  该方法每次reloadData后只会调用一次，调用时间为第一次切换到第index、index-1或都index+1项时
 *
 *  @param segmentContainer segmentContainer description
 *  @param index            项的序号
 *
 *  @return 返回在第index项需要显示的内容
 */
- (id)segmentContainer:(QMSegmentContainer *)segmentContainer contentForIndex:(NSInteger)index;
@optional

/**
 是否 循环

 @param segmentContainer segmentContainer description
 @return return value description
 */
- (BOOL)shouldRecycleContainer:(QMSegmentContainer *)segmentContainer;
- (NSInteger)numberOfItemsInSegmentContainer:(QMSegmentContainer *)segmentContainer;

/**
 *  该方法每次reloadData后只会调用一次，调用时间为第一次切换到第index、index-1或者index+1项时
 *
 *  @param segmentContainer segmentContainer description
 *  @param index            项的序号
 */
- (void)segmentContainer:(QMSegmentContainer *)segmentContainer preDisplayItemAtIndex:(NSInteger)index;

/**
 *  选中第index项时的回调,每次切换(不论是滑动还是点击切换都会调用)到第index项都会调用该方法
 *
 *  @param segmentContainer segmentContainer description
 *  @param index            项的序号
 */
- (void)segmentContainer:(QMSegmentContainer *)segmentContainer didSelectedItemAtIndex:(NSInteger)index;

/**
 *  每次滑动切换到第index项时调用
 *
 *  @param segmentContainer segmentContainer description
 *  @param index            index description
 */
- (void)segmentContainer:(QMSegmentContainer *)segmentContainer didSlideToItemAtindex:(NSInteger)index;

- (void)segmentContainer:(QMSegmentContainer *)segmentContainer didScrollRectAccordingIndex:(CGFloat)index delta:(CGFloat)delta isScrollToRight:(BOOL)scrollToRight;

/**
 *  每次点击切换到第index项时调用
 *
 *  @param segmentContainer segmentContainer description
 *  @param index            index description
 */
- (void)segmentContainer:(QMSegmentContainer *)segmentContainer didClickedItemAtIndex:(NSInteger)index;

/**
 *  每次完成reloadData后都会调用
 *
 *  @param segmentContainer segmentContainer description
 */
- (void)segmentContainerDidReloadData:(QMSegmentContainer *)segmentContainer;

@end
