//
//  QMSegmentItemButton.m
//  juanpi3
//
//  Created by finger on 16/5/3.
//  Copyright © 2016年 finger. All rights reserved.
//

#import "QMSegmentIconTitleItem.h"
#import "ViewFrameAccessor.h"
#import "MacroDefines.h"

@implementation QMSegmentIconTitleItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.iconImageView];
        [self addSubview:self.typeImageView];
        [self addSubview:self.titleLbl];
        [self addSubview:self.typeLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
   
    [self.iconImageView setFrame:CGRectMake(self.width/2.0-15, 4.5, 30, 30)];
//    [self.typeImageView setFrame:CGRectMake(self.iconImageView.right - 4 - 12, self.iconImageView.bottom - 4 - 12, 12, 12)];
    [self.typeLabel setFrame:CGRectMake(self.iconImageView.right - 4 - 12, self.iconImageView.bottom - 4 - 12, 12, 12)];
    self.typeLabel.layer.cornerRadius = 6;
    self.typeLabel.layer.masksToBounds = YES;
    
    [self.titleLbl setFrame:CGRectMake(0, 34.5, self.width, 12)];
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        if (self.selectedBGColor.length) {
            self.backgroundColor = [UIColor colorWithHexString:self.selectedBGColor];
            self.titleLbl.textColor = [UIColor whiteColor];
            
            self.typeLabel.textColor = [UIColor colorWithHexString:self.selectedBGColor];
            self.typeLabel.backgroundColor = [UIColor whiteColor];
            return;
        }
        
        self.typeLabel.backgroundColor = [UIColor clearColor];
        self.titleLbl.textColor = [UIColor redColor];
    }else{
        if (self.normalBGColor.length) {
            self.backgroundColor = [UIColor colorWithHexString:self.normalBGColor];
            self.titleLbl.textColor = [UIColor whiteColor];
            
            self.typeLabel.textColor = [UIColor colorWithHexString:self.selectedBGColor];
            self.typeLabel.backgroundColor = [UIColor whiteColor];
            return;
        }
        
        self.typeLabel.backgroundColor = [UIColor clearColor];
        self.titleLbl.textColor = [UIColor grayColor];
    }
}

- (void)setCornerMaskType:(NSInteger)cornerMaskType
{
    self.typeLabel.hidden = NO;
    _cornerMaskType = cornerMaskType;
    switch (cornerMaskType) {
        case 1:{
            self.typeLabel.text = @"HOT";
            self.typeLabel.backgroundColor = [UIColor colorWithHexString:@"ff475a"];
        }
            break;
        case 2:{
            self.typeLabel.text = @"NEW";
            self.typeLabel.backgroundColor = [UIColor colorWithHexString:@"58a9e0"];
        }
            break;
        case 3:{
            self.typeLabel.text = @"推荐";
            self.typeLabel.backgroundColor = [UIColor colorWithHexString:@"ff9200"];
        }
            break;
        default:{
            self.typeLabel.hidden = YES;
        }
            break;
    }
}

#pragma mark - Property Method

- (UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _iconImageView;
}

- (UIImageView *)typeImageView
{
    if (!_typeImageView) {
        _typeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _typeImageView;
}

- (UILabel *)typeLabel
{
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _typeLabel.font = [UIFont systemFontOfSize:5];
        _typeLabel.textAlignment = NSTextAlignmentCenter;
        _typeLabel.textColor = [UIColor whiteColor];
    }
    return _typeLabel;
}

- (UILabel *)titleLbl{
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLbl.backgroundColor = [UIColor clearColor];
        _titleLbl.font = [UIFont systemFontOfSize:12];
        _titleLbl.textAlignment = NSTextAlignmentCenter;
        _titleLbl.textColor = [UIColor grayColor];
    }
    return _titleLbl;
}

@end
