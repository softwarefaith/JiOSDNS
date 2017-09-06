//
//  NSString+AppValidIP.h
//  JiOSDNS
//
//  Created by 蔡杰 on 2017/9/6.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AppValidIP)

/*IP4   IP6 格式
 
 http://api.example.com/path 替换成：http://124.12.42.xx/path，
 如果是在 IPv6 的环境下则是：http://[2002:0:0:0:0:0:7c0c:xxx]/path。
 
*/
//先判断是否为ipv6 在判断是否为ipv4
- (BOOL)validIp;

- (BOOL)validIpv4;

- (BOOL)validIpv6;

- (BOOL)validHost;

@end
