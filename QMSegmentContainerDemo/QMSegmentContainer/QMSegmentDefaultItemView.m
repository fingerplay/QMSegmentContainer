//
//  QMSegmentDefaultItemView.m
//  juanpi3
//
//  Created by 彭军 on 16/7/5.
//  Copyright © 2016年 彭军. All rights reserved.
//

#import "QMSegmentDefaultItemView.h"
#import "UIButton+WebCache.h"
#import "UIButton+Category.h"
#import "ViewFrameAccessor.h"
#import "QMDeviceHelper.h"
#import "UIImage+Category.h"
#import "NSString+QMHelper.h"


#define indicatorOffset 5.0

@implementation QMSegmentDefaultItemView
@synthesize selected = _selected;

- (id)initWithFrame:(CGRect)frame item:(QMSegmentMenuModel *)item isCanShowPopupMenu:(BOOL)isCanShowPopupMenu {
    self = [super initWithFrame:frame];
    if (self) {
        _item = item;
        if (item.unselectedBgColor) {
            [self setBackgroundColor:item.unselectedBgColor forState:UIControlStateNormal];
        }else{
            [self setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        }
        if (item.selectedBgColor) {
            [self setBackgroundColor:item.selectedBgColor forState:UIControlStateSelected];
        }else{
            [self setBackgroundColor:[UIColor clearColor] forState:UIControlStateSelected];
        }
        
        [self setTitleColor:item.unselectedTitleColor forState:UIControlStateNormal];
        [self setTitleColor:item.selectedTitleColor forState:UIControlStateSelected];
        if (item.titleFont) {
            self.titleLabel.font = item.titleFont;
        }else{
            self.titleLabel.font = ScreenScale() == 3 ? [UIFont systemFontOfSize:15] : [UIFont systemFontOfSize:14];
        }
        
        NSString *selectedPH = item.phSelectedIcon;
        NSString *unselectedPH = item.phUnselectedIcon;
        
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
        
        
        if ([item.showType integerValue]==1 && !isCanShowPopupMenu) {
            
            _itemImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _itemImageButton.userInteractionEnabled = NO;
            _itemImageButton.imageView.contentMode = UIViewContentModeScaleToFill;
            _itemImageButton.frame = self.bounds;
            _itemImageButton.backgroundColor = [UIColor clearColor];
            [self setTitle:item.title forState:UIControlStateNormal];
            __weak typeof(self) wSelf = self;
            if (item.unselectedIcon.length>0) {
                [_itemImageButton sd_setBackgroundImageWithURL:[NSURL URLWithString:item.unselectedIcon] forState:UIControlStateNormal  placeholderImage:unselectedPHImage options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    __strong typeof(wSelf) sSelf = wSelf;
                    if (image) {
                        [sSelf setTitle:nil forState:UIControlStateNormal];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            CGFloat imageWidth = (image.size.width/image.size.height) * frame.size.height;
                            self.itemImageButton.frame = CGRectMake(indicatorOffset/2, 0, imageWidth, frame.size.height);
                            sSelf.frame = CGRectMake(0, 0, self.itemImageButton.width + indicatorOffset, frame.size.height);
                            [sSelf setNeedsLayout];
                            if (sSelf.delegate && [sSelf.delegate respondsToSelector:@selector(defaultItemViewDownLoadSuccess)]) {
                                [sSelf.delegate defaultItemViewDownLoadSuccess];
                            }
                        });
                    }else{
                        [sSelf setTitle:item.title forState:UIControlStateNormal];
                        [sSelf sizeToFit];
                        sSelf.frame = CGRectMake(sSelf.frame.origin.x, sSelf.frame.origin.y, sSelf.width + indicatorOffset, frame.size.height);
                        [sSelf setNeedsLayout];
                        if (sSelf.delegate && [sSelf.delegate respondsToSelector:@selector(defaultItemViewDownLoadSuccess)]) {
                            [sSelf.delegate defaultItemViewDownLoadSuccess];
                        }
                    }
                    
                }];
                
            }else{
                [self sizeToFit];
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.width + indicatorOffset, frame.size.height);
            }
            
            if (item.selectedIcon.length>0) {
                [_itemImageButton sd_setBackgroundImageWithURL:[NSURL URLWithString:item.selectedIcon] forState:UIControlStateSelected placeholderImage:selectedPHImage options:SDWebImageHighPriority];
            }
            [self addSubview:_itemImageButton];
        }else if ([item.showType integerValue]==3&& !isCanShowPopupMenu){
            CGSize size = [item.title sizeWithAttributes:@{NSFontAttributeName:item.titleFont}];
            if (size.width>=self.width) {
                self.width = size.width + indicatorOffset;
            }

            
            _itemImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _itemImageButton.frame = CGRectMake(self.width/2.0-15, 4.5, 30, 30);
            _itemImageButton.backgroundColor = [UIColor clearColor];
            _itemImageButton.userInteractionEnabled = NO;
            
            [_itemImageButton sd_setImageWithURL:[NSURL URLWithString:item.unselectedIcon] forState:UIControlStateNormal placeholderImage:unselectedPHImage options:SDWebImageHighPriority];
            [_itemImageButton sd_setImageWithURL:[NSURL URLWithString:item.selectedIcon] forState:UIControlStateSelected placeholderImage:selectedPHImage options:SDWebImageHighPriority];
            
            _itemTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _itemTitleButton.titleLabel.font = item.titleFont;
            [_itemTitleButton setTitleColor:item.unselectedTitleColor forState:UIControlStateNormal];
            [_itemTitleButton setTitleColor:item.selectedTitleColor forState:UIControlStateSelected];
            [_itemTitleButton setTitle:item.title forState:UIControlStateNormal];
            _itemTitleButton.userInteractionEnabled = NO;
            _itemTitleButton.frame = CGRectMake(0, _itemImageButton.frame.origin.y+_itemImageButton.height, self.width, 12);
            [self addSubview:_itemImageButton];
            [self addSubview:_itemTitleButton];
        }else{
  
            CGSize size = [item.title sizeWithAttributes:@{NSFontAttributeName:item.titleFont}];
            _itemTitleButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _itemTitleButton.titleLabel.font = item.titleFont;
            [_itemTitleButton setTitleColor:item.unselectedTitleColor forState:UIControlStateNormal];
            [_itemTitleButton setTitleColor:item.selectedTitleColor forState:UIControlStateSelected];
            [_itemTitleButton setTitle:item.title forState:UIControlStateNormal];
            _itemTitleButton.userInteractionEnabled = NO;
            _itemTitleButton.frame = CGRectMake(0, 0, size.width+indicatorOffset, frame.size.height);
            [self addSubview:_itemTitleButton];
            
            if (item.segmentTag && item.segmentTag.text.length) {
                self.markTag = [self markTagWith:item.segmentTag];
                self.width = _itemTitleButton.width  + self.markTag.width;
                self.markTag.left = _itemTitleButton.right + 2;
                self.markTag.top = (frame.size.height - self.markTag.height)*0.5;
                [self addSubview:self.markTag];
            }else{
                self.width = _itemTitleButton.width;
            }
        }
        _redPointView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:RGBColor(255, 70, 78) size:CGSizeMake(9, 9)]];
        CGRect redPointFrame = _redPointView.frame;
        redPointFrame.origin.x = CGRectGetWidth(frame) - 27;
        redPointFrame.origin.y = 3;
        _redPointView.frame = redPointFrame;
        _redPointView.hidden = YES;
        _redPointView.layer.masksToBounds = YES;
        _redPointView.layer.cornerRadius = 4.5;
        [self addSubview:_redPointView];
    }
    return self;
}


-(void)setFrame:(CGRect)frame{

    [super setFrame:frame];
}

- (UILabel *)markTagWith:(QMSegmentTag *)tag{
    UIFont *tagFont = [UIFont systemFontOfSize:9];
    CGSize size = [self sizeWithString:tag.text font:tagFont];
    UILabel *markTag = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width+4, 12)];
    markTag.textAlignment = NSTextAlignmentCenter;
    
    markTag.backgroundColor = tag.bg_color.length>0 ? [UIColor colorWithHexString:tag.bg_color] : [UIColor clearColor];
    UIColor *titleColor = tag.text_color.length>0 ? [UIColor colorWithHexString:tag.text_color] : [UIColor redColor];
    UIColor *borderColor = tag.border_color.length>0 ? [UIColor colorWithHexString:tag.border_color] : [UIColor redColor];
    markTag.font = tagFont;
    markTag.textColor = titleColor;
    markTag.layer.borderColor = borderColor.CGColor;
    markTag.layer.borderWidth = 0.5;
    markTag.text = tag.text;
    return markTag;
}

/**
 平均分割模式下，重置itemTitleButton 和 markTag的位置
 */
- (void)averageItemView{

    CGFloat width = self.width;
    
    if ([_item.showType integerValue] == 2) {
     
        if (_item.segmentTag && _item.segmentTag.text.length) {
            
            CGFloat itemWidth = self.markTag.right - self.itemTitleButton.left;
            
            self.itemTitleButton.left = (width - itemWidth)*0.5;
            
            self.markTag.left = self.itemTitleButton.right + 2;
            
        }else{
            self.itemTitleButton.frame = CGRectMake(0, 0, width, self.height);
        }
    }
    
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    _selected = selected;
    if (_itemImageButton) {
        _itemImageButton.selected = selected;
    }
    
    if (_itemTitleButton) {
        _itemTitleButton.selected = selected;
    }
    
}

-(NSString *)cacheKeyForURL:(NSString *)url{
    return [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:url]];
}


- (CGSize)sizeWithString:(NSString *)string font:(UIFont *)font {
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] == NSOrderedDescending) {
        NSDictionary *attributes = @{NSFontAttributeName:font};
        return [string boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    }else{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        return [string sizeWithFont:font];
#pragma clang diagnostic pop
    }
}
@end
