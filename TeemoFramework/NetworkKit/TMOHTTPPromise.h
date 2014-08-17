//
//  TMOHTTPPromise.h
//  TeemoV2
//
//  Created by 崔 明辉 on 14/8/17.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GTMHTTPFetcher, TMOHTTPResult;

typedef enum {
    /**
     *  当缓存未失效时，取缓存；当缓存失效时，首先返回缓存，执行回调，然后取网络数据，再返回网络数据，执行回调，更新缓存。回调块可能被执行一次或两次。
     */
    TMOHTTPPromiseTypeValidCache,
    /**
     *  总是首先返回缓存，执行回调，然后取网络数据，再返回网络数据，执行回调，更新缓存。回调块可能被执行一次或两次。
     */
    TMOHTTPPromiseTypeAlwaysRequest,
    /**
     *  当缓存存在时，总是返回缓存；当缓存不存在时，访问网络，再执行回调。回调块总是被执行一次。
     */
    TMOHTTPPromiseTypeAlwaysCache,
}TMOHTTPPromiseType;

@interface TMOHTTPPromise : NSObject

/**
 *  为一个保证级的请求设置一个保证缓存数据
 *
 *  @param argURLString URL
 */
+ (void)prepareForURLString:(NSString *)argURLString withData:(NSData *)argData;

/**
 *  创建一个保证级的请求
 *
 *  @param argFetcherBlock 需要返回一个请求实例
 *  @param argPromiseBlock 保证级的请求回调，该回调可能被执行多次！
 */
+ (void)promiseFetch:(GTMHTTPFetcher *(^)())argFetcherBlock
        promiseBlock:(void (^)(TMOHTTPResult *result, NSError *error))argPromiseBlock
           cacheTime:(NSTimeInterval)argCacheTime;

/**
 *  创建一个自定义类型的保证级请求
 *
 *  @param argFetcherBlock 需要返回一个请求实例
 *  @param argPromiseBlock 保证级的请求回调，该回调可能被执行多次！
 *  @param argPromiseType  类型
 */
+ (void)promiseFetch:(GTMHTTPFetcher *(^)())argFetcherBlock
        promiseBlock:(void (^)(TMOHTTPResult *result, NSError *error))argPromiseBlock
         promiseType:(TMOHTTPPromiseType)argPromiseType
           cacheTime:(NSTimeInterval)argCacheTime;

@end
