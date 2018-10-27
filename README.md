# QMSegmentContainer
一种自定义tabbar

## 特点
1.支持文字、图标、图文或者自定义的tabitem
2.支持左右滑动切换tab对应的子页面，切换前后子页面的viewWillAppear/viewWillDisappear/viewDidAppear/viewDidDisappear方法会得到响应
3.支持在页面顶部或者底部显示tabbar
4.支持tabbar的单独隐藏和显示
5.支持动态插入、删除tabitem,插入或删除后其他tabitem会自动改变位置

## 使用方式
以tabbar放在页面底部，页面全屏展现为例：
1. 在ViewController中申明其遵循QMSegmentContainerDelegate。

2. 并且 在lazyload方法中初始化QMSegmentContainer实例,并在ViewDidLoad中addSubView添加到页面上。
    - (QMSegmentContainer *)categoryView {
        if (_categoryView == nil) {
           QMSegmentContainer *categoryView = [[QMSegmentContainer alloc] initWithFrame:self.view.bounds];
           categoryView.isBottomBar = YES;
           categoryView.allowGesture = NO;
           categoryView.topBarHeight =    bottomHeight;
           categoryView.segmentTopBar.indicatorHeight = 0;
           categoryView.delegate = self;
           categoryView.segmentTopBar.itemPadding = 0;
           categoryView.parentVC = self;
           _categoryView = categoryView;
         }
         return _categoryView;
    }
  
  3. 实现QMSegmentContainerDelegate方法。其中以下方法是必须要实现的：
  
       //获取tabitem的数量
        - (NSInteger)numberOfItemsInTopBar:(UIView<QMSegmentTopBarProtocol> *)topBar;
       //每一个tabitem对应的子页面，支持UIView和UIViewController及其子类
        - (id)segmentContainer:(QMSegmentContainer *)segmentContainer contentForIndex:(NSInteger)index；
  
     以下方法选择其中一个实现：
       - (NSString *)topBar:(QMSegmentTopBar *)segmentTopBar titleForItemAtIndex:(NSInteger)index； //文字模式
       - (NSString *)topBar:(UIView<QMSegmentTopBarProtocol> *)segmentTopBar iconForItemAtIndex:(NSInteger)index； //图片模式
       - (QMSegmentMenuModel *)topBar:(UIView<QMSegmentTopBarProtocol> *)topBar menuModelForItemAtIndex:(NSInteger)index;  //图文模式
  
     如果想要获取点击事件，可以实现：
     -(void)segmentContainer:(QMSegmentContainer *)segmentContainer didSelectedItemAtIndex:(NSInteger)index; //默认赋值与点击切换时均触发
     - (void)segmentContainer:(QMSegmentContainer *)segmentContainer didClickedItemAtIndex:(NSInteger)index; //仅点击切换时触发
