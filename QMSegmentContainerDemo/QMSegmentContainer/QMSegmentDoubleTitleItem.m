//
//  QMSegmentDoubleTitleItem.m
//  juanpi3
//
//  Created by finger on 16/5/25.
//  Copyright © 2016年 finger. All rights reserved.
//

#import "QMSegmentDoubleTitleItem.h"
#import "NSString+UI.h"
#import "ViewFrameAccessor.h"

@implementation QMSegmentDoubleTitleItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.titleLbl];
        [self addSubview:self.subTitleLbl];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    NSInteger titleHeight = [self.titleLbl.text getUISize:[UIFont systemFontOfSize:16] limitWidth:MAXFLOAT].height;
    NSInteger subTitleHeight = [self.subTitleLbl.text getUISize:[UIFont systemFontOfSize:11] limitWidth:MAXFLOAT].height;
    
    [self.titleLbl setFrame:CGRectMake(0, (self.height - titleHeight - 4 - subTitleHeight)/2, self.width, titleHeight)];
    [self.subTitleLbl setFrame:CGRectMake(0, self.titleLbl.bottom + 2, self.width, subTitleHeight)];
}

- (void)setSelected:(BOOL)selected{
    if (selected) {
        self.titleLbl.textColor = [UIColor redColor];
        self.subTitleLbl.textColor = [UIColor redColor];
    }else{
        self.titleLbl.textColor = [UIColor grayColor];
        self.subTitleLbl.textColor = [UIColor grayColor];
    }
}

#pragma mark - Property Method

- (UILabel *)titleLbl{
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLbl.backgroundColor = [UIColor clearColor];
        _titleLbl.font = [UIFont systemFontOfSize:16];
        _titleLbl.textColor = [UIColor grayColor];
        _titleLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLbl;
}

- (UILabel *)subTitleLbl{
    if (!_subTitleLbl) {
        _subTitleLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        _subTitleLbl.backgroundColor = [UIColor clearColor];
        _subTitleLbl.font = [UIFont systemFontOfSize:11];
        _subTitleLbl.textAlignment = NSTextAlignmentCenter;
        _subTitleLbl.textColor = [UIColor grayColor];
    }
    return _subTitleLbl;
}

@end
