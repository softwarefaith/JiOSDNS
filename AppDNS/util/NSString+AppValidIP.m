//
//  NSString+AppValidIP.m
//  JiOSDNS
//
//  Created by 蔡杰 on 2017/9/6.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

#import "NSString+AppValidIP.h"

@implementation NSString (AppValidIP)

- (BOOL)validIp {
    if (!([self length] > 0)) {
        return NO;
    }
    return [self validIpv6] | [self validIpv4];
}

- (BOOL)validIpv4 {
    if (!([self length] > 0)) {
        return NO;
    }
    NSString * ipRegExp = @"^(([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3})|(0\\.0\\.0\\.0)$";
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF matches %@", ipRegExp];
    return [predicate evaluateWithObject: self];
}

- (BOOL)validIpv6 {
    if (!([self length] > 0)) {
        return NO;
    }
    NSString * ipRegExp = @"^(^((\\p{XDigit}{1,4}):){7}(\\p{XDigit}{1,4})$)|(^(::((\\p{XDigit}//{1,4}):){0,5}(\\p{XDigit}{1,4}))$)|(^((\\p{XDigit}{1,4})(:|::)){0,6}(\\p//{XDigit}{1,4})$)$";
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF matches %@", ipRegExp];
    return [predicate evaluateWithObject: self];
}

- (BOOL)validHost {
    
    if (!([self length] > 0)) {
        return NO;
    }
    NSString * hostRegExp = @"((http[s]?|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF matches %@", hostRegExp];
    return [predicate evaluateWithObject: self];
}

@end
