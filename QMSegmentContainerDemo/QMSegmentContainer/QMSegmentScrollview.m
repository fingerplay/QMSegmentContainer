//
//  QMSegmentScrollview.m
//  juanpi3
//
//  Created by finger on 15-1-8.
//  Copyright (c) 2015年 finger. All rights reserved.
//

#import "QMSegmentScrollview.h"

@implementation QMSegmentScrollview

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        if (self.bounces) {
            return YES;
        }
        
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [pan velocityInView:self];
        if (velocity.x > 0) {
            CGPoint location = [pan locationInView:self];
            return location.x > [[UIScreen mainScreen] bounds].size.width;
        }
    }
    
    return YES;
}

@end
