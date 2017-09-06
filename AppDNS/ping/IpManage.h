//
//  IpManage.h
//  test
//
//  Created by godfery on 16/5/9.
//  Copyright (c) 2016年 joyfort. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "GBPing.h"
#ifndef test_IpManage_h
#define test_IpManage_h


@interface IpManage : NSObject<GBPingDelegate>


@property (strong, nonatomic) GBPing *ping;

@property (strong,nonatomic)  NSMutableArray* ipArray;
@property (strong,nonatomic)  NSMutableDictionary * state;

@property (strong,nonatomic)  NSString*voteIp;
@property (strong,nonatomic)  NSString*replaceIp;

@property (assign,atomic) float voteTime ;

-(void)init:(NSMutableArray*)ipArray;
+ (instancetype)getInstance;
-(void)execute ;
-(NSString*)urlreplace:(NSString*)url;

@end



#endif
