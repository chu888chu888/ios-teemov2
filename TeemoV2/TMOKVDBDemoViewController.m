//
//  TMOKVDBDemoViewController.m
//  TeemoV2
//
//  Created by 崔明辉 on 14-4-15.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOKVDBDemoViewController.h"
#import "TMOLevelDBQueue.h"

@interface TMOKVDBDemoViewController ()

@end

@implementation TMOKVDBDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"TMONetworkDemoViewController" bundle:nibBundleOrNil];
    if (self) {
        self.title = @"KVDB";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TMOLevelDBQueue *db = [TMOLevelDBQueue defaultDatabase];//使用系统默认的KVDB库
    [db setObject:@"SetSomething" forKey:@"theKey"];//你可以直接存入任何对象
    NSLog(@"%@",[db valueForKey:@"theKey"]);
    
    TMOLevelDBQueue *customDb = [TMOLevelDBQueue databaseWithIdentifier:@"myCustom" directory:NSCachesDirectory];//使用一个新库存储对象
    [customDb setObject:@"otherThings" forKey:@"theKey"];
    [customDb objectForKey:@"theKey" withBlock:^(id object) {
        NSLog(@"%@",object);//异步方式获取
    }];
    
    NSLog(@"cachesize:%f",customDb.cacheSize);
    [customDb releaseAllSpace];
    
    TMOLevelDBQueue *customPath = [TMOLevelDBQueue databaseWithPath:[NSString stringWithFormat:@"%@tmpKVDB/",NSTemporaryDirectory()]];//把KV库保存至指定路径
    [customPath setObject:@"123123" forKey:@"ccc"];
    NSLog(@"%@",[customPath valueForKey:@"ccc"]);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
