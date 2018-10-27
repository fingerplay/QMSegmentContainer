//
//  QMSementGradualItemView.m
//  juanpi3
//
//  Created by Alvin on 2017/11/16.
//  Copyright © 2017年 Alvin. All rights reserved.
//

#import "QMSegmentGradualItemView.h"
#import "QMSegmentDefaultItemView.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "NSString+QMHelper.h"

#define indicatorOffset 5.0

@interface QMSegmentGradualItemView()

@property (nonatomic, strong) UIButton *activeBtn;
@property (nonatomic, strong) UIButton *unActiveBtn;
@property (nonatomic, strong) QMSegmentMenuModel *item;

@end

@implementation QMSegmentGradualItemView

- (instancetype)initWithFrame:(CGRect)frame item:(QMSegmentMenuModel *)item {
    if (self = [super initWithFrame:frame]) {
        _item = item;
        [self addSubview:self.unActiveBtn];
        [self addSubview:self.activeBtn];
        [self reload];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame item:nil];
}

- (void)refreshItem:(QMSegmentMenuModel *)item {
    _item = item;
    [self reload];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.activeBtn.frame = self.bounds;
    self.unActiveBtn.frame = self.bounds;
}

- (void)reload {
    if (!self.item) return;
    [self setNeedsLayout];
    
    QMSegmentMenuModel *item = self.item;
    NSString *selectedPH = self.item.phSelectedIcon;
    NSString *unselectedPH = self.item.phUnselectedIcon;
    
    UIImage *selectedPHImage = nil;
    UIImage *unselectedPHImage = nil;
    
    
    if ([selectedPH isHTTPLink]) {
        selectedPHImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[self cacheKeyForURL:selectedPH]];
    }else{
         selectedPHImage = [UIImage imageNamed:selectedPH];
    }
    
    if ([unselectedPH isHTTPLink]) {
        unselectedPHImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[self cacheKeyForURL:unselectedPH]];
    }else{
        unselectedPHImage = [UIImage imageNamed:unselectedPH];
    }
    
    if ([self.item.showType integerValue] == 1) {
        
        if (self.item.selectedIcon.length) {
            [self.activeBtn setTitle:nil forState:UIControlStateNormal];
            self.activeBtn.userInteractionEnabled = NO;
            self.activeBtn.imageView.contentMode = UIViewContentModeScaleToFill;

            [self.activeBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:self.item.selectedIcon] forState:UIControlStateNormal placeholderImage:selectedPHImage completed:nil];
            

        }
        
        if (self.item.unselectedIcon.length) {
            [self.unActiveBtn setTitle:nil forState:UIControlStateNormal];
            self.unActiveBtn.userInteractionEnabled = NO;
            self.unActiveBtn.imageView.contentMode = UIViewContentModeScaleToFill;
       
            [self.unActiveBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:self.item.unselectedIcon] forState:UIControlStateNormal placeholderImage:unselectedPHImage completed:nil];
            

        }
    } else if ([self.item.showType integerValue] == 2) {
        self.activeBtn.titleLabel.font = item.titleFont;
        [self.activeBtn setTitleColor:item.selectedTitleColor forState:UIControlStateNormal];
        [self.activeBtn setTitle:item.title forState:UIControlStateNormal];
        self.activeBtn.userInteractionEnabled = NO;
        self.activeBtn.imageView.image = nil;
        [self.activeBtn setBackgroundImage:nil forState:UIControlStateNormal];
        
        self.unActiveBtn.titleLabel.font = item.titleFont;
        [self.unActiveBtn setTitleColor:item.unselectedTitleColor forState:UIControlStateNormal];
        [self.unActiveBtn setTitle:item.title forState:UIControlStateNormal];
        self.unActiveBtn.userInteractionEnabled = NO;
        self.unActiveBtn.imageView.image = nil;
        [self.unActiveBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }
}

- (void)setGradient:(CGFloat)gradient {
    _gradient = gradient;
    self.activeBtn.alpha = gradient; 
    self.unActiveBtn.alpha = 1 - gradient;
}

#pragma mark - helpMethods
-(NSString *)cacheKeyForURL:(NSString *)url{
    return [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:url]];
}


#pragma mark - properties
- (UIButton *)activeBtn {
    if (!_activeBtn) {
        _activeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _activeBtn.contentSize = self.frame.size;
    }
    return _activeBtn;
}

- (UIButton *)unActiveBtn {
    if (!_unActiveBtn) {
        _unActiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _unActiveBtn.contentSize = self.frame.size;
    }
    return _unActiveBtn;
}

@end
