//
//  AppDNSInterceptor.m
//  JiOSDNS
//
//  Created by 蔡杰 on 2017/9/6.
//  Copyright © 2017年 蔡杰. All rights reserved.
//

#import "AppDNSInterceptor.h"
#import <objc/runtime.h>

static NSString * const kAppDNSInterceptorKey = @"AppDNSInterceptorKey";


typedef NSURLSessionConfiguration*(*SessionConfigConstructor)(id,SEL);
static SessionConfigConstructor orig_defaultSessionConfiguration;
static SessionConfigConstructor orig_ephemeralSessionConfiguration;

static NSURLSessionConfiguration* Interceptor_defaultSessionConfiguration(id self, SEL _cmd)
{
    NSURLSessionConfiguration* config = orig_defaultSessionConfiguration(self,_cmd); // call original method
   
    return config;
}

static NSURLSessionConfiguration* Interceptor_ephemeralSessionConfiguration(id self, SEL _cmd)
{
    NSURLSessionConfiguration* config = orig_ephemeralSessionConfiguration(self,_cmd); // call original method

    return config;
}

static void setEnabledForSessionConfiguration(BOOL enable,NSURLSessionConfiguration* sessionConfig) {
    // Runtime check to make sure the API is available on this version
    if (   [sessionConfig respondsToSelector:@selector(protocolClasses)]
        && [sessionConfig respondsToSelector:@selector(setProtocolClasses:)])
    {
        NSMutableArray * urlProtocolClasses = [NSMutableArray arrayWithArray:sessionConfig.protocolClasses];
        Class protoCls = [NSClassFromString(@"AppDNSInterceptor") class];
        if (enable && ![urlProtocolClasses containsObject:protoCls])
        {
            [urlProtocolClasses insertObject:protoCls atIndex:0];
        }
        else if (!enable && [urlProtocolClasses containsObject:protoCls])
        {
            [urlProtocolClasses removeObject:protoCls];
        }
        sessionConfig.protocolClasses = urlProtocolClasses;
    }
    else
    {
        NSLog(@"[OHHTTPStubs]  is only available when running on iOS7+/OSX9+. "
              @"Use conditions like 'if ([NSURLSessionConfiguration class])' to only call "
              @"this method if the user is running iOS7+/OSX9+.");
    }
}

IMP InterceptorReplaceMethod(SEL selector,
                             IMP newImpl,
                             Class affectedClass,
                             BOOL isClassMethod)
{
    Method origMethod = isClassMethod ? class_getClassMethod(affectedClass, selector) : class_getInstanceMethod(affectedClass, selector);
    IMP origImpl = method_getImplementation(origMethod);
    
    if (!class_addMethod(isClassMethod ? object_getClass(affectedClass) : affectedClass, selector, newImpl, method_getTypeEncoding(origMethod)))
    {
        method_setImplementation(origMethod, newImpl);
    }
    
    return origImpl;
}


//代码来之与OHHTTPStubs
@interface NSURLSessionConfiguration(AppInterceptorSupport)
@end

@implementation NSURLSessionConfiguration(AppInterceptorSupport)

+(void)load
{
    orig_defaultSessionConfiguration = (SessionConfigConstructor)InterceptorReplaceMethod(@selector(defaultSessionConfiguration),
                                                                                          (IMP)Interceptor_defaultSessionConfiguration,
                                                                                          [NSURLSessionConfiguration class],
                                                                                          YES);
    orig_ephemeralSessionConfiguration = (SessionConfigConstructor)InterceptorReplaceMethod(@selector(ephemeralSessionConfiguration),
                                                                                            (IMP)Interceptor_defaultSessionConfiguration,
                                                                                            [NSURLSessionConfiguration class],
                                                                                            YES);
}

@end





@interface AppDNSInterceptor ()<NSURLSessionDelegate>

@property (nonatomic, strong) NSURLConnection * connection;

@property (nonatomic, strong) NSURLSession *managerSession;

@property (nonatomic, strong) NSHTTPURLResponse *httpResponse;


@end

@implementation AppDNSInterceptor

+ (void)registerInterceptor {
    [NSURLProtocol registerClass:[NSClassFromString(@"AppDNSInterceptor") class]];
}

+ (void)unregisterInterceptor {
     [NSURLProtocol unregisterClass:[NSClassFromString(@"AppDNSInterceptor") class]];
}

#pragma mark - 拦截
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    NSLog(@"request.URL.absoluteString = %@",request.URL.absoluteString);
    //只处理http| https请求
    NSString *scheme = [[request URL] scheme];
    if ([scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
        [scheme caseInsensitiveCompare:@"https"] == NSOrderedSame) {
        
        //看看是否处理过,防止无限循环
        if([NSURLProtocol propertyForKey:kAppDNSInterceptorKey inRequest:request]){
            return NO;
        }
        return YES;
    }
    return NO;
}

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task {
    return [self canInitWithRequest:task.currentRequest];
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    //判断两个 request 是否相同，如果相同的话可以使用缓存数据，通常只需要调用父类的实现。
    return [super requestIsCacheEquivalent:a toRequest:b];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    //这里截取重定向 做定制化服务
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    //    //给我们处理过的请求设置一个标识符, 防止无限循环,
    [NSURLProtocol setProperty: @YES forKey: kAppDNSInterceptorKey inRequest: mutableRequest];
    NSString *originalUrl = mutableRequest.URL.absoluteString;
    NSURL *url = [NSURL URLWithString:originalUrl];

    NSString *ip = nil; //处理ip映射
    if (ip) {
        NSRange hostFirstRange = [originalUrl rangeOfString:url.host];
        if (NSNotFound != hostFirstRange.location) {
            NSString *newUrl = [originalUrl stringByReplacingCharactersInRange:hostFirstRange withString:ip];
            mutableRequest.URL = [NSURL URLWithString:newUrl];
            [mutableRequest setValue:url.host forHTTPHeaderField:@"host"];
            // 添加originalUrl保存原始URL
            [mutableRequest addValue:originalUrl forHTTPHeaderField:@"originalUrl"];
        }
    }

    return mutableRequest;
}


#pragma mark -转发
- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    
    AppDNSInterceptor *interceptor = [super initWithRequest:request cachedResponse:nil client:client];
    return interceptor;
}

- (void)startLoading {
    NSMutableURLRequest * request = self.request.mutableCopy;
  
   
    
  // self.connection = [[NSURLConnection alloc] initWithRequest:request  delegate:self startImmediately:YES];
    
    NSURLSessionDataTask * task = [self.managerSession dataTaskWithRequest:request];
    [task resume];
}



#pragma mark - 回调

#pragma mark - NSURLConnectionDelegate
- (void)connection: (NSURLConnection *)connection didReceiveResponse: (NSURLResponse *)response {
    if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
       
    
    }
    [self.client URLProtocol: self didReceiveResponse: response cacheStoragePolicy: NSURLCacheStorageAllowedInMemoryOnly];
}

- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)data {
    [self.client URLProtocol: self didLoadData: data];
}

- (void)connectionDidFinishLoading: (NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading: self];
}

- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error {
    [self.client URLProtocol: self didFailWithError: error];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    
    //处理重定向问题
    if (response != nil) {
        NSMutableURLRequest *redirectableRequest = [request mutableCopy];
       
        
        [self.client URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
        completionHandler(request);
        
    } else {
        
        completionHandler(request);
    }
}
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    _httpResponse = (NSHTTPURLResponse *)response;
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    //处理缓存
    // 允许处理服务器的响应，才会继续接收服务器返回的数据

    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    //下载过程中

    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    //    下载完成之后的处理

    [self.client URLProtocolDidFinishLoading:self];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    completionHandler(proposedResponse);
}
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    
    [self.client URLProtocol:self didFailWithError:error];
}



#pragma mark - 结束
- (void)stopLoading {
    [self.managerSession invalidateAndCancel];
    self.managerSession = nil;
    
    
//    if (self.connection) {
//        [self.connection cancel];
//        [NSURLProtocol removePropertyForKey: kAppDNSInterceptorKey inRequest: self.connection.currentRequest.mutableCopy];
//        self.connection = nil;
//    }
    
}


#pragma mark - Private
- (NSURLSession *)managerSession {
    if (!_managerSession) {
      //  _session = [NSURLSession sharedSession];
        _managerSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
       
    }
    return _managerSession;
}

@end
