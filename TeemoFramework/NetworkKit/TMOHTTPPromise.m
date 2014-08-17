//
//  TMOHTTPPromise.m
//  TeemoV2
//
//  Created by 崔 明辉 on 14/8/17.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOHTTPPromise.h"
#import "TMOKVDB.h"
#import "TMOHTTPResult.h"
#import <GTMHTTPFetcher.h>

static LevelDB *promiseLevelDB;

@implementation TMOHTTPPromise

+ (void)initialize {
    if (self == [TMOHTTPPromise self]) {
        promiseLevelDB = [TMOKVDB customDatabase:@"networkPromiseCache"];
    }
}

+ (void)prepareForURLString:(NSString *)argURLString withData:(NSData *)argData {
    [promiseLevelDB setObject:argData forKey:argURLString];
}

+ (void)promiseFetch:(GTMHTTPFetcher *(^)())argFetcherBlock
        promiseBlock:(void (^)(TMOHTTPResult *, NSError *))argPromiseBlock
           cacheTime:(NSTimeInterval)argCacheTime {
    [self promiseFetch:argFetcherBlock
          promiseBlock:argPromiseBlock
           promiseType:TMOHTTPPromiseTypeValidCache
             cacheTime:argCacheTime];
}

+ (void)promiseFetch:(GTMHTTPFetcher *(^)())argFetcherBlock
        promiseBlock:(void (^)(TMOHTTPResult *, NSError *))argPromiseBlock
         promiseType:(TMOHTTPPromiseType)argPromiseType
           cacheTime:(NSTimeInterval)argCacheTime {
    GTMHTTPFetcher *fetcher = argFetcherBlock();
    [fetcher stopFetching];
    NSString *URLString = [[[fetcher mutableRequest] URL] absoluteString];
    NSData *aliveCache = [promiseLevelDB valueForKey:URLString];
    if (argPromiseType == TMOHTTPPromiseTypeAlwaysCache) {
        if (aliveCache == nil) {
            [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
                if (error == nil) {
                    TMOHTTPResult *result = [TMOHTTPResult createHTTPResultWithRequest:fetcher.mutableRequest WithResponse:nil WithData:data];
                    argPromiseBlock(result, error);
                    [promiseLevelDB setObject:data forKey:URLString];
                }
                else {
                    argPromiseBlock(nil, error);
                }
            }];
        }
        else {
            TMOHTTPResult *result = [TMOHTTPResult createHTTPResultWithRequest:fetcher.mutableRequest WithResponse:nil WithData:aliveCache];
            argPromiseBlock(result, nil);
        }
    }
    else if (argPromiseType == TMOHTTPPromiseTypeAlwaysRequest) {
        if (aliveCache != nil) {
            TMOHTTPResult *result = [TMOHTTPResult createHTTPResultWithRequest:fetcher.mutableRequest WithResponse:nil WithData:aliveCache];
            argPromiseBlock(result, nil);
        }
        [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
            if (error == nil) {
                TMOHTTPResult *result = [TMOHTTPResult createHTTPResultWithRequest:fetcher.mutableRequest WithResponse:nil WithData:data];
                argPromiseBlock(result, error);
                [promiseLevelDB setObject:data forKey:URLString];
            }
        }];
    }
    else if (argPromiseType == TMOHTTPPromiseTypeValidCache) {
        if (aliveCache != nil) {
            TMOHTTPResult *result = [TMOHTTPResult createHTTPResultWithRequest:fetcher.mutableRequest WithResponse:nil WithData:aliveCache];
            argPromiseBlock(result, nil);
        }
        NSData *limitCache = [promiseLevelDB objectWithCacheForKey:URLString];
        if (limitCache == nil) {
            [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
                if (error == nil) {
                    TMOHTTPResult *result = [TMOHTTPResult createHTTPResultWithRequest:fetcher.mutableRequest WithResponse:nil WithData:data];
                    argPromiseBlock(result, error);
                    [promiseLevelDB setObject:data forKey:URLString];
                    [promiseLevelDB setObject:data forKey:URLString cacheTime:argCacheTime];
                }
                else if(error != nil && aliveCache == nil) {
                    argPromiseBlock(nil, error);
                }
            }];
        }
    }
}


@end
