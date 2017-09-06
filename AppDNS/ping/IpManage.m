//
//  IpManage.m
//  test
//
//  Created by godfery on 16/5/9.
//  Copyright (c) 2016年 joyfort. All rights reserved.
//

#import "IpManage.h"



@implementation IpManage

 //*state;
+ (instancetype)getInstance {
    static IpManage *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[IpManage alloc] init];
    });
    return sharedGameKitHelper;

}
-(NSString*)urlreplace:(NSString*)url {
    if(self.voteIp) {
        return [url stringByReplacingOccurrencesOfString:self.replaceIp withString:self.voteIp];
    }
    
    return url;
}

-(void)execute {
    [self doVote];
    NSString * ip = [self.ipArray lastObject];
    [self.ipArray removeLastObject];
    if(ip) {
        [self doPing:ip];
    }
}
-(void)init:(NSMutableArray*)ipArray {
    
    self.ipArray = [[NSMutableArray alloc]init];
    self.ipArray = ipArray;
    self.voteTime = 1;
    self.state =[[NSMutableDictionary alloc]init];
    
//    NSMutableArray *a = [[NSMutableArray alloc]init];
//    [a addObject:@"google.com"];
//    //[a addObject:@"www.baidu.com"];
//    
//    NSLog(@"%@",a);
   
    
 
}
-(void)doVote{
    float a =0;
    NSLog(@"voteIp---%@",self.voteIp);
    for (NSString* k in [self.state allKeys]) {
        a = [[self.state valueForKey:k] floatValue];
        if(a<self.voteTime) {
            self.voteTime = a;
            self.voteIp = k;

        }
        
    }
}
-(void)doPing:(NSString*)ip{
    self.ping = [[GBPing alloc] init];
    self.ping.host = ip;
    self.ping.delegate = self;
    self.ping.timeout = 1.0;
    self.ping.pingPeriod = 0.9;
    self.ping.pingCount = 4;
    
    [self.ping setupWithBlock:^(BOOL success, NSError *error) { //necessary to resolve hostname
        if (success) {
            //start pinging
            [self.ping startPinging];
            
            //stop it after 5 seconds
            //            [NSTimer ti]
            //            [NSTimer timerWithTimeInterval:5 invocation:<#(NSInvocation *)#> repeats:false:5 repeats:NO withBlock:^{
            //                NSLog(@"stop it");
            //                [self.ping stop];
            //                self.ping = nil;
            //            }];
            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //                NSLog(@"stop it");
            //                [self.ping stop];
            //                self.ping = nil;
            //            });
        }
        else {
            NSLog(@"failed to start");
            [self.ping stop];
            //    [state setValue:(NSInteger)summary.ttl forKey:summary.host];
           
            [self execute];
        }
    }];
}

-(void)ping:(GBPing *)pinger didReceiveReplyWithSummary:(GBPingSummary *)summary {
    NSTimeInterval time = summary.rtt;
    
    NSString *string = [NSString stringWithFormat:@"%06f",time];
    [self.state setObject:string forKey:summary.host];
    
     NSLog(@"REPLY>  %@", self.state);
    [self.ping stop];
//    [state setValue:(NSInteger)summary.ttl forKey:summary.host];
        NSLog(@"REPLY>  %@", summary);
    [self execute];
}

-(void)ping:(GBPing *)pinger didReceiveUnexpectedReplyWithSummary:(GBPingSummary *)summary {
    NSLog(@"BREPLY> %@", summary);
}

//-(void)ping:(GBPing *)pinger didSendPingWithSummary:(GBPingSummary *)summary {
//    NSLog(@"SENT>   %@", summary);
//}

-(void)ping:(GBPing *)pinger didTimeoutWithSummary:(GBPingSummary *)summary {
    [self.state setObject:@"100" forKey:summary.host];
         NSLog(@"TIMOUT>  %@", self.state);
        [self.ping stop];
        NSLog(@"TIMOUT> %@", summary);
        [self execute];
}

-(void)ping:(GBPing *)pinger didFailWithError:(NSError *)error {
    NSLog(@"FAIL>   %@", error);
}

-(void)ping:(GBPing *)pinger didFailToSendPingWithSummary:(GBPingSummary *)summary error:(NSError *)error {
    NSLog(@"FSENT>  %@, %@", summary, error);
}


@end
