//
//  UIButton+Category.h
//  SmartHome
//
//  Created by Wolfire on 29/06/2017.
//  Copyright © 2017 EverGrande. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Category)

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;
- (void)setButtonTitle:(NSString *)title;

- (void)adjustButtonTitleToBottom;

@end
