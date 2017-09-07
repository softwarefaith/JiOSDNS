//
//  AppHostParser.m
//  JiOSDNS
//
//  Created by 蔡杰 on 2017/9/6.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

#import "AppDNSParser.h"



const static NSString *kAppDNSPodURL = @"http://119.29.29.29/d?dn=";
#define APPDNSPodURL(host) [NSString stringWithFormat:@"%@%@",kAppDNSPodURL, host]


@implementation AppDNSParser




+ (NSArray*) ipSynParseWithHost:(NSString*)host {
    if (!([host length] > 0)) {
        return nil;
    }
    //NSURLSession 没有同步 需要信号变量 转为同步
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:APPDNSPodURL(host)]];
   __block NSHTTPURLResponse *hostResponse;
    __block  NSData *hostData;
 
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"ipSynParseWithHost error = %@",error);
        hostData = data;
        hostResponse = (NSHTTPURLResponse*)response;
         dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    if (hostResponse.statusCode != 200) {
        return nil;
    }
    if (hostData && [hostData length] > 0) {
        NSString *ip = [[NSString alloc]initWithData:hostData encoding:NSUTF8StringEncoding];
        NSArray *separatedArray = [ip componentsSeparatedByString:@","];
        NSArray *ips = [[separatedArray firstObject] componentsSeparatedByString:@";"];

        return ips;
    }
    return nil;
}

+ (void)ipAsynParseWithHost:(NSString*)host withComplete:(AppDNSParserCallback)hostCallback {
    if (!([host length] > 0)) {
        if (hostCallback) {
            hostCallback(nil,nil,[NSError errorWithDomain:@"host empty" code:-1 userInfo:nil]);
            return;
        }
    }
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:APPDNSPodURL(host)]];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (hostCallback) {
            
            NSString *ip = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSArray *separatedArray = [ip componentsSeparatedByString:@","];
            NSArray *ips = [[separatedArray firstObject] componentsSeparatedByString:@";"];
            hostCallback(ips,([separatedArray count] > 1?[separatedArray lastObject]:0),error);
        }
    }];
    [dataTask resume];
}



@end
