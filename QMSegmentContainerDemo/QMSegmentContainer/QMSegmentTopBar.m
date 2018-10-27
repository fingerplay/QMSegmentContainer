//
//  QMsegmentTopBar.m
//  juanpi3
//
//  Created by Alvin on 16/6/3.
//  Copyright © 2016年 Alvin. All rights reserved.
//

#import "QMSegmentTopBar.h"
#import "QMSegmentIconTitleItem.h"
#import "QMSegmentDoubleTitleItem.h"
#import "QMSegmentDefaultItemView.h"
#import "QMSegmentGradualItemView.h"
#import "ViewFrameAccessor.h"
#import <SDWebImageManager.h>
#import <UIImageView+WebCache.h>
#import "NSString+UI.h"
#import "NSString+QMHelper.h"
#import "QMDeviceHelper.h"

#define itemView_start_tag 111
#define itemCorner_start_tag 222
#define itemTag_start_tag 333 //自定义角标tag的起始值

@interface QMSegmentTopBar()<QMSegmentDefaultItemViewDelegate,UIScrollViewDelegate>{
    BOOL _didLoadData;
    NSInteger _curIndex;
}

@property (nonatomic, strong) UIScrollView *topBar;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) NSMutableArray *itemViewArray;
@property (nonatomic, assign) NSInteger itemCount;

/**
 *  只要包含纯文本形式则显示下划线
 */
@property (nonatomic, assign)BOOL isShowLine;
@property (nonatomic, assign) QMSegmentMenuType menuType;

@end

@implementation QMSegmentTopBar

@synthesize  averageSegmentation = _averageSegmentation;
@synthesize  isAlignmentCenter = _isAlignmentCenter;
@synthesize  titleNormalColor = _titleNormalColor;
@synthesize  titleSelectedColor = _titleSelectedColor;
@synthesize  titleFont = _titleFont;
@synthesize  titleSelectedFont = _titleSelectedFont;
@synthesize  containerBackgroundColor = _containerBackgroundColor;
@synthesize  bottomLineColor = _bottomLineColor;
@synthesize  bottomLineHeight = _bottomLineHeight;
@synthesize  indicatorOffset = _indicatorOffset;
@synthesize  indicatorHeight = _indicatorHeight;
@synthesize  indicatorBottomPadding = _indicatorBottomPadding;
@synthesize  indicatorColor = _indicatorColor;
@synthesize  minIndicatorWidth = _minIndicatorWidth;
@synthesize  bgColor = _bgColor;
@synthesize  horizontalInset = _horizontalInset;
@synthesize  itemPadding = _itemPadding;
@synthesize  expandToTopBarWidth = _expandToTopBarWidth;
@synthesize  isShowSubTitle = _isShowSubTitle;
@synthesize  lastIndex = _lastIndex;
@synthesize  currentIndex = _currentIndex;
@synthesize  defaultIndex = _defaultIndex;
@synthesize  catogryArray = _catogryArray;
@synthesize  popupMenuBtn = _popupMenuBtn;
@synthesize  isShowImg = _isShowImg;
@synthesize  isGradual = _isGradual;
@synthesize  onlyOneShow = _onlyOneShow;
@synthesize  delegate = _delegate;
@synthesize  didSeleteItemAtIndex = _didSeleteItemAtIndex;
@synthesize indicatorView = _indicatorView;
@synthesize topBarHeight = _topBarHeight;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame topBarHeight:(CGFloat )topBarHeight
{
    if (self = [super initWithFrame:frame]) {
        self.topBarHeight = @(topBarHeight);
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self addSubview:self.topBar];
    [self addSubview:self.lineView];
    [self.topBar addSubview:self.indicatorView];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.minIndicatorWidth = 0;//indicator的最小宽度
    
    if (!self.topBarHeight) {
        self.topBarHeight = @(ScreenScale() == 3 ? Scale(126) : 40);
    }
    
    self.height = self.topBarHeight.floatValue;//顶部选项条默认高度,区分2x和3x
    self.itemPadding = 24;//项与项之间默认距离
    self.indicatorOffset = 5.0;//选项选中时标记的红条比文字长出的长度(效果图标记为10)
    self.indicatorHeight = 2.0;//标记选中的红线的高度
    self.bottomLineHeight = 0.5;//分隔线默认高度
    self.expandToTopBarWidth = YES;//默认铺满topBar的宽度
    self.containerBackgroundColor = UIColorFromHexValue(0xf4f4f8);
//    self.isShowImg = true;
    _lastIndex = -1;
}

-(void)setBgColor:(UIColor *)bgColor{
    _bgColor = bgColor;
    if (bgColor) {
        self.backgroundColor = bgColor;
        if (CGColorEqualToColor(bgColor.CGColor, [UIColor whiteColor].CGColor)){
            self.lineView.hidden = NO;
        }else{
            self.lineView.hidden = YES;
        }
    }else{
        self.backgroundColor = [UIColor whiteColor];
        self.lineView.hidden = NO;
    }
}

-(void)setTopBarHeight:(NSNumber *)topBarHeight{
    _topBarHeight = topBarHeight;
    self.topBar.height = topBarHeight.floatValue;
}

- (void)reloadData
{
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(numberOfItemsInTopBar:)] || ![self.delegate respondsToSelector:@selector(topBar:titleForItemAtIndex:)]) {
        return;
    }
    
    self.itemCount = [self.delegate numberOfItemsInTopBar:self];
    self.indicatorView.backgroundColor = self.indicatorColor;
    [self reloadTopBar];
    [self reloadCornerMark];
    
    //defaultIndex只在选中的是非第一个选项并且currentIndex小于1的情况下生效
    if (self.defaultIndex && !self.currentIndex) {
        _currentIndex = self.defaultIndex;
    }
    
    if (!self.currentIndex || self.currentIndex >= self.itemCount) {
        _currentIndex = 0;
    }
    [self setSelectedIndex:self.currentIndex withAnimated:NO];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBarDidReloadData:)]) {
        [self.delegate topBarDidReloadData:self];
    }
}




- (void)reloadTopBar
{
    if (!self.onlyOneShow && self.itemCount <= 1) {//只有一个选项时隐藏顶部导航条
        self.topBar.frame = CGRectMake(0, 0, self.topBar.width, 0);
        self.lineView.bottom = self.topBar.bottom;
        self.height = 0;
        return;
    }else{
        
        if (self.height==0) {
            self.height = self.topBarHeight.floatValue;
        }
        
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(menuTypeOfItemsInSegmentTopBar:)]) {
        
        self.menuType = [self.delegate menuTypeOfItemsInSegmentTopBar:self];
        self.isGradual = self.menuType == QMSegmentMenuGradualChange;
        
        if ([self isCanShowPopupMenu]) {
            self.topBar.frame = CGRectMake(0, 0, self.width - 40, self.height);
            [self.popupMenuBtn setFrame:CGRectMake(self.topBar.width, 0, 40, self.height-1)];
            [self addSubview:self.popupMenuBtn];

        }else{
            if (self.menuType==QMSegmentMenuAppletAndPic||self.menuType==QMSegmentMenuAppletType||self.menuType==QMSegmentMenuAppletAndTextType){
                self.itemPadding = 0;
                self.height = appletHeight;
            }else{
                self.height = self.topBarHeight.floatValue;
            }
            self.topBar.frame = CGRectMake(0, 0, self.width, self.height);
            if (self.menuType==QMSegmentMenuAppletAndPic||self.menuType==QMSegmentMenuAppletType||self.menuType==QMSegmentMenuFullPicType) {
                self.indicatorView.hidden = YES;
            }else{
                self.indicatorView.hidden = NO;
            }
            
            if (self.menuType == QMSegmentMenuGradualChange) {
                self.indicatorView.hidden = YES;
            }
            
            if (self.menuType==QMSegmentMenuFullPicType) {
                self.height = 48;
            }
        }
        
    }else if ([self isCanShowImg]) {
        self.height = appletHeight;
        self.topBar.frame = CGRectMake(0, 0, self.width, self.height);
        self.indicatorView.hidden = YES;
        self.itemPadding = 0;
    }else if ([self isCanShowPopupMenu]) {
        self.topBar.frame = CGRectMake(0, 0, self.width - 44, self.height);
        [self.popupMenuBtn setFrame:CGRectMake(self.topBar.width, 1, 44, self.height - 2)];
        [self addSubview:self.popupMenuBtn];
        
    }else{
        self.topBar.frame = CGRectMake(0, 0, self.width, self.height);
    }
    
    self.lineView.bottom = self.topBar.bottom;
    
    for (UIButton *btn in self.itemViewArray) {
        [btn removeFromSuperview];
    }
    [self.itemViewArray removeAllObjects];
    
    [self addTopBarSubviews];
}


- (void)addTopBarSubviews {
    QMSegmentMenuType type = QMSegmentMenuPlainTextType;
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuTypeOfItemsInSegmentTopBar:)]) {
        type = [self.delegate menuTypeOfItemsInSegmentTopBar:self];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBar:menuModelForItemAtIndex:)]) {
        for (NSInteger i = 0; i < self.itemCount; i++) {
            UIButton *btn;
            QMSegmentMenuModel *menu = [self.delegate topBar:self menuModelForItemAtIndex:i];
            btn = [self itemButtonForIndex:i menu:menu];
            [self.topBar addSubview:btn];
            if (btn) {
                [self.itemViewArray addObject:btn];
            }
            
        }
        
    }else if ([self isCanShowImg]) {
        for (NSInteger i = 0; i < self.itemCount; i++) {
            UIButton *btn = [self segmentIconTitleItemForIndex:i];
            [self.topBar addSubview:btn];
            if (btn) {
                [self.itemViewArray addObject:btn];
            }
        }
    }else if(self.isShowSubTitle) {
        for (NSInteger i = 0; i < self.itemCount; i++) {
            UIButton *btn = [self segmentDoubleTitleForIndex:i];
            [self.topBar addSubview:btn];
            if (btn) {
                [self.itemViewArray addObject:btn];
            }
        }
    }else {
        for (NSInteger i = 0; i < self.itemCount; i++) {
            UIButton *btn = [self itemButtonForIndex:i];
            [self.topBar addSubview:btn];
            if (btn) {
                [self.itemViewArray addObject:btn];
            }
        }
    }
    
    if (self.averageSegmentation) {
        [self reLayoutTopBarUseAverageMode];
    } else {
        [self reLayoutTopBar];
    }
    
    [self.topBar bringSubviewToFront:self.indicatorView];
}

- (void)reLayoutTopBarUseAverageMode {
    self.topBar.contentSize = self.topBar.bounds.size;
    
    CGFloat leftPos = 0;
    CGFloat averageWidth = self.topBar.width / self.itemCount;
    for (NSInteger i = 0; i < self.itemViewArray.count; i++) {
        UIButton *btn = [self.itemViewArray objectAtIndex:i];
        btn.left = leftPos;
        btn.width = averageWidth;
        leftPos = btn.right;
        if ([btn isKindOfClass:[QMSegmentDefaultItemView class]]) {
            [((QMSegmentDefaultItemView *)btn) averageItemView];
        }
        
    }
}

- (void)reLayoutTopBar
{
    CGFloat horizeonMargin = self.horizontalInset > 0 ? self.horizontalInset : 0.5*self.itemPadding;//左右缩进量默认为padding的一半，如果设置了horizontalInset,则按horizontalInset计算
    CGFloat leftPos = horizeonMargin;
    for (NSInteger i = 0; i < self.itemViewArray.count; i++) {
        UIButton *btn = [self.itemViewArray objectAtIndex:i];
        btn.left = leftPos;
        leftPos += btn.width + self.itemPadding;
    }
    
    CGFloat rigthPos = leftPos - self.itemPadding + horizeonMargin;//所有控件布局完成后，最右边的位置
    
    self.topBar.contentSize = CGSizeMake(rigthPos, self.topBar.height);
    if ([self isCanShowImg] && rigthPos >= self.topBar.width) {//如果当前为图片模式，超过topbar宽度即可滚动，未超过则调整间距，使之刚好铺满屏幕
        self.topBar.contentSize = CGSizeMake(rigthPos, self.topBar.height);
    }
    else if (rigthPos >= self.topBar.width + 20) {//普通情况超过屏幕宽度20个像素才滑动，否则调整间距，使之刚好铺满屏幕
        self.topBar.contentSize = CGSizeMake(rigthPos, self.topBar.height);
    }
    else{
        
        if (self.isAlignmentCenter) {
            self.topBar.frame = self.bounds;
            self.topBar.contentSize = self.topBar.bounds.size;
            CGFloat btnTotalWidth = leftPos - self.itemPadding - horizeonMargin;
            //如果为yes 则菜单显示居中
            leftPos = (self.topBar.width - btnTotalWidth)*0.5;
            for (NSInteger i = 0; i < self.itemViewArray.count; i++) {
                UIButton *btn = [self.itemViewArray objectAtIndex:i];
                btn.left = leftPos;
                leftPos += btn.width + self.itemPadding;
            }

            
        }else{
            self.topBar.contentSize = self.topBar.bounds.size;
            CGFloat delta = (self.topBar.width - rigthPos) / self.itemCount;
            if (delta < 0 || self.expandToTopBarWidth) {
                for (NSInteger i = 0; i < self.itemViewArray.count; i++) {
                    UIButton *btn = [self.itemViewArray objectAtIndex:i];
                    btn.left += (i + 0.5) * delta;
                }
            }
        }
    }
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    if (self.isAlignmentCenter) {
        [self reLayoutTopBar];
        [self reLayoutIndicatorView];
    }
}

- (void)itemButtonsClicked:(UIButton *)sender
{
    UIButton *btn = [self viewWithTag:itemView_start_tag+_curIndex];
    btn.selected = NO;
    sender.selected = YES;
    
    _curIndex = sender.tag - itemView_start_tag;
    
    if (self.didSeleteItemAtIndex) {
        self.didSeleteItemAtIndex(sender.tag - itemView_start_tag);
    }
    
    
    [self scrollToItemAtIndex:sender.tag - itemView_start_tag withAnimation:YES slide:NO canCallBack:YES];
}

- (void)scrollToItemAtIndex:(NSInteger)index withAnimation:(BOOL)animation slide:(BOOL)slide canCallBack:(BOOL)callBack
{
//    if (self.popupMenu.show) {
//        [self.popupMenu dismissPopMenuView];
//    }
    
    if (index >= self.itemCount) {
        return;
    }
    
    NSInteger oldIndex = self.currentIndex;
    _lastIndex = _currentIndex;
    _currentIndex = index;
    _curIndex = index;
    
    UIButton *originBtn = (UIButton *)[self.itemViewArray objectAtIndex:oldIndex];
    originBtn.selected = NO;
    originBtn.titleLabel.font = self.titleFont;
    
    UIButton *newBtn = (UIButton *)[self.itemViewArray objectAtIndex:index];
    newBtn.selected = YES;
    newBtn.titleLabel.font = self.titleSelectedFont;
    
    if (animation) {
        __weak typeof(self) wSelf = self;
        [UIView animateWithDuration:0.2 animations:^{
            __strong typeof(wSelf) sSelf = self;
            [sSelf reLayoutIndicatorView];
            [sSelf scrollRectToVisibleCenteredOn:newBtn.frame animated:NO];
        } completion:^(BOOL finished) {
            __strong typeof(wSelf) sSelf = self;
            if (sSelf.delegate && [sSelf.delegate respondsToSelector:@selector(topBar:didSelectedItemAtIndex:)] && callBack) {
                [sSelf.delegate topBar:sSelf didSelectedItemAtIndex:index];
            }
            
        }];
    }
    else{
        [self reLayoutIndicatorView];
        [self scrollRectToVisibleCenteredOn:newBtn.frame animated:NO];
        if (self.delegate && [self.delegate respondsToSelector:@selector(topBar:didSelectedItemAtIndex:)] && callBack) {
            [self.delegate topBar:self didSelectedItemAtIndex:index];
        }
    }
}

- (void)reLayoutIndicatorView
{
    if (self.averageSegmentation) {//平均分割模式下的indicator布局
        CGFloat averageWidth = self.topBar.width / self.itemCount;
        self.indicatorView.frame = CGRectMake(self.currentIndex * averageWidth,
                                              self.topBar.height - self.indicatorHeight,
                                              averageWidth,
                                              self.indicatorHeight);
    } else {
        UIButton *itemView = [self.itemViewArray objectAtIndex:self.currentIndex];

        CGFloat realItemWidth = itemView.width - itemView.titleEdgeInsets.right;
        
        if ([itemView isKindOfClass:[QMSegmentDefaultItemView class]]) {
            QMSegmentDefaultItemView *segmentItemView = (QMSegmentDefaultItemView *)itemView;
            if (segmentItemView.item.segmentTag && [segmentItemView.item.showType integerValue]==2) {
                realItemWidth = segmentItemView.itemTitleButton.width;
            }
        }
        
        CGFloat indicatorWith = realItemWidth >= self.minIndicatorWidth ? realItemWidth : self.minIndicatorWidth;
        CGRect indicatorFrame = CGRectMake(itemView.left + 0.5*realItemWidth - 0.5*indicatorWith, self.topBar.height - self.indicatorHeight - self.indicatorBottomPadding, indicatorWith, self.indicatorHeight);
        self.indicatorView.frame = indicatorFrame;
    }
}

- (void)reloadCornerMark
{
    if (self.averageSegmentation || [self isCanShowImg]) {//平均分割模式或者图片模式下，不支持角标功能
        return;
        
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBar:conerMarkForItemAtIndex:)]) {
        for (NSInteger index = 0; index < self.itemCount; index ++) {
            id cornerMrak = [self.delegate topBar:self conerMarkForItemAtIndex:index];
            if (cornerMrak) {
                [self setCornerMark:cornerMrak forItemAtIndex:index];
            }
        }
    }
}

#pragma mark - QMSegmentPopupMenuDelegate

- (NSInteger)numberOfItemsInsegmentPopupMenu:(QMSegmentPopupMenu *)segmentPopupMenu
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfItemsInTopBar:)]) {
        return [self.delegate numberOfItemsInTopBar:self];
    }
    return 0;
}

- (NSString *)segmentPopupMenu:(QMSegmentPopupMenu *)segmentPopupMenu titleForItemAtIndex:(NSInteger)index
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBar:titleForItemAtIndex:)]) {
        return [self.delegate topBar:self titleForItemAtIndex:index];
    }
    return @"";
}

- (QMSegmentMenuModel *)segmentPopupMenu:(QMSegmentPopupMenu *)segmentPopupMenu menuModelForItemAtIndex:(NSInteger)index{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBar:menuModelForItemAtIndex:)]) {
        return [self.delegate topBar:self menuModelForItemAtIndex:index];
    }
    return nil;
}


- (id)segmentPopupMenu:(QMSegmentPopupMenu *)segmentPopupMenu cornerMarkForItemAtIndex:(NSInteger)index
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBar:conerMarkForItemAtIndex:)]) {
        return [self.delegate topBar:self conerMarkForItemAtIndex:index];
    }
    return nil;
}

#pragma mark - config
- (void)setSelectedIndex:(NSInteger)index withAnimated:(BOOL)animated
{
    if (_didLoadData) {
        _lastIndex = _currentIndex;
        _currentIndex = index;
        _curIndex = index;
        
    }
    else{
        [self scrollToItemAtIndex:index withAnimation:animated slide:NO canCallBack:NO];
    }
}

- (UIButton *)itemAtIndex:(NSInteger)index
{
    return [self.itemViewArray objectAtIndex:index];
}

#pragma mark - 角标
//为index处的选项添加角标
- (void)setCornerMark:(id _Nonnull)content forItemAtIndex:(NSInteger)index
{
    if ([content isKindOfClass:[NSString class]]) {//在线图片先下载完成再显示角标
        __weak typeof(self) wSelf = self;
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:content]
                                                              options:SDWebImageDownloaderUseNSURLCache
                                                             progress:nil
                                                            completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                __strong typeof(wSelf) sSelf = wSelf;
                                                                if (finished && image) {
                                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                                        [sSelf addCornerMarkWithImage:image forItemAtIndex:index];
                                                                    });
                                                                }
                                                            }];
    }
    else if ([content isKindOfClass:[UIImage class]]){//UIImage对象直接加入
        [self addCornerMarkWithImage:content forItemAtIndex:index];
    }
}

- (void)addCornerMarkWithImage:(UIImage *)image forItemAtIndex:(NSInteger)index
{
    UIButton *itemView = [self.itemViewArray objectAtIndex:index];
    if (!itemView) {
        return;
    }
    
    NSInteger tag = itemCorner_start_tag + index;
    UIView *view = [itemView viewWithTag:tag];
    if (view && [view isKindOfClass:[UIImageView class]]) {
        UIImageView *cornerMarkView = (UIImageView *)view;
        cornerMarkView.image = image;
    }
    else{
        UIImageView *cornerMarkView = [[UIImageView alloc] initWithImage:image];
        //        cornerMarkView.frame = CGRectMake(itemView.width - 0.5*self.indicatorOffset, 3.0, itemCorner_width, itemCorner_height);
        
        cornerMarkView.frame = CGRectMake(itemView.width + 1, 3.0, itemCorner_width, itemCorner_height);
        
        cornerMarkView.userInteractionEnabled = YES;
        cornerMarkView.clipsToBounds = YES;
        cornerMarkView.contentMode = UIViewContentModeScaleToFill;
        cornerMarkView.tag = itemCorner_start_tag + index;
        [itemView addSubview:cornerMarkView];
        
        //itemView.width += itemCorner_width;
        itemView.width += itemCorner_width + 1;
        itemView.titleEdgeInsets  = UIEdgeInsetsMake(0, 0, 0, itemCorner_width);
        
        [self reLayoutTopBar];
        [self reLayoutIndicatorView];
    }
}

//移除index处的角标
- (void)removeCornerMarkForItemAtIndex:(NSInteger)index
{
    UIButton *itemView = [self.itemViewArray objectAtIndex:index];
    if (!itemView) {
        return;
    }
    
    NSInteger tag = itemCorner_start_tag + index;
    UIView *view = [itemView viewWithTag:tag];
    if (view && [view isKindOfClass:[UIImageView class]]) {
        [view removeFromSuperview];
        
        itemView.width -= itemCorner_width;
        itemView.titleEdgeInsets = UIEdgeInsetsZero;
        [self reLayoutTopBar];
        [self reLayoutIndicatorView];
    }
}

#pragma mark - help
#pragma mark - Private Methods

//上面图片，下面标题
- (QMSegmentIconTitleItem *)segmentIconTitleItemForIndex:(NSInteger)index
{
    CGFloat itemWidth = self.itemCount>=5?(ScreenWidth/4.5):ScreenWidth/self.itemCount;
    if (self.delegate && index < self.itemCount) {
        QMSegmentIconTitleItem *button = [[QMSegmentIconTitleItem alloc] init];
        button.tag = itemView_start_tag + index;
        [button addTarget:self action:@selector(itemButtonsClicked:) forControlEvents:UIControlEventTouchUpInside];
        if ([self.delegate respondsToSelector:@selector(topBar:titleForItemAtIndex:)]) {
            NSString *title = [self.delegate topBar:self titleForItemAtIndex:index];
            button.titleLabel.font = self.titleFont;
            [button.titleLbl setText:title];
        }
        if ([self.delegate respondsToSelector:@selector(topBar:iconForItemAtIndex:)]) {
            NSString *iconUrl = [self.delegate topBar:self iconForItemAtIndex:index];
            [button.iconImageView sd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:nil];
        }
        if ([self.delegate respondsToSelector:@selector(topBar:conerMarkForItemAtIndex:)]) {
            button.cornerMaskType = [[self.delegate topBar:self conerMarkForItemAtIndex:index] integerValue];
        }
        
        if ([self.delegate respondsToSelector:@selector(topBar:normalBGColorForItemAtIndex:)]) {
            button.normalBGColor = [self.delegate topBar:self normalBGColorForItemAtIndex:index];
        }
        
        if ([self.delegate respondsToSelector:@selector(topBar:selectedBGColorForItemAtIndex:)]) {
            button.selectedBGColor = [self.delegate topBar:self selectedBGColorForItemAtIndex:index];
        }
        button.selected = index == 0;
        button.frame = CGRectMake(0, 0, itemWidth, self.topBar.height);
        return button;
    }
    return nil;
}

//上面主标题，下面副标题
- (QMSegmentDoubleTitleItem *)segmentDoubleTitleForIndex:(NSInteger)index
{
    if (self.delegate && index < self.itemCount){
        QMSegmentDoubleTitleItem *button = [[QMSegmentDoubleTitleItem alloc] init];
        button.tag = itemView_start_tag + index;
        [button addTarget:self action:@selector(itemButtonsClicked:) forControlEvents:UIControlEventTouchUpInside];
        if ([self.delegate respondsToSelector:@selector(topBar:titleForItemAtIndex:)]) {
            NSString *title = [self.delegate topBar:self titleForItemAtIndex:index];
            [button.titleLbl setText:title];
        }
        if ([self.delegate respondsToSelector:@selector(topBar:subTitleForItemAtIndex:)]) {
            NSString *subTitle = [self.delegate topBar:self subTitleForItemAtIndex:index];
            [button.subTitleLbl setText:subTitle];
        }
        NSInteger titleWidth = [button.titleLbl.text getUISize:[UIFont systemFontOfSize:16] limitWidth:MAXFLOAT].width;
        NSInteger subTitleWidth = [button.subTitleLbl.text getUISize:[UIFont systemFontOfSize:11] limitWidth:MAXFLOAT].width;
        if (titleWidth > subTitleWidth) {
            button.frame = CGRectMake(0, 0, titleWidth + self.indicatorOffset, self.topBar.height);
        }else{
            button.frame = CGRectMake(0, 0, subTitleWidth + self.indicatorOffset, self.topBar.height);
        }
        return button;
    }
    return nil;
}

//单条文字或图片
- (UIButton *)itemButtonForIndex:(NSInteger)index
{
    if (self.delegate && index < self.itemCount && [self.delegate respondsToSelector:@selector(topBar:titleForItemAtIndex:)]) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImageView *imageView = [[UIImageView alloc] init];
        button.tag = itemView_start_tag + index;
        NSString *contain = @"";
        if ([self.delegate respondsToSelector:@selector(topBar:titleForItemAtIndex:)]) {
            contain = [self.delegate topBar:self titleForItemAtIndex:index];
        }
        NSString *picUrl = @"";
        if ([self.delegate respondsToSelector:@selector(topBar:iconForItemAtIndex:)]) {
            picUrl = [self.delegate topBar:self iconForItemAtIndex:index];
        }
        if ([picUrl isHTTPLink]) {
            button.titleLabel.font = self.titleFont;
            [button setTitle:contain forState:UIControlStateNormal];
            [button setTitleColor:self.titleNormalColor forState:UIControlStateNormal];
            [button setTitleColor:self.titleSelectedColor forState:UIControlStateSelected];
            [button addTarget:self action:@selector(itemButtonsClicked:) forControlEvents:UIControlEventTouchUpInside];
            [button sizeToFit];
            button.frame = CGRectMake(0, 0, button.width + self.indicatorOffset, self.topBar.height);
            
            __weak typeof(self) wSelf = self;
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:picUrl]
                                                                  options:SDWebImageDownloaderUseNSURLCache
                                                                 progress:nil
                                                                completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                    __strong typeof(wSelf) sSelf = wSelf;
                                                                    if (finished && image) {
                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                            CGFloat imageWidth = (image.size.width/image.size.height) * sSelf.topBar.height;
                                                                            imageView.image = image;
                                                                            imageView.frame = CGRectMake(self.indicatorOffset/2, 0, imageWidth, sSelf.topBar.height);
                                                                            [button addSubview:imageView];
                                                                            [button addTarget:self action:@selector(itemButtonsClicked:) forControlEvents:UIControlEventTouchUpInside];
                                                                            [button setTitle:@"" forState:UIControlStateNormal];
                                                                            button.frame = CGRectMake(0, 0, imageView.width + self.indicatorOffset, sSelf.topBar.height);
                                                                            
                                                                            
                                                                            if (self.averageSegmentation) {
                                                                                [self reLayoutTopBarUseAverageMode];
                                                                            } else {
                                                                                [self reLayoutTopBar];
                                                                            }
                                                                            
                                                                            [self reLayoutIndicatorView];
                                                                        });
                                                                    }
                                                                    
                                                                }];
        }
        else {
            button.titleLabel.font = self.titleFont;
            [button setTitle:contain forState:UIControlStateNormal];
            [button setTitleColor:self.titleNormalColor forState:UIControlStateNormal];
            [button setTitleColor:self.titleSelectedColor forState:UIControlStateSelected];
            [button addTarget:self action:@selector(itemButtonsClicked:) forControlEvents:UIControlEventTouchUpInside];
            [button sizeToFit];
            button.frame = CGRectMake(0, 0, button.width + self.indicatorOffset, self.topBar.height);
        }
        
        return button;
    }
    return nil;
}


//单条文字或图片
- (UIButton *)itemButtonForIndex:(NSInteger)index menu:(QMSegmentMenuModel*)menu
{
    if (!menu.selectedTitleColor) {
        menu.selectedTitleColor = self.titleSelectedColor;
    }
    if (!menu.unselectedTitleColor) {
        menu.unselectedTitleColor = self.titleNormalColor;
    }
    
    if ([menu.showType integerValue]==3) {
        //图文详情固定字体大小为12
        menu.titleFont = [UIFont systemFontOfSize:12];
    }else{
        
        if (menu.titleFont) {
            self.titleFont = menu.titleFont;
            self.titleSelectedFont = menu.titleFont;
        }else{
            menu.titleFont = self.titleFont;
        }
    }
    
    BOOL canShowPopMenu = [self isCanShowPopupMenu];
    if (self.isGradual && !canShowPopMenu) {
        CGFloat itemWidth = self.itemCount>=5?(ScreenWidth/4.5):ScreenWidth/self.itemCount;
        QMSegmentGradualItemView *defaultItemView = [[QMSegmentGradualItemView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, self.topBar.height) item:menu];
        defaultItemView.tag = itemView_start_tag + index;
        [defaultItemView addTarget:self action:@selector(itemButtonsClicked:) forControlEvents:UIControlEventTouchUpInside];
//        defaultItemView.delegate = self;
        defaultItemView.gradient = index > 0 ? 0 : 1;
        return defaultItemView;
    }
    
    
    CGFloat itemWidth = self.itemCount>=5?(ScreenWidth/4.5):ScreenWidth/self.itemCount;
    QMSegmentDefaultItemView *defaultItemView = [[QMSegmentDefaultItemView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, self.topBar.height) item:menu isCanShowPopupMenu:canShowPopMenu];
    defaultItemView.tag = itemView_start_tag + index;
    [defaultItemView addTarget:self action:@selector(itemButtonsClicked:) forControlEvents:UIControlEventTouchUpInside];
    defaultItemView.delegate = self;
    return defaultItemView;
}


-(void)defaultItemViewDownLoadSuccess{
    if (self.averageSegmentation) {
        [self reLayoutTopBarUseAverageMode];
    } else {
        [self reLayoutTopBar];
    }
    
    [self reLayoutIndicatorView];
}


- (void)scrollRectToVisibleCenteredOn:(CGRect)visibleRect
                             animated:(BOOL)animated {
    CGRect centeredRect = CGRectMake(visibleRect.origin.x + visibleRect.size.width/2.0 - self.topBar.width/2.0,
                                     visibleRect.origin.y + visibleRect.size.height/2.0 - self.topBar.height/2.0,
                                     self.topBar.width,
                                     self.topBar.height);
    [self.topBar scrollRectToVisible:centeredRect
                            animated:animated];
}

- (BOOL)isCanShowImg
{
    //5个到10个可配置显示图片
    if(self.itemCount >= 5 && self.itemCount <= 10 && self.isShowImg){
        return YES;
    }
    return NO;
}

- (BOOL)isCanShowPopupMenu
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(topBarShouldPopMenuList:)]) {
        return [self.delegate topBarShouldPopMenuList:self];
    }
    //10个以上显示下拉箭头
    if (self.itemCount > 15){
        return YES;
    }
    return NO;
}

#pragma mark - properties
- (UIScrollView *)topBar
{
    if (!_topBar) {
        _topBar = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, self.height)];
        _topBar.showsHorizontalScrollIndicator = NO;
        _topBar.showsVerticalScrollIndicator = NO;
        _topBar.backgroundColor = [UIColor clearColor];
        _topBar.bounces = YES;
        _topBar.directionalLockEnabled = YES;
        _topBar.scrollsToTop = NO;
        _topBar.delegate = self;
    }
    return _topBar;
}

- (UIImageView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.height - self.indicatorHeight, 1.0, self.indicatorHeight)];
        _indicatorView.backgroundColor = [UIColor redColor];
    }
    return _indicatorView;
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bottom - self.bottomLineHeight, SCREEN_W, self.bottomLineHeight)];
        _lineView.backgroundColor = UIColorFromHexValue(0xff464e);
    }
    return _lineView;
}

- (UIColor *)titleNormalColor
{
    if (!_titleNormalColor) {
        _titleNormalColor = UIColorFromHexValue(0x333333);
    }
    return _titleNormalColor;
}

- (UIColor *)titleSelectedColor
{
    if (!_titleSelectedColor) {
        _titleSelectedColor = UIColorFromHexValue(0xff464e);
    }
    return _titleSelectedColor;
}

- (UIColor *)indicatorColor
{
    if (!_indicatorColor) {
        _indicatorColor = UIColorFromHexValue(0xff464e);
    }
    return _indicatorColor;
}

- (UIFont *)titleFont
{
    if (!_titleFont) {
        _titleFont = ScreenScale() == 3 ? [UIFont systemFontOfSize:15] : [UIFont systemFontOfSize:14];
    }
    return _titleFont;
}

- (UIFont *)titleSelectedFont
{
    if (!_titleSelectedFont) {
        _titleSelectedFont = ScreenScale() == 3 ? [UIFont boldSystemFontOfSize:15] : [UIFont boldSystemFontOfSize:14];
    }
    return _titleSelectedFont;
}

- (NSMutableArray *)itemViewArray
{
    if (!_itemViewArray) {
        _itemViewArray = [@[] mutableCopy];
    }
    return _itemViewArray;
}

- (void)setBottomLineColor:(UIColor *)bottomLineColor
{
    _bottomLineColor = bottomLineColor;
    self.lineView.backgroundColor = bottomLineColor;
}

- (void)setBottomLineHeight:(CGFloat)bottomLineHeight
{
    _bottomLineHeight = bottomLineHeight;
    self.lineView.height = bottomLineHeight;
    self.lineView.bottom = self.topBar.height;
}

- (void)setIndicatorHeight:(CGFloat)indicatorHeight
{
    _indicatorHeight = indicatorHeight;
    self.indicatorView.height = indicatorHeight;
    self.indicatorView.bottom = self.topBar.height;
}

@end
