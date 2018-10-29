//
//  ViewController.m
//  QMSegmentContainerDemo
//
//  Created by 罗谨 on 2018/10/18.
//  Copyright © 2018年 finger. All rights reserved.
//

#import "ViewController.h"
#import "QMSegmentContainer.h"
#import "SubViewController.h"
#import "MacroDefines.h"

@interface ViewController ()<QMSegmentContainerDelegate,QMSegmentTopBarDelegate>
@property (nonatomic,strong) NSArray *categories;
@property (nonatomic,strong) QMSegmentContainer *categoryView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self setup];
}

- (void)setup {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    [self.view addSubview:self.categoryView];
}

- (void)loadData {
    MenuModel *menu1= [[MenuModel alloc] init];
    menu1.categoryId =1;
    menu1.menuTitle = @"空调";
    menu1.bgColor = @"#0000ff";
    
    MenuModel *menu2= [[MenuModel alloc] init];
    menu2.categoryId=2;
    menu2.menuTitle = @"窗帘";
    menu2.bgColor = @"#ff0000";
    
    MenuModel *menu3= [[MenuModel alloc] init];
    menu3.categoryId=3;
    menu3.menuTitle = @"电视";
    menu3.bgColor = @"#00ff00";
    
    self.categories = @[menu1,menu2,menu3];
}

- (NSString*)imageForCategory:(MenuModel*)category selected:(BOOL)selected {
    NSString *image;
    switch (category.categoryId) {
        case 1: {
            image = selected ? @"tab_aircondition_active" : @"tab_aircondition_normal";
            break;
        }
        case 2: {
            image = selected ? @"tab_curtain_active" : @"tab_curtain_normal";
            break;
        }
        case 3: {
            image = selected ? @"tab_tv_active" : @"tab_tv_normal";
            break;
        }
    }
    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - QMSegmentContainer Delegate
- (NSInteger)numberOfItemsInTopBar:(QMSegmentTopBar *)topBar
{
    return self.categories.count;
}

//- (NSString *)topBar:(QMSegmentTopBar *)segmentTopBar titleForItemAtIndex:(NSInteger)index
//{
//    MenuModel *category = [self.categories objectAtIndex:index];
//    return category.menuTitle;
//}

//- (NSString *)topBar:(UIView<QMSegmentTopBarProtocol> *)segmentTopBar iconForItemAtIndex:(NSInteger)index {
//    MenuModel *category = [self.categories objectAtIndex:index];
//    return [self imageForCategory:category selected:YES];
//}

- (QMSegmentMenuModel *)topBar:(UIView<QMSegmentTopBarProtocol> *)topBar menuModelForItemAtIndex:(NSInteger)index {
    MenuModel *category = [self.categories objectAtIndex:index];
    QMSegmentMenuModel *menu = [[QMSegmentMenuModel alloc] init];
    menu.title = category.menuTitle;
    menu.phSelectedIcon = [self imageForCategory:category selected:YES];
    menu.phUnselectedIcon = [self imageForCategory:category selected:NO];
    menu.selectedTitleColor =   UIColorFromHexString(@"#13D5DC") ;
    menu.unselectedTitleColor =  RGBColor(117, 120, 122);
    menu.showType = @3;
    return menu;
}

//- (BOOL)shouldRecycleContainer:(QMSegmentContainer *)segmentContainer {
//    return NO;
//}
//
//- (NSInteger)numberOfItemsInSegmentContainer:(QMSegmentContainer *)segmentContainer {
//    return self.categories.count;
//}

- (id)segmentContainer:(QMSegmentContainer *)segmentContainer contentForIndex:(NSInteger)index
{
    MenuModel *category = [self.categories objectAtIndex:index];
    SubViewController *subVC = [[SubViewController alloc] init];
    subVC.menu = category;
    return subVC;
}

-(void)segmentContainer:(QMSegmentContainer *)segmentContainer didSelectedItemAtIndex:(NSInteger)index {
    if (self.categories.count <= index) {
        return;
    }
    
    NSLog( @"select category index:%ld",index);

}

- (void)segmentContainer:(QMSegmentContainer *)segmentContainer didClickedItemAtIndex:(NSInteger)index {

}

- (QMSegmentContainer *)categoryView {
    if (!_categoryView) {
        _categoryView = [[QMSegmentContainer alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _categoryView.segmentTopBar.indicatorHeight = 0;
        _categoryView.isBottomBar = YES;
        _categoryView.delegate = self;
        _categoryView.segmentTopBar.itemPadding = 0;
        _categoryView.parentVC = self;
        _categoryView.topBarHeight = 60;
    }
    return _categoryView;
}

@end
