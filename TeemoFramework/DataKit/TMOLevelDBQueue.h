//
//  TMOLevelDBQueue.h
//  TeemoV2
//
//  Created by 崔 明辉 on 14-8-23.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMOLevelDBQueue : NSObject

+ (TMOLevelDBQueue *)databaseWithPath:(NSString *)argPath;
+ (TMOLevelDBQueue *)databaseWithIdentifier:(NSString *)argIdentifier
                                  directory:(NSSearchPathDirectory)argDirectory;
+ (TMOLevelDBQueue *)defaultDatabase;

- (void)setObject:(id)argObject forKey:(NSString *)argKey;
- (void)setObject:(id)argObject forKey:(NSString *)argKey expiredTime:(NSTimeInterval)argExpiredTime;
- (void)removeObjectForKey:(NSString *)argKey;
- (void)objectForKey:(NSString *)argKey withBlock:(void (^)(id object))argBlock;
- (id)objectForKey:(NSString *)argKey;

@end
