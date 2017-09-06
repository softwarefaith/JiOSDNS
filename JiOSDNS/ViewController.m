//
//  ViewController.m
//  JiOSDNS
//
//  Created by 蔡杰 on 2017/9/5.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

#import "ViewController.h"

#import "AppDNSParser.h"

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
   NSArray *ips =  [AppDNSParser ipSynParseWithHost:@"www.baidu.com"];
    
   NSLog(@"解析 ip = %@ ",ips);
    
    
    NSString *iptemp = @"111.206.186.244;111.206.186.245,23";
    NSArray *arr = [iptemp componentsSeparatedByString:@","];
    NSArray *arrs = [[arr firstObject] componentsSeparatedByString:@";"];

    NSLog(@"解析 ips = %@ ",arrs);
    
    

    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end