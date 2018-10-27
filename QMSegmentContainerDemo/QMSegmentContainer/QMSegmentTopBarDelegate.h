//
//  QMSegmentTopBarDelegate.h
//  juanpi3
//
//  Created by Alvin on 16/9/18.
//  Copyright © 2016年 Alvin. All rights reserved.
//

#import "QMSegmentTopBarProtocol.h"
typedef NS_ENUM(NSInteger,QMSegmentMenuType){
    QMSegmentMenuPlainTextType=0,  //全文模式   显示下划线
    QMSegmentMenuFullPicType,//全图模式   不显示下划线
    QMSegmentMenuAppletType,     //上面图片下面文字
    QMSegmentMenuPicAndTextType, //图片与文字模式混合
    QMSegmentMenuAppletAndTextType,//图文模式与文字模式混合  以图文模式的高度为准
    QMSegmentMenuAppletAndPic,      //图文模式与全图模式混合
    QMSegmentMenuGradualChange, // 渐变
};

@class QMSegmentTopBar,QMSegmentPopupMenu;
@protocol QMSegmentTopBarDelegate <NSObject>

@required
/**
 *  返回segment控件一共有多少项
 *
 *  @param topBar description
 *
 *  @return segment控件的项数
 */
- (NSInteger)numberOfItemsInTopBar:(UIView<QMSegmentTopBarProtocol> *)topBar;

@optional
/**
 *  返回控件在index项的标题
 *
 *  @param segmentTopBar description
 *  @param index            项的序号index
 *
 *  @return 返回控件在index项的标题
 */
- (NSString *)topBar:(UIView<QMSegmentTopBarProtocol> *)segmentTopBar titleForItemAtIndex:(NSInteger)index;



/**
 *  获取当前菜单的类型
 *
 *  @param topBar description
 *
 *  @return return value description
 */
- (QMSegmentMenuType)menuTypeOfItemsInSegmentTopBar:(UIView<QMSegmentTopBarProtocol> *)topBar;
/**
 *  返回index项需要的菜单数据
 *
 *  @param topBar description
 *  @param index            index description
 *
 *  @return QMSegmentMenuModel
 */
- (QMSegmentMenuModel *)topBar:(UIView<QMSegmentTopBarProtocol> *)topBar menuModelForItemAtIndex:(NSInteger)index;
- (NSArray<QMSegmentMenuModel *> *)topBarMenuList:(UIView<QMSegmentTopBarProtocol> *)topBar;
/**
 *  返回控件在index项的icon
 *
 *  @param segmentTopBar description
 *  @param index            项的序号index
 *
 *  @return 返回控件在index项的标题
 */
- (NSString *)topBar:(UIView<QMSegmentTopBarProtocol> *)segmentTopBar iconForItemAtIndex:(NSInteger)index;

/**
 *  该方法每次reloadData后只会调用一次，调用时间为第一次切换到第index、index-1或者index+1项时
 *
 *  @param segmentTopBar description
 *  @param index            项的序号
 */
- (void)topBar:(UIView<QMSegmentTopBarProtocol> *)segmentTopBar preDisplayItemAtIndex:(NSInteger)index;

/**
 *  选中第index项时的回调,每次切换(不论是滑动还是点击切换都会调用)到第index项都会调用该方法
 *
 *  @param segmentContainer description
 *  @param index            项的序号
 */
- (void)topBar:(UIView<QMSegmentTopBarProtocol> *)segmentContainer didSelectedItemAtIndex:(NSInteger)index;

/**
 *  每次点击切换到第index项时调用
 *
 *  @param segmentTopBar description
 *  @param index            index description
 */
- (void)topBar:(UIView<QMSegmentTopBarProtocol> *)segmentTopBar didClickedItemAtIndex:(NSInteger)index;

/**
 *  在第index项需要显示的角标图片，可以是图片地址，也可以是UIImage对象
 *
 *  @param segmentTopBar description
 *  @param index            index description
 *
 *  @return 角标图片
 */
- (id)topBar:(UIView<QMSegmentTopBarProtocol> *)segmentTopBar conerMarkForItemAtIndex:(NSInteger)index;


- (NSString *)topBar:(UIView<QMSegmentTopBarProtocol> *)segmentTopBar selectedBGColorForItemAtIndex:(NSInteger)index;

- (NSString *)topBar:(UIView<QMSegmentTopBarProtocol> *)segmentTopBar normalBGColorForItemAtIndex:(NSInteger)index;

/**
 *  返回控件在index项的副标题
 *
 *  @param segmentTopBar description
 *  @param index            项的序号index
 *
 *  @return 返回控件在index项的副标题
 */
- (NSString *)topBar:(UIView<QMSegmentTopBarProtocol> *)segmentTopBar subTitleForItemAtIndex:(NSInteger)index;

/**
 是否显示 下拉框

 @param topBar description
 @return value description
 */
- (BOOL)topBarShouldPopMenuList:(UIView<QMSegmentTopBarProtocol> *)topBar;

/**
 *  每次完成reloadData后都会调用
 *
 *  @param segmentTopBar segmentContainer description
 */
- (void)topBarDidReloadData:(UIView<QMSegmentTopBarProtocol> *)segmentTopBar;

- (void)topBarDidSelectPopBtn:(UIButton *)popBtn;

@end
