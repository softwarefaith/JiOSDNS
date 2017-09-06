//
//  AppDNSCache.h
//  JiOSDNS
//
//  Created by 蔡杰 on 2017/9/6.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    缓存到plist文件
    其中格式为:    "host" : ip1;ip2;ip3
 如果有ttl:    "host" : ip1;ip2;ip3,ttl

    AppDNSPList 为打包默认 DNS 映射
 */

@interface AppDNSCache : NSObject

+ (AppDNSCache *)shareCache;

- (NSArray *)ipFromCache:(NSString*)host;

- (void)saveIPToCache:(NSString *)ip withHost:(NSString*)host;

///ip is nil -》delete all ips
- (void)delHost:(NSString *)host withIP:(NSString*)ip;


@end
