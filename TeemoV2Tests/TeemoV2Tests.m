//
//  TeemoV2Tests.m
//  TeemoV2Tests
//
//  Created by 张培创 on 14-3-31.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TMOBaseModel.h"
#import "NSArray+TMODuplicate.h"

@interface TeemoV2Tests : XCTestCase

@end

@implementation TeemoV2Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
//    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
//    [self testDuplicate];
    
//    [self testDuplicateWithKey];
}

- (void)testDuplicate {
    NSMutableArray *moments = [NSMutableArray array];
    NSMutableArray *unMoments = [NSMutableArray array];
    for (int i = 0; i < 1000; i ++) {
        NSString *content = [NSString stringWithFormat:@"Jack%d", i];
        TMOBaseModel *moment = [[TMOBaseModel alloc] init];
        moment.content = content;
        moment.index = i;
        [moments addObject:moment];
        
        [unMoments addObject:moment];
    }
    TMOBaseModel *moment1 = [[TMOBaseModel alloc] init];
    moment1.content = @"Jack1000000";
    moment1.index = 2;
    
    TMOBaseModel *moment2 = [[TMOBaseModel alloc] init];
    moment2.content = @"Jack500";
    moment2.index = 7;
    
    [unMoments addObject:moment1];
    [unMoments addObject:moment2];
    
    NSLog(@"Model开始");
    NSLog(@"Model不重复的 : %@", [unMoments unionWithoutDuplicatesWithArray:moments]);
    NSLog(@"Model结束");
}

- (void)testDuplicateWithKey {
    NSMutableArray *oneArray = [[NSMutableArray alloc] init];
    NSMutableArray *twoArray = [[NSMutableArray alloc] init];
    
    NSString *someKey = @"someKey";
    
    for (int i = 0; i < 1000; i ++) {
        NSMutableDictionary *currentDictionary = [[NSMutableDictionary alloc] init];
        [currentDictionary setValue:[NSString stringWithFormat:@"Jack%d", i] forKey:someKey];
        [currentDictionary setValue:[NSNumber numberWithInt:i] forKey:@"number"];
        [oneArray addObject:currentDictionary];
        [twoArray addObject:currentDictionary];
    }
    
    [oneArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Jack1000", someKey, nil]];
    
    NSLog(@"字典开始");
    NSLog(@"字典不重复的 : %@", [oneArray unionWithoutDuplicatesWithArray:twoArray forKey:someKey]);
    NSLog(@"字典结束");
}

@end
