//
//  AppDNSCache.m
//  JiOSDNS
//
//  Created by 蔡杰 on 2017/9/6.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

#import "AppDNSCache.h"
 NSString * const kAppDNSLocation = @"appDNS.plist";
NSString * const kDefaultAppDNSLocation = @"AppDNSPList";


@interface AppDNSCache ()

@property (nonatomic, strong) NSMutableDictionary   *dnsMap;


@end

@implementation AppDNSCache



+ (AppDNSCache *)shareCache {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AppDNSCache alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self readFromDocument];
    }
    return self;
}

- (void)readFromDocument {
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *filepath = [docPath stringByAppendingPathComponent:kAppDNSLocation];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filepath];
    if (!dic) {
        NSString *path = [[NSBundle mainBundle] pathForResource:kDefaultAppDNSLocation ofType:@"plist"];
        dic = [NSDictionary dictionaryWithContentsOfFile:path];
        if (dic) {
            [self saveToDocument:dic];
        }
    }
    if (_dnsMap == nil) {
        _dnsMap = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    [_dnsMap addEntriesFromDictionary:dic];
}

- (void)saveToDocument:(NSDictionary *)dic
{
    if (dic) {
        NSString *home = NSHomeDirectory();
        NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
        NSString *filepath = [docPath stringByAppendingPathComponent:kAppDNSLocation];
        [dic writeToFile:filepath atomically:YES];
    }
}

#pragma mark - Public
- (NSArray *)ipFromCache:(NSString *)host {
   
    __block NSString *ipString ;

    @synchronized(self) {
        
        [self.dnsMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            if ([key isEqualToString:host]) {
                
                if ([obj isKindOfClass:[NSString class]]) {
                    ipString = (NSString *)obj;
                    *stop = YES;
                }
            }
        }];
    }
    NSArray *separatedArray = [ipString componentsSeparatedByString:@","];
    NSArray *ips = [[separatedArray firstObject] componentsSeparatedByString:@";"];
    return ips;
}



@end
