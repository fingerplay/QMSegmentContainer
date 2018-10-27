//
//  QMSegmentTopBarProtocol.h
//  juanpi3
//
//  Created by Alvin on 2017/11/17.
//  Copyright © 2017年 Alvin. All rights reserved.
//

@protocol QMSegmentTopBarDelegate;
@protocol QMSegmentTopBarProtocol<NSObject>

/** 如果该值为YES，则会忽略对顶部选项条的所有配置的间隔值，且选项条与父视图同宽，不能滑动，对选项条进行平均分割，即每一个选项的宽度相同。
 平均分割模式下不支持角标。默认为NO。 */
@property (nonatomic, assign) BOOL averageSegmentation;
/**按钮在tabar居中显示*/
@property (nonatomic, assign) BOOL isAlignmentCenter;
/** 顶部选项文字正常颜色，默认和首页对应颜色相同 */
@property (nonatomic, strong) UIColor *titleNormalColor;
/** 顶部选项文字选中时的颜色,默认和首页对应颜色相同 */
@property (nonatomic, strong) UIColor *titleSelectedColor;
/** 顶部文字字体大小 */
@property (nonatomic, strong) UIFont *titleFont;
/** 顶部选中字体大小 */
@property (nonatomic, strong) UIFont *titleSelectedFont;
/** 内容背景颜色 */
@property (nonatomic, strong) UIColor *containerBackgroundColor;
/** 顶部菜单底部的线条颜色 */
@property (nonatomic, strong) UIColor *bottomLineColor;
/** 顶部菜单底部的线条高度 */
@property (nonatomic, assign) CGFloat bottomLineHeight;
/**  标记选中状态的红线超出文字的宽度 */
@property (nonatomic, assign) CGFloat indicatorOffset;
/**  标记选中的红线的高度 */
@property (nonatomic, assign) CGFloat indicatorHeight;
/**  标记选中的红线的离底部的间距 */
@property (nonatomic, assign) CGFloat indicatorBottomPadding;
/** 指示器颜色 */
@property (nonatomic, strong) UIColor *indicatorColor;
/**  顶部选中项下边沿红标记条的最小宽度，默认为0（宽度和控件宽度相等，但比该属性小时会取该属性的值） */
@property (nonatomic, assign) CGFloat minIndicatorWidth;
/**  顶部条背景颜色*/
@property (nonatomic, strong) UIColor *bgColor;
/**
 *  顶部选项条左边秋右边的缩进量，默认为itemPadding的二分之一。根据选项数，间距和缩进进行调整超过屏幕宽度时顶部选项条可以进行左右滑动，未超过且expandToTopBarWidth为yes时，则忽略该属性和itemPadding属性，重新计算间距以铺满topBar的宽度。
 */
@property (nonatomic, assign) CGFloat horizontalInset;

/**
 *  顶部选项条选项之间的间距,默认为20,该值不包含选项控件本身两边沿距文字的距离。根据选项数，间距和缩进进行调整超过屏幕宽度时顶部选项条可以进行左右滑动，未超过且expandToTopBarWidth为yes时，则忽略该属性和horizontalInset属性，重新计算间距以铺满topBar的宽度。
 */
@property (nonatomic, assign) CGFloat itemPadding;

/**该参数为YES时，topBar上元素较少时，会重新计算间距，使之铺满整个topBar的宽度；为NO时不会铺满整个topBar的宽度。默认为YES。
 */
@property (nonatomic, assign) BOOL expandToTopBarWidth;

/** 是否显示副标题，默认为NO*/
@property (nonatomic, assign) BOOL isShowSubTitle;
/** 上一次的index */
@property (nonatomic, assign, readonly) NSInteger lastIndex;
/** 获取当前选中项的index */
@property (nonatomic, assign, readonly) NSInteger currentIndex;
/** 默认选中项的index,由服务器下发,缓存在Cache里*/
@property (nonatomic, assign) NSInteger defaultIndex;

/**
 *  类目页需求。当顶部项大于10个时，右边显示下拉箭头，点击显示下拉菜单
 */
@property (nonatomic, strong) NSArray *catogryArray;


@property (nonatomic, strong) UIImageView *indicatorView;

/**
 *  弹出菜单按钮
 */
@property (nonatomic, strong) UIButton *popupMenuBtn;

/**
 *  是否是带图模式(默认不带)
 */
@property (nonatomic) BOOL isShowImg;

/**
 * 是否 渐变
 */
@property (nonatomic, assign) BOOL isGradual;

/**
 *  单个菜单是否显示MenuBar
 */
@property (nonatomic,assign)BOOL onlyOneShow;

/**
 topbar默认高度
 */
@property (nonatomic,strong)NSNumber *topBarHeight;

/**
 *  代理
 */
@property (nonatomic, weak) id<QMSegmentTopBarDelegate> delegate;

/**
 *  点击按钮的回调事件
 */
@property (nonatomic, copy) void (^didSeleteItemAtIndex)(NSInteger seletedIndex);

/**
 *  是否可以显示图片
 */
- (BOOL)isCanShowImg;



#pragma mark - 设置角标
@optional
/**
 *  手动设置选中的项
 *
 *  @param index    要选择项的index
 *  @param animated 切换过程是否使用动画
 */
- (void)setSelectedIndex:(NSInteger)index withAnimated:(BOOL)animated;
/**
 *  滑动到某一项
 */
- (void)scrollToItemAtIndex:(NSInteger)index withAnimation:(BOOL)animation slide:(BOOL)slide canCallBack:(BOOL)callBack;

- (void)scrollToRectWithIndex:(NSInteger)index delta:(CGFloat)delta isScrollToRight:(BOOL)scrollToRight;

//- (void)scrollToRect

/**
 *  重新加载加载内容
 */
- (void)reloadData;

- (void)menuTapped;

/**
 *  为第index项设置角标，通过该方法设置的角标在reloadData后不会保留。
 *
 *  @param content 可以为UIImage对象，也可是图片地址NSString对象
 *  @param index   序号
 */
- (void)setCornerMark:(id)content forItemAtIndex:(NSInteger)index;
/**
 *  移除第index项顶部的标题右上角角标。
 *
 *  @param index 序号
 */
- (void)removeCornerMarkForItemAtIndex:(NSInteger)index;

@end
