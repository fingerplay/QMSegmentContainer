//
//  QMSegmentContainer.m
//  juanpi3
//
//  Created by finger on 15-1-6.
//  Copyright (c) 2015年 finger. All rights reserved.
//

#import "QMSegmentContainer.h"
#import "QMSegmentScrollview.h"
#import "QMSegmentIconTitleItem.h"
#import "QMSegmentDoubleTitleItem.h"
#import "QMSegmentDefaultItemView.h"
#import "QMDeviceHelper.h"
#import "ViewFrameAccessor.h"

#define itemView_start_tag 111

#define itemCorner_start_tag 222

#define itemTag_start_tag 333 //自定义角标tag的起始值

@interface QMSegmentContainer ()<UIScrollViewDelegate>
{
    BOOL _didLoadData;
    NSInteger _curIndex;
    CGFloat _lastOffsetX;
}

@property (nonatomic, assign) NSInteger topItemCount;
@property (nonatomic, assign) NSInteger orignContentCount;
@property (nonatomic, assign) NSInteger contentItemCount;
@property (nonatomic, strong, readwrite) NSMutableDictionary *contentsDic;//存储内容文件
@property (nonatomic, strong) NSMutableArray *appearingViewControllers;//处于appearing状态的contents
@property (nonatomic, strong) NSMutableDictionary *pageStartTimeDictionary;
/**
 *  只要包含纯文本形式则显示下划线
 */
@property (nonatomic, assign)BOOL isShowLine;
@property (nonatomic, assign)QMSegmentMenuType menuType;
@property (nonatomic, assign) BOOL isRecycle;


@end


@implementation QMSegmentContainer

-(void)dealloc{
    [_pageStartTimeDictionary removeAllObjects];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _topBarHeight = ScreenScale() == 3 ? Scale(126) : 40;//顶部选项条默认高度,区分2x和3x
        self.allowGesture = YES;//默认可以通过滑动来切换选项
        
        _containerBackgroundColor = [UIColor whiteColor];
        
        _lastIndex = -1;
        _shouldScrollAnimate = YES;
        _pageStartTimeDictionary = [[NSMutableDictionary alloc] init];
        _isTopBarOnWindow = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.segmentTopBar];
        [self addSubview:self.containerView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!_didLoadData) {
        _didLoadData = YES;
        [self reloadData];//在layoutsubview中(本控件第一次显示时)调用reloadData可以保证reload时，所依赖的视图大小都已是实际显示大小。
    }
    if (self.isBottomBar) {
        if (self.segmentTopBar.hidden) {
            self.containerView.frame = CGRectMake(0, 0, self.width, self.height);
        }else {
            self.containerView.frame = CGRectMake(0, 0, self.width, self.height - self.segmentTopBar.height);
        }
    
        if (self.isTopBarOnWindow) {
            self.segmentTopBar.frame = CGRectMake(0, SCREEN_HEIGHT-self.topBarHeight, self.width, self.topBarHeight);
        }else{
            self.segmentTopBar.frame = CGRectMake(0, self.height-self.topBarHeight, self.width, self.topBarHeight);
        }
        
    }else {
        self.containerView.frame = CGRectMake(0, self.segmentTopBar.bottom, self.width, self.height - self.segmentTopBar.height);
        self.segmentTopBar.frame = CGRectMake(0, 0, self.width, self.topBarHeight);
    }
    
    self.containerView.contentSize = CGSizeMake(self.containerView.contentSize.width, self.containerView.height);
    
    
    id otherView = [self.contentsDic objectForKey:[self savedKeyForContentAtIndex:self.currentIndex]];
    UIView *view;
    if ([otherView isKindOfClass:[UIView class]]) {
        view = otherView;
    }else if ([otherView isKindOfClass:[UIViewController class]]){
        view = [(UIViewController *)otherView view];
    }
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft
        || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        view.frame = CGRectMake(0, 0, self.containerView.width, self.containerView.height);
        CGPoint containOffset = CGPointMake(0, 0);
        self.containerView.contentOffset = containOffset;
    }else {
        view.frame = CGRectMake(self.currentIndex*self.containerView.width, 0, self.containerView.width, self.containerView.height);
        CGPoint containOffset = CGPointMake(self.currentIndex*self.containerView.width, 0);
        self.containerView.contentOffset = containOffset;
    }
}


- (void)setTopBarEnable:(BOOL)enable
{
    self.segmentTopBar.userInteractionEnabled = enable;
    for (UIView *view in self.segmentTopBar.subviews) {
        view.userInteractionEnabled = enable;
    }
}

-(void)setBounces:(BOOL)bounces{

    self.containerView.bounces = bounces;
}

#pragma mark - ReloadData

- (void)reloadData
{
    if (!_didLoadData || !self.delegate || ![self.delegate respondsToSelector:@selector(numberOfItemsInTopBar:)] || ![self.delegate respondsToSelector:@selector(segmentContainer:contentForIndex:)]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(shouldRecycleContainer:)]) {
        self.isRecycle = [self.delegate shouldRecycleContainer:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(menuTypeOfItemsInSegmentTopBar:)]) {
        self.menuType = [self.delegate menuTypeOfItemsInSegmentTopBar:self.topBar];
        
        if (self.isRecycle) {
            if (self.menuType == QMSegmentMenuFullPicType) {
                self.topBarHeight = 48;
            }else{
                self.topBarHeight = 40;
            }
        }
        
    }
    
    self.topItemCount = [self.delegate numberOfItemsInTopBar:self.segmentTopBar];
    self.orignContentCount = [self.delegate numberOfItemsInTopBar:self.segmentTopBar];
    if ([self.delegate respondsToSelector:@selector(numberOfItemsInSegmentContainer:)]) {
        self.orignContentCount = [self.delegate numberOfItemsInSegmentContainer:self];
    }
   
    self.contentItemCount =  self.orignContentCount;
    
    self.segmentTopBar.delegate = self.delegate;
    self.segmentTopBar.topBarHeight = @(self.topBarHeight);
    [self.segmentTopBar reloadData];
//    [self reloadContainerView];
    [self reloadContainerViewWithOutContentAtIndex:0];

    //defaultIndex只在选中的是非第一个选项并且currentIndex小于1的情况下生效
    NSInteger delta = 0;
    if (self.defaultIndex && !self.currentIndex) {
        _currentIndex = self.defaultIndex;
    }
    
    if (!self.currentIndex || self.currentIndex >= self.contentItemCount) {
        _currentIndex = 0;
    }
    _currentIndex += delta;
    [self setSelectedIndex:self.currentIndex withAnimated:NO];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentContainerDidReloadData:)]) {
        [self.delegate segmentContainerDidReloadData:self];
    }
}

- (void)reloadContainerView
{
    [self.appearingViewControllers removeAllObjects];
    
    for (UIView *subView in self.containerView.subviews) {
        [subView removeFromSuperview];
    }
    if (self.parentVC) {
        for (UIViewController *child in self.parentVC.childViewControllers) {
            [child removeFromParentViewController];
        }
    }
    
    [self.contentsDic removeAllObjects];
    if (self.isBottomBar) {
        self.containerView.frame = CGRectMake(0, 0, self.width, self.height - self.segmentTopBar.height);
    }else{
        self.containerView.frame = CGRectMake(0, self.segmentTopBar.bottom, self.width, self.height - self.segmentTopBar.height);
    }
    self.containerView.contentSize = CGSizeMake(self.contentItemCount * self.containerView.width, self.containerView.height);
    
}

- (void)reloadContainerViewWithOutContentAtIndex:(NSInteger)index
{
//    [self.appearingViewControllers removeAllObjects];
    id remainContent = [self contentAtIndex:index];
    
    for (NSInteger i=0; i<self.appearingViewControllers.count; i++) {
        UIViewController *vc = [self.appearingViewControllers objectAtIndex:i];
        if (vc != remainContent) {
            i --;// index 恢复 防止跳过下一个数据。
            [self.appearingViewControllers removeObject:vc];
        }
    }
    
    NSArray *subviews = self.containerView.subviews;
    for (NSInteger i=0; i<subviews.count; i++) {
        UIView *view = [subviews objectAtIndex:i];
        if (view.left/self.containerView.width != index) {
            NSLog(@"remove subview:%@ atindex:%ld",view,i);
            [view removeFromSuperview];
        }
    }
    

    if (self.parentVC) {
        for (NSInteger i=0; i<self.parentVC.childViewControllers.count;i++) {
            UIViewController *child = [self.parentVC.childViewControllers objectAtIndex:i];
            if (child != remainContent) {
                [child removeFromParentViewController];
            }
        }
    }
    
    NSArray *keys = self.contentsDic.allKeys;
    for (NSInteger i=0; i<keys.count; i++) {
        NSString *key = [keys objectAtIndex:i];
        id content = [self.contentsDic objectForKey:key];
        if (content && content != remainContent) {
            NSLog(@"remove content:%@ ",content);
            [self.contentsDic removeObjectForKey:key];
        }
    }
//    [self.contentsDic removeAllObjects];
    
    if (self.isBottomBar) {
        self.containerView.frame = CGRectMake(0, 0, self.width, self.height - self.segmentTopBar.height);
    }else{
        self.containerView.frame = CGRectMake(0, self.segmentTopBar.bottom, self.width, self.height - self.segmentTopBar.height);
    }
    self.containerView.contentSize = CGSizeMake(self.contentItemCount * self.containerView.width, self.containerView.height);
    
}

#pragma mark - Item switch

- (void)switchTab
{
    [self scrollToItemAtIndex:++_curIndex withAnimation:YES slide:NO isClick:NO];
}

- (void)activeIndex:(NSInteger)index {
    [self willScrollToIndex:index];//在需要的时候添加视图
    
    NSUInteger oldIndex = self.currentIndex;
    _lastIndex = _currentIndex;
    _currentIndex = index;
    _curIndex = index;
    
    [self setContentAtIndex:oldIndex scrollsToTop:NO];
    [self setContentAtIndex:index scrollsToTop:YES];
}

- (void)scrollToItemAtIndex:(NSUInteger)index withAnimation:(BOOL)animation slide:(BOOL)slide isClick:(BOOL)isClick
{
    if (index >= self.contentItemCount) {
        NSLog(@"切换的index[%ld]超出范围！ contentItemCount:%ld",index,self.contentItemCount);
        return;
    }
    id fromVC = [self contentAtIndex:self.currentIndex];

    if ([fromVC isKindOfClass:[UIViewController class]] && [self.appearingViewControllers containsObject:fromVC]) {
        [(UIViewController*)fromVC beginAppearanceTransition:NO animated:animation];
    }
    
    if (fromVC && self.delegate && [self.delegate respondsToSelector:@selector(segmentContainer:willUnSelectedItemAtIndex:)]) {
        [self.delegate segmentContainer:self willUnSelectedItemAtIndex:self.currentIndex];
    }
    
    [self activeIndex:index];
    CGPoint containOffset = CGPointMake(index*self.containerView.width, 0);
    if(isClick){
        if (self.delegate && [self.delegate respondsToSelector:@selector(segmentContainer:didClickedItemAtIndex:)]) {
            [self.delegate segmentContainer:self didClickedItemAtIndex:index];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentContainer:didSelectedItemAtIndex:)]) {
        //注意这里toVC对应的页面会初始化，然后被addSubView到containerView上，并执行viewWillAppear，相当于执行了beginAppearanceTransition
        [self.delegate segmentContainer:self didSelectedItemAtIndex:index];
    }
    
    //这里如果提前把toVC取出来了，可能是为空的，导致beginAppearanceTransition和endAppearanceTransition不被调用，从而不配对。所以必须要在页面初始化以后再取toVC
    id toVC = [self contentAtIndex:index];
    if (([toVC isKindOfClass:[UIViewController class]]) && ![self.appearingViewControllers containsObject:toVC]) {
        [(UIViewController*)toVC beginAppearanceTransition:YES animated:animation];
    }
    
    if (animation && self.shouldScrollAnimate) {
        __weak typeof(self) wSelf = self;
        [UIView animateWithDuration:0.25 animations:^{
            __strong typeof(wSelf) sSelf = self;
            sSelf.containerView.contentOffset = containOffset;
        } completion:^(BOOL finished) {
            __strong typeof(wSelf) sSelf = self;
            [sSelf didScrollToItemAtIndex:(index % sSelf.orignContentCount) slide:slide click:isClick];
//            [sSelf.topBar scrollToItemAtIndex:index withAnimation:animation slide:slide canCallBack:NO];
           
            if ([fromVC isKindOfClass:[UIViewController class]] && [self.appearingViewControllers containsObject:fromVC]) {
                [(UIViewController*)fromVC endAppearanceTransition];
                [self.appearingViewControllers removeObject:fromVC];
            }
            
            if (([toVC isKindOfClass:[UIViewController class]]) && ![self.appearingViewControllers containsObject:toVC]) {
                [(UIViewController*)toVC endAppearanceTransition];
                [self.appearingViewControllers addObject:toVC];
            }
        }];
    }
    else{
        if ([fromVC isKindOfClass:[UIViewController class]] && [self.appearingViewControllers containsObject:fromVC]) {
            [(UIViewController*)fromVC endAppearanceTransition];
            [self.appearingViewControllers removeObject:fromVC];
        }
        
        if (([toVC isKindOfClass:[UIViewController class]]) && ![self.appearingViewControllers containsObject:toVC]) {
            [(UIViewController*)toVC endAppearanceTransition];
            [self.appearingViewControllers addObject:toVC];
        }
        [self.segmentTopBar scrollToItemAtIndex:index withAnimation:animation slide:slide canCallBack:NO];
        self.containerView.contentOffset = containOffset;
        [self didScrollToItemAtIndex:(index % self.orignContentCount) slide:slide click:isClick];
 

    }
}

- (void)didScrollToItemAtIndex:(NSUInteger)index slide:(BOOL)slide click:(BOOL)click{
    
    if (slide) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(segmentContainer:didSlideToItemAtindex:)]) {
            [self.delegate segmentContainer:self didSlideToItemAtindex:index];
        }
    }
}

- (void)willScrollToIndex:(NSUInteger)index
{
    //做视图预加载
    [self addContentAtIndex:index preDisplay:NO];
    
    if (self.isPreLoad) {
        [self addContentAtIndex:index - 1 preDisplay:YES];
        [self addContentAtIndex:index + 1 preDisplay:YES];
    }
   
}

- (void)addContentAtIndex:(NSInteger)index preDisplay:(BOOL)isPreDisplay
{
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(segmentContainer:contentForIndex:)]) {
        return;
    }
    
    if (index < 0 || index >= self.contentItemCount) {
        return;
    }
    
    id content = [self.contentsDic objectForKey:[self savedKeyForContentAtIndex:index]];
    if (content) {
        [self resetContent:content atIndex:index preDisplay:isPreDisplay];
    }
    else{
        [self doAddContentAtIndex:index preDisplay:isPreDisplay];
    }
}

- (void)addContentAtIndex:(NSInteger)index {

    NSLog(@"add begin: index:%ld content dic:%@",index,self.contentsDic);
    //如果添加的不是最后一个，需要移动它之后其他子视图的位置
    if (index>=0 && index < self.contentItemCount) {
        for (NSInteger i=self.contentItemCount - 1; i>= index; i--) {
            id otherView = [self.contentsDic objectForKey:[self savedKeyForContentAtIndex:i]];
            [self resetContent:otherView atIndex:i+1 preDisplay:NO];
            [self.contentsDic removeObjectForKey:[self savedKeyForContentAtIndex:i]];
            NSLog(@"add index:%ld content dic:%@",i,self.contentsDic);
        }
    }
    
    //往index前面添加
    [self doAddContentAtIndex:index preDisplay:NO];
    self.contentItemCount++ ;
    NSLog(@"add contentItemCount:%ld",self.contentItemCount);
    self.containerView.contentSize = CGSizeMake((self.contentItemCount) * self.containerView.width, self.containerView.height);
    
    [self.segmentTopBar reloadData];
    
    //如果添加的设备在当前选中的设备之前，则选中的设备需要往后顺移一位
    if (index <= self.currentIndex) {
        self.currentIndex ++ ;
        [self scrollToItemAtIndex:self.currentIndex withAnimation:NO slide:NO isClick:NO];
    }
    
}

- (void)removeContentAtIndex:(NSInteger)index {
    if (index <0 ||index >= self.contentItemCount ) {
        NSLog(@"remove failed contentItemCount:%ld",self.contentItemCount);
        return;
    }
    
    NSLog(@"remove content dic:%@ at index:%ld",self.contentsDic,index);
    id content = [self.contentsDic objectForKey:[self savedKeyForContentAtIndex:index]];

    if ([content isKindOfClass:[UIView class]]) {
        [content removeFromSuperview];
    }else if ([content isKindOfClass:[UIViewController class]]){
        UIViewController *vc = content;
        [self.appearingViewControllers removeObject:content];
        [vc.view removeFromSuperview];
        [vc willMoveToParentViewController:self.parentVC];
        [vc removeFromParentViewController];
        [vc didMoveToParentViewController:self.parentVC];
    }

    self.containerView.contentSize = CGSizeMake((self.contentItemCount - 1) * self.containerView.width, self.containerView.height);
    [self.contentsDic removeObjectForKey:[self savedKeyForContentAtIndex:index]];
    //如果删除的不是最后一个，需要它之后其他子视图的位置往前移动一位
    if (index>=0 && index < self.contentItemCount - 1) {
        for (NSInteger i=index+1; i<self.contentItemCount; i++) {
            id otherView = [self.contentsDic objectForKey:[self savedKeyForContentAtIndex:i]];
            
            [self resetContent:otherView atIndex:i-1 preDisplay:NO];
            
            //把之前的删除，避免重复
            [self.contentsDic removeObjectForKey:[self savedKeyForContentAtIndex:i]];
            
//            if ([otherView isKindOfClass:[UIView class]]) {
//                [otherView setNeedsLayout];
//            }else if ([otherView isKindOfClass:[UIViewController class]]){
//                [((UIViewController*)otherView).view setNeedsLayout];
//            }
           
            NSLog(@"remove index:%ld content dic:%@",i,self.contentsDic);
        }
    }
    

    if (content) {
        //删除最后一个品类
        [self.contentsDic removeObjectForKey:[self savedKeyForContentAtIndex:self.contentItemCount-1]];
        self.contentItemCount --;
        NSLog(@"remove contentItemCount:%ld",self.contentItemCount);
    }
  
    [self.segmentTopBar reloadData];
//    self.currentIndex = index>0 ? index - 1 : 0;
    if (index<=self.currentIndex) {
        self.currentIndex --;
        if (self.currentIndex<0) {
            self.currentIndex = 0;
        }
        [self scrollToItemAtIndex:self.currentIndex withAnimation:NO slide:NO isClick:NO];
    }
}

- (void)resetContent:(id)content atIndex:(NSUInteger)index preDisplay:(BOOL)isPreDisplay{
    UIView *view = nil;
    if ([content isKindOfClass:[UIView class]]) {
        view = content;
    }else if ([content isKindOfClass:[UIViewController class]]){
        view = [(UIViewController *)content view];
    }
    if (view.left != index*self.containerView.width) {
        view.frame = CGRectMake(index*self.containerView.width, 0, self.containerView.width, self.containerView.height);
    }
    if (!view.superview) {
        [self.containerView addSubview:view];
    }
    [self.contentsDic setObject:content forKey:[self savedKeyForContentAtIndex:index]];
}

- (id)doAddContentAtIndex:(NSUInteger)index preDisplay:(BOOL)isPreDisplay{
    id content = [self.delegate segmentContainer:self contentForIndex:index];
    
    if (content) {
        [self.contentsDic setObject:content forKey:[self savedKeyForContentAtIndex:index]];
        if ([content isKindOfClass:[UIView class]]) {
            UIView *contentView = (UIView *)content;
            contentView.frame = CGRectMake(index*self.containerView.width, 0, self.containerView.width, self.containerView.height);
            contentView.autoresizingMask |= UIViewAutoresizingFlexibleHeight;
            [self.containerView addSubview:contentView];
        }
        else if ([content isKindOfClass:[UIViewController class]]){
            UIViewController *vc = (UIViewController *)content;
            
            vc.view.frame = CGRectMake(index*self.containerView.width, 0, self.containerView.width, self.containerView.height);
            [self.containerView addSubview:vc.view];
            [self.appearingViewControllers addObject:vc];
            if (self.parentVC) {
                [vc willMoveToParentViewController:self.parentVC];
                [self.parentVC addChildViewController:vc];
                [vc didMoveToParentViewController:self.parentVC];
            }
        }
        
        [self setContentAtIndex:index scrollsToTop:NO];//默认scrollsTotop为NO，只有当显示时才为YES
        if(isPreDisplay){
            if (self.delegate && [self.delegate respondsToSelector:@selector(segmentContainer:preDisplayItemAtIndex:)]) {
                [self.delegate segmentContainer:self preDisplayItemAtIndex:index];
            }
        }
    }
    return content;
}

- (NSString *)savedKeyForContentAtIndex:(NSUInteger)index
{
    index = self.isRecycle ? index % self.orignContentCount : index;
    return [NSString stringWithFormat:@"%lu",(unsigned long)index];
}

#pragma mark - 重置segment到默认位置
- (void)resetToDefaultIndex{
    if (_currentIndex % self.orignContentCount == 0 || !self.isRecycle) return;
    // 当前所处的区域是否 偏右
    BOOL isCurrentIndexInRightRange = (_currentIndex % self.orignContentCount - self.orignContentCount / 2) >= 0;
//    NSInteger dif = _currentIndex % self.orignContentCount;
    NSInteger proposeIndex = 0;
    NSInteger proposeLeftIndex = _currentIndex - _currentIndex % self.orignContentCount;
    NSInteger proposeRightIndex = _currentIndex + self.orignContentCount - _currentIndex % self.orignContentCount;
    if (isCurrentIndexInRightRange) {
        proposeIndex = proposeRightIndex;
    } else {
        proposeIndex = proposeLeftIndex;
    }
    
    if (proposeLeftIndex <= self.orignContentCount) {
        proposeIndex = proposeRightIndex;
    }
    
//    if (proposeRightIndex >= self.orignContentCount * (CAROUSEL_RECYCLE_COUNT - 1)) {
//        proposeIndex = proposeLeftIndex;
//    }
    [self activeIndex:proposeIndex];
    [self.containerView setContentOffset:CGPointMake(proposeIndex*self.width, 0) animated:true];
//    [self scrollToItemAtIndex:proposeIndex withAnimation:true slide:true];
}

- (void)moveTopBarToWindow {
    [self.topBar removeFromSuperview];
    UIView *layoutContainerView = [[[self.superview viewController] navigationController] view];
    [layoutContainerView addSubview:self.topBar];
    [layoutContainerView bringSubviewToFront:self.topBar];
    
    if (self.isBottomBar) {
        self.topBar.bottom = SCREEN_HEIGHT;
    }
    _isTopBarOnWindow = YES;
}

- (void)resetTopBarPosition {
    [self.topBar removeFromSuperview];
    [self addSubview:self.topBar];
    if (self.isBottomBar) {
        self.topBar.bottom = self.height;
    }
    _isTopBarOnWindow = NO;
}

- (void)setTopBarHidden:(BOOL)topBarHidden {
    _topBarHidden = topBarHidden;
    if (topBarHidden) {
        self.segmentTopBar.hidden = YES;
        self.containerView.height = self.height;
    }else{
        self.segmentTopBar.hidden = NO;
        self.containerView.height = self.height - self.topBarHeight;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.x <= 0 || !self.isRecycle) return;
    
    CGFloat offsetX = scrollView.contentOffset.x;
    BOOL isScrollToRight = offsetX > _lastOffsetX;
    NSInteger page = offsetX / scrollView.width;
    if (!isScrollToRight) {
        // 左滑 page整形需+1才能取到当前page
        page += 1;
    }
    // 滑动所占页面的比例
    CGFloat delta = ABS(offsetX - scrollView.width * page) / scrollView.width;

    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentContainer:didScrollRectAccordingIndex:delta:isScrollToRight:)]) {
        [self.delegate segmentContainer:self didScrollRectAccordingIndex:page delta:delta isScrollToRight:isScrollToRight];
    }
    [self.topBar scrollToRectWithIndex:page delta:delta isScrollToRight:isScrollToRight];
    _lastOffsetX = scrollView.contentOffset.x;
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    CGFloat offsetX = scrollView.contentOffset.x;
//    NSInteger page = offsetX / scrollView.width;
//    NSInteger nextPage = round(offsetX / scrollView.width);
//    id content = [self.contentsDic safeObjectForKey:[self savedKeyForContentAtIndex:nextPage]];
//    if ([content isKindOfClass:[UIViewController class]]){
//        QMBaseVC *vc = (QMBaseVC *)content;
//        if ([vc.isPreLoad boolValue] && nextPage != page) {
//            vc.isPreLoad = @(false);
//        }
//    }
//}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x / scrollView.width;
    if (page != self.currentIndex) {
        _curIndex = page;
        [self scrollToItemAtIndex:page withAnimation:false slide:YES isClick:NO];
    }
}

#pragma mark - Config

- (void)setSelectedIndex:(NSInteger)index withAnimated:(BOOL)animated
{
    [self.segmentTopBar setSelectedIndex:index withAnimated:animated];
    
    
    if (!_didLoadData) {
        _lastIndex = _currentIndex;
        _currentIndex = index;
        _curIndex = index;
        
    }
    else{
        [self scrollToItemAtIndex:index withAnimation:animated slide:NO isClick:NO];
    }
}


- (id)contentAtIndex:(NSInteger)index
{
    return [self.contentsDic objectForKey:[self savedKeyForContentAtIndex:index]];
}

//设置scrollview的scrollsToTop属性
- (void)setContentAtIndex:(NSInteger)index scrollsToTop:(BOOL)scrollsToTop
{
    id content = [self contentAtIndex:index];
    if (content) {
        UIView *superView = nil;
        
        if ([content isKindOfClass:[UIViewController class]]) {
            superView = ((UIViewController *)content).view;
        }
        else if ([content isKindOfClass:[UIView class]]){
            if ([content isKindOfClass:[UIScrollView class]]){
                UIScrollView *scrollView = (UIScrollView *)content;
                scrollView.scrollsToTop = scrollsToTop;
                superView = scrollView;
            }
            else{
                superView = (UIView *)content;
            }
        }
        
        if (superView) {
            [self setSubView:superView scrollsTotop:scrollsToTop];
        }
    }
}

//设置superview的subview中的scrollview的scrollsToTop
- (void)setSubView:(UIView *)superView scrollsTotop:(BOOL)scrollsToTop
{
    for (NSInteger i = superView.subviews.count - 1; i >= 0; i--) {
        UIView *subView = [superView.subviews objectAtIndex:i];
        
        if ([subView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)subView;
            scrollView.scrollsToTop = scrollsToTop;
            break;
        }
        
        [self setSubView:subView scrollsTotop:scrollsToTop];
    }
}

- (NSInteger)safeCurrentIndex {
    if (self.orignContentCount>0) {
        return self.currentIndex % self.orignContentCount;
    }else{
        return 0;
    }
    
}

-(NSInteger)safeLastIndex{
    if (self.orignContentCount>0) {
        return self.lastIndex % self.orignContentCount;
    }else{
        return 0;
    }
}

#pragma mark - Properties
- (UIView<QMSegmentTopBarProtocol> *)topBar {

    self.segmentTopBar.hidden = false;
    return self.segmentTopBar;
}

- (QMSegmentTopBar *)segmentTopBar
{
    if (!_segmentTopBar) {
        CGRect frame = self.isBottomBar ? CGRectMake(0, self.height-self.topBarHeight, self.width, self.topBarHeight) : CGRectMake(0, 0, self.width, self.topBarHeight);
        _segmentTopBar = [[QMSegmentTopBar alloc] initWithFrame:frame];
        _segmentTopBar.onlyOneShow = YES;
        __weak typeof(self) weakself = self;
        [_segmentTopBar setDidSeleteItemAtIndex:^(NSInteger index) {
            if (index != weakself.currentIndex) {
                [weakself scrollToItemAtIndex:index withAnimation:YES slide:NO isClick:YES];
            }
            
        }];
    }
    return _segmentTopBar;
}


- (QMSegmentScrollview *)containerView
{
    if (!_containerView) {
        _containerView = [[QMSegmentScrollview alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - self.topBar.height)];
        _containerView.showsHorizontalScrollIndicator = NO;
        _containerView.showsVerticalScrollIndicator = NO;
        _containerView.bounces = NO;
        _containerView.pagingEnabled = YES;
        _containerView.delegate = self;
        _containerView.scrollsToTop = NO;
        _containerView.backgroundColor = self.containerBackgroundColor;
    }
    return _containerView;
}


- (NSMutableDictionary *)contentsDic
{
    if (!_contentsDic) {
        _contentsDic = [[NSMutableDictionary alloc] init];
    }
    return _contentsDic;
}

- (NSMutableArray *)appearingViewControllers {
    if (!_appearingViewControllers) {
        _appearingViewControllers = [[NSMutableArray alloc] init];
    }
    return _appearingViewControllers;
}

- (void)setContainerBackgroundColor:(UIColor *)containerBackgroundColor
{
    _containerBackgroundColor = containerBackgroundColor;
    self.containerView.backgroundColor = containerBackgroundColor;
}

- (void)setTopBarHeight:(CGFloat)topBarHeight
{
    _topBarHeight = topBarHeight;
    self.topBar.height = topBarHeight;
    self.topBar.topBarHeight = @(topBarHeight);
    self.containerView.top = topBarHeight;
}

- (void)setAllowGesture:(BOOL)allowGesture
{
    _allowGesture = allowGesture;
    self.containerView.scrollEnabled = allowGesture;
}

-(void)setTopBarBgColor:(UIColor *)topBarBgColor{
    _topBarBgColor = topBarBgColor;
    self.topBar.bgColor = _topBarBgColor;
}

-(void)setIndicatorColor:(UIColor *)indicatorColor{
    _indicatorColor = indicatorColor;
    self.topBar.indicatorColor = _indicatorColor;
}

@end
