//
//  AppDNSFilterRule.h
//  JiOSDNS
//
//  Created by 蔡杰 on 2017/9/6.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kAppDNSFilterRuleInstance [AppDNSFilterRule shareDNSFilterRule]

@interface AppDNSFilterRule : NSObject


+ (instancetype)shareDNSFilterRule;

- (NSString *)fetchIpAddressFromHost:(NSString *)host;

@end
