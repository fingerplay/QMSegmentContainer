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

@interface ViewController ()<QMSegmentContainerDelegate>
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
    [self.view addSubview:self.categoryView];
}

- (void)loadData {
    MenuModel *menu1= [[MenuModel alloc] init];
    menu1.menuTitle = @"女装";
    menu1.bgColor = @"#0000ff";
    
    MenuModel *menu2= [[MenuModel alloc] init];
    menu2.menuTitle = @"男装";
    menu2.bgColor = @"#ff0000";
    
    MenuModel *menu3= [[MenuModel alloc] init];
    menu3.menuTitle = @"鞋包";
    menu3.bgColor = @"#00ff00";
    
    self.categories = @[menu1,menu2,menu3];
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

- (NSString *)topBar:(QMSegmentTopBar *)segmentTopBar titleForItemAtIndex:(NSInteger)index
{
    MenuModel *category = [self.categories objectAtIndex:index];
    return category.menuTitle;
}

- (QMSegmentMenuModel *)topBar:(UIView<QMSegmentTopBarProtocol> *)topBar menuModelForItemAtIndex:(NSInteger)index {
    MenuModel *category = [self.categories objectAtIndex:index];
    QMSegmentMenuModel *menu = [[QMSegmentMenuModel alloc] init];
    menu.title = category.menuTitle;
    menu.selectedTitleColor =   UIColorFromHexString(@"#13D5DC") ;
    menu.unselectedTitleColor =  RGBColor(117, 120, 122);
    menu.showType = @3;
    return menu;
}

- (BOOL)shouldRecycleContainer:(QMSegmentContainer *)segmentContainer {
    return NO;
}

- (NSInteger)numberOfItemsInSegmentContainer:(QMSegmentContainer *)segmentContainer {
    return self.categories.count;
}

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
        _categoryView = [[QMSegmentContainer alloc] initWithFrame:self.view.bounds];
        _categoryView.delegate = self;
        _categoryView.segmentTopBar.indicatorHeight = 0;
        _categoryView.delegate = self;
        _categoryView.segmentTopBar.itemPadding = 0;
        _categoryView.parentVC = self;
        _categoryView.topBarHeight = 60;
    }
    return _categoryView;
}

@end
