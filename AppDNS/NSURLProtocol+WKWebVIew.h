//
//  NSURLProtocol+WKWebVIew.h
//  JiOSDNS
//
//  Created by 蔡杰 on 2017/9/6.
//  Copyright © 2017年 蔡杰. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSURLProtocol (WKWebVIew)

+ (void)wk_registerScheme:(NSString*)scheme;

+ (void)wk_unregisterScheme:(NSString*)scheme;


@end
