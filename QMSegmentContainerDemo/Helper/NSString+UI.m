//
//  NSString+UI.m
//  Juanpi_2.0
//
//  Created by Brick on 14-2-28.
//  Copyright (c) 2014年 Juanpi. All rights reserved.
//

#import "NSString+UI.h"
//#import "BBSystemValue.h"
@implementation NSString (UI)

- (CGSize)getUISize:(UIFont*)font limitWidth:(CGFloat)width {
    CGSize size = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                     options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName:font}
                                     context:nil].size;
    return CGSizeMake(ceil(size.width), ceil(size.height));
}

- (CGSize)getUISize:(UIFont*)font WithParagraphSpace:(CGFloat)space limitWidth:(CGFloat)width {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = space;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
    return [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                              options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:attributes
                              context:nil].size;
}

- (NSString *)isDetailGoodsID {
    if (![self hasSuffix:@"/r"]) {
        return @"";
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSString *resultStr = [[self componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return resultStr;
    
}

- (NSString *)addCurrencySymbol {
    return [NSString stringWithFormat:@"¥%@", self];
}

- (NSInteger)byteLength {
    NSUInteger len = self.length;
    NSString *pattern = @"[\u4e00-\u9fa5]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSInteger numMatch = [regex numberOfMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, len)];
    return len + numMatch;
}

+ (int)getCharacterFromStr:(NSString *)tempStr {
    int strlength = 0;
    char *p = (char *)[tempStr cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0; i<[tempStr lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        } else {
            p++;
        }
    }
    return strlength;
}

+ (NSArray *)descripteDifferentLabelWithFirstString:(NSString *)firstString  AndFirstFont:(UIFont *)fontF WithFirstColor:(UIColor *)firstColor WithSecondString:(NSString *)secondString AndSecondFont:(UIFont *)fontL AndSecondColor:(UIColor *)secondColor {
    if (firstString.length > 0 && secondString.length > 0) {
        NSDictionary *dicA = @{@"conten":firstString,@"color":firstColor,@"font":fontF};
        NSDictionary *dicB = @{@"conten":secondString,@"color":secondColor,@"font":fontL};
        return @[dicA,dicB];
    } else if (firstString.length > 0 && secondString.length == 0) {
        NSDictionary *dicA = @{@"conten":firstString,@"color":firstColor,@"font":fontF};
        return @[dicA];
    } else if (firstString.length == 0 && secondString.length > 0) {
        NSDictionary *dicB = @{@"conten":secondString,@"color":secondColor,@"font":fontL};
        return @[dicB];
    } else {
        return @[];
    }
}

@end


@implementation NSString (File)

+ (NSString *)pathName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//去处需要的路径
    return [documentsDirectory stringByAppendingPathComponent:@"menu.plist"];
}

+ (NSString *)leftMenuPathName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//去处需要的路径
    return [documentsDirectory stringByAppendingPathComponent:@"leftmenu.plist"];
}

+ (NSString *)pointMallPathName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"pointMall.plist"];
}

@end

@implementation NSString (LoginPassword)
+ (BOOL)checkPasswordValid:(NSString *)password {
    if (password.length == 0) {
        NSLog( @"Check password invalid:%@", password);
        return NO;
    }
    return YES;
}
@end
