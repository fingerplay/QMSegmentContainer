//
//  NSString+QMHelper.m
//  juanpi3
//
//  Created by Jay on 16/1/15.
//  Copyright © 2016年 Jay. All rights reserved.
//

#import "NSString+QMHelper.h"

@implementation NSString (QMHelper)

- (NSNumber*)verToNumber{
    
    if (!self) {
        return @(0);
    }
    NSMutableString * string = [NSMutableString stringWithString:self];
    NSRange range = [string rangeOfString:@"."];
    
    [string replaceOccurrencesOfString:@"." withString:@"" options:NSCaseInsensitiveSearch range:NSRangeFromString([NSString stringWithFormat:@"{%lu,%lu}", (unsigned long)range.location+1, (unsigned long)self.length-range.location-1])];
    
    return [NSNumber numberWithFloat:[string floatValue]];
}

- (BOOL)isHTTPLink {
    if ([self isKindOfClass:[NSString class]]) {
        if (self.length > 0 && ([self hasPrefix:@"http://"] || [self hasPrefix:@"https://"])) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isNormalHTTPLink {
    if ([self isKindOfClass:[NSString class]] && self.length > 0 && ([self hasPrefix:@"http://"] || [self hasPrefix:@"https://"])) {
        if ([self rangeOfString:@"http://go_login"].location == NSNotFound && [self rangeOfString:@"http://go_share"].location == NSNotFound) {
            return YES;
        }
    }

    return NO;
}

- (BOOL)isJSNull {
    if (self.length == 0 || [self isEqualToString:@"null"] || [self isEqualToString:@"undefined"]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSString *)cutSearchKeywordsForJump:(NSString *)keywords
{
    //截取 url 最后一部分
    NSString *lastComponent = [keywords lastPathComponent];
    NSMutableString *targetUrl = [NSMutableString string];
    
    NSUInteger keywordsLength = lastComponent.length;
    
    //拼接url最后的部分中的数字和“_”
    for (int index = 0; index < keywordsLength; index ++) {
        
        UniChar keyword = [lastComponent characterAtIndex:index];
        if (keyword >= 48 && keyword <= 57) {
            NSString *chString = [NSString stringWithFormat:@"%c",keyword];
            [targetUrl appendString:chString];//拼接数字
        }
        
        if (keyword == 63) {//将 '?xxxx=' ---> '_'
            [targetUrl appendString:@"_"];//拼接 "_"
        }
    }
    
    return targetUrl;
}

- (NSString *)filterHtml
{
    NSString *result = self;
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString:result];
    while ([theScanner isAtEnd] == NO) {
        [theScanner scanUpToString:@"<" intoString:NULL];
        [theScanner scanUpToString:@">" intoString:&text];
        result = [result stringByReplacingOccurrencesOfString:
                  [ NSString stringWithFormat:@"%@>", text]
                                                   withString:@""];
    }
    return result;
}


- (NSString *)setupHidePhoneNum {
    if (![self isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *returnString = nil;
    
    if (self.length >= 7) {
        returnString = [self stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    else {
        returnString = self;
    }
    return returnString;
}


- (NSString *)setupHideEmail {
    if (![self isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    NSString *returnString = nil;
    
    if ([self rangeOfString:@"@"].location != NSNotFound) {
        NSArray *emailArr = [self componentsSeparatedByString:@"@"];
        NSString *headStr = [emailArr objectAtIndex:0];
        if (headStr.length > 2) {
            returnString = [self stringByReplacingCharactersInRange:NSMakeRange(headStr.length - 2, 2) withString:@"**"];
        }
        else {
            NSString *replaceString = @"*";
            if (headStr.length == 2) {
                replaceString = @"**";
            }
            returnString = [self stringByReplacingCharactersInRange:NSMakeRange(0, headStr.length) withString:replaceString];
        }
    }
    else {
        returnString = self;
    }
    
    return returnString;
}

- (NSString *)replaceSchemeToHttpsIfNeed {
    if (![self isKindOfClass:[NSString class]]) {
        return nil;
    }
    return self;
    
//--------------- 苹果强制要求开启ATS时候在此进行替换操作 ---------------
//    //以下域名不替换
//    if ([self rangeOfString:@"drp.juanpi.com"].location != NSNotFound
//        || [self rangeOfString:@"dmall.juanpi.com"].location != NSNotFound) {
//        return self;
//    }
//    if ([self isHTTPLink]) {
//        if ([self hasPrefix:@"http://"]) {
//            return [self stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
//        } else {
//            return self;
//        }
//    } else {
//        return [NSString stringWithFormat:@"https://%@",self];
//    }
}


- (UIImage *)base64StringtoImg {
    NSData *imageData = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:imageData];
}

- (NSDictionary *)dictionary{
    if (![self isKindOfClass:[NSString class]] || self.length <= 0) {
        return nil;
    }
    NSString *baseString = self;
    NSData *jsonData = [baseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        return nil;
    }
    return dic;
}

/**
 字符串是否包含emoji表情
 
 @param string 字符串
 @return 返回
 */
+ (BOOL)stringContainsEmoji:(NSString *)string{
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50 || hs == 0x231a) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    return returnValue;
}

/**
 判断字符串是否为空字符串
 
 @param string 字符串
 @return 是或否
 */
+ (BOOL)isEmptyString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}
@end
