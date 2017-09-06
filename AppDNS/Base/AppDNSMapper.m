//
//  AppHostMapper.m
//  JiOSDNS
//
//  Created by 蔡杰 on 2017/9/6.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

#import "AppDNSMapper.h"
#import "NSString+AppValidIP.h"
#import "AppDNSFilterRule.h"

#import <netdb.h>
#import <arpa/inet.h>
#import <sys/types.h>
#import <sys/socket.h>

@implementation AppDNSMapper

+ (void)asynParseHost: (NSString *)host complete: (void(^)(NSString * ip))complete {
    NSParameterAssert(complete);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        complete([self synParseHost: host]);
    });
}

+ (NSString *)synParseHost: (NSString *)host {
    if ([host validIp]) { return host; }
    if (![host validHost]) { return nil; }
    NSString * ipAddress = [kAppDNSFilterRuleInstance fetchIpAddressFromHost:host];
    if (ipAddress != nil) { return ipAddress; }
    return ipAddress;
}


#pragma mark - 机器获取

+ (NSString *)getIpAddressFromHostName: (NSString *)host {
    
    if (![host validHost]) {
        return nil;
    }
    
    NSString * ipAddress = [self getIpv6AddressFromHost: host];
    if (ipAddress == nil) {
        ipAddress = [self getIpv4AddressFromHost: host];
    }
    return ipAddress;
}

+ (NSString *)getIpv4AddressFromHost: (NSString *)host {
    if (![host validHost]) {
        return nil;
    }
    const char * hostName = host.UTF8String;
    __block struct hostent * phost = [self getHostByName: hostName execute: ^{
        phost = gethostbyname(hostName);
    }];
    if ( phost == NULL ) { return nil; }
    
    struct in_addr ip_addr;
    memcpy(&ip_addr, phost->h_addr_list[0], 4);
    
    char ip[20] = { 0 };
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    return [NSString stringWithUTF8String: ip];
}

+ (NSString *)getIpv6AddressFromHost: (NSString *)host {
    if (![host validHost]) {
        return nil;
    }
    const char * hostName = host.UTF8String;
    __block struct hostent * phost = [self getHostByName: hostName execute: ^{
        phost = gethostbyname2(hostName, AF_INET6);
    }];
    if ( phost == NULL ) { return nil; }
    
    char ip[32] = { 0 };
    char ** aliases;
    switch (phost->h_addrtype) {
        case AF_INET:
        case AF_INET6: {
            for (aliases = phost->h_addr_list; *aliases != NULL; aliases++) {
                NSString * ipAddress = [NSString stringWithUTF8String: inet_ntop(phost->h_addrtype, *aliases, ip, sizeof(ip))];
                if (ipAddress) { return ipAddress; }
            }
        } break;
            
        default:
            break;
    }
    return nil;
}


+ (struct hostent *)getHostByName: (const char *)hostName execute: (dispatch_block_t)execute {
    if (execute == nil) { return NULL; }
    __block struct hostent * phost = NULL;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSOperationQueue * queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    [queue addOperationWithBlock: ^{
        execute();
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC));
    [queue cancelAllOperations];
    return phost;
}


@end
