//
//  AppDNSFilterRule.m
//  JiOSDNS
//
//  Created by 蔡杰 on 2017/9/6.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

#import "AppDNSFilterRule.h"

@implementation AppDNSFilterRule

+ (instancetype)shareDNSFilterRule {
    
    static AppDNSFilterRule *dnsFilter = nil;
    
    static dispatch_once_t once_t;
    dispatch_once(&once_t, ^{
        dnsFilter = [[AppDNSFilterRule alloc] init];
    });
    return dnsFilter;
}

- (NSString *)fetchIpAddressFromHost:(NSString *)host {
    
    
    return @"123.890";
}

@end
