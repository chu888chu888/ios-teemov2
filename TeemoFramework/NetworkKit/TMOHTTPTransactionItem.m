//
//  TMOHTTPTransactionItem.m
//  TeemoV2
//
//  Created by 崔 明辉 on 14/8/16.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOHTTPTransactionItem.h"
#import "TMOHTTPResult.h"
#import "TMOHTTPManager.h"


@implementation TMOHTTPTransactionItem

- (void)queryWithBlock:(void (^)(TMOHTTPResult *result, NSError *error))argBlock {
    if (self.postData != nil || self.postInfo != nil) {
        //post
        if (self.postData != nil) {
            [TMOHTTPManager simplePost:self.URLString
                              postData:self.postData
                       completionBlock:^(TMOHTTPResult *result, NSError *error) {
                           argBlock(result, error);
            }];
        }
        else {
            [TMOHTTPManager simplePost:self.URLString
                              postInfo:self.postInfo
                       completionBlock:^(TMOHTTPResult *result, NSError *error) {
                           argBlock(result, error);
            }];
        }
    }
    else {
        //get
        [[TMOHTTPManager shareInstance] fetchWithURL:self.URLString postInfo:nil timeoutInterval:10 headers:nil owner:nil cacheTime:self.cacheTime fetcherPriority:TMOFetcherPriorityNormal comletionHandle:nil completionBlock:^(TMOHTTPResult *result, NSError *error) {
            argBlock(result, error);
        }];
    }
}

@end
