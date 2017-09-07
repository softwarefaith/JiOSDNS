//
//  AppHostMapper.h
//  JiOSDNS
//
//  Created by 蔡杰 on 2017/9/6.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface AppDNSMapper : NSObject



//DNS解析功能

+ (void)asynParseHost: (NSString *)host complete: (void(^)(NSString * ip))complete;

+ (NSString *)synParseHost: (NSString *)host;


//通过手机方式 - 本地获取  先 6  后 4
+ (NSString *)getIpAddressFromHostName: (NSString *)host;
+ (NSString *)getIpv4AddressFromHost: (NSString *)host;
+ (NSString *)getIpv6AddressFromHost: (NSString *)host;

//通过系统CFHostRef方式获取  添加libresolv
+ (NSString *)fetchIPFromHost:(NSString *)host;


@end
