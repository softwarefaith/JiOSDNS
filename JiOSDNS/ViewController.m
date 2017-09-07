//
//  ViewController.m
//  JiOSDNS
//
//  Created by 蔡杰 on 2017/9/5.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

#import "ViewController.h"

#import "AppDNSParser.h"
#import "NSString+AppValidIP.h"

#import "AppDNSMapper.h"
#import "IpManage.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (IBAction)test:(id)sender {
    
    //1.解析 www.163.com&ttl=1  //111.206.186.244;111.206.186.245,23  其中23是ttl缓存时间
    //2.www.baidu.com  :  61.135.169.125;61.135.169.121   没有ttl
 //  NSArray *ips =  [AppDNSParser ipSynParseWithHost:@"www.baidu.com"];
    
    NSString * ip = [AppDNSMapper fetchIPFromHost:@"www.baid.com"];
   NSLog(@"解析 ip = %@ ",ip );
    
    IpManage *ips = [IpManage getInstance];
    [ips init:@[@"111.206.186.244",@"61.135.169.121"].mutableCopy];
    [ips execute];
    NSLog(@"解析 ipqqqqqqq---- = %@ ",ips.state);

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
