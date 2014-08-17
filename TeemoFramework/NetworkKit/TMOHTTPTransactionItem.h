//
//  TMOHTTPTransactionItem.h
//  TeemoV2
//
//  Created by 崔 明辉 on 14/8/16.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMOHTTPResult;

/**
 *  事务事件
 */
@interface TMOHTTPTransactionItem : NSObject

/**
 *  URL
 */
@property (nonatomic, strong) NSString *URLString;

/**
 *  该请求是否应该取缓存，
 *  不缓存 -1
 *  永久缓存 0
 *  缓存指定秒数 >0
 */
@property (nonatomic, assign) NSTimeInterval cacheTime;

/**
 *  发送的postData，若指定，则此请求为post请求
 */
@property (nonatomic, strong) NSData *postData;

/**
 *  发送的postInfo，若指定，则此请求为post请求
 */
@property (nonatomic, strong) NSDictionary *postInfo;

/**
 *  若为YES，请求失败后，则中断整个事务，并执行回调
 */
@property (nonatomic, assign) BOOL stopTransactionIfError;

/**
 *  系统方法，请勿执行
 *
 *  @param argBlock Block
 */
- (void)queryWithBlock:(void (^)(TMOHTTPResult *result, NSError *error))argBlock;

@end
