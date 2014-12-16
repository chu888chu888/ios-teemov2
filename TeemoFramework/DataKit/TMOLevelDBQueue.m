//
//  TMOLevelDBQueue.m
//  TeemoV2
//
//  Created by 崔 明辉 on 14-8-23.
//  Copyright (c) 2014年 com.duowan.zpc. All rights reserved.
//

#import "TMOLevelDBQueue.h"
#import <LevelDB.h>

static NSMutableDictionary *pool;

@interface TMOLevelDBQueue () {
    dispatch_queue_t _queue;
}

@property (nonatomic, strong) LevelDB *connection;

@end

@implementation TMOLevelDBQueue

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pool = [NSMutableDictionary dictionary];
    });
}

+ (TMOLevelDBQueue *)databaseWithPath:(NSString *)argPath {
    if ([pool[argPath] isKindOfClass:[TMOLevelDBQueue class]] &&
        ![[pool[argPath] connection] closed]) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:argPath]) {
            [[pool[argPath] connection] close];//Handle cache clean by system.
        }
        else {
            return pool[argPath];
        }
    }
    LevelDB *connection = [[LevelDB alloc] initWithPath:argPath andName:@"kvdb"];
    TMOLevelDBQueue *poolItem = [[TMOLevelDBQueue alloc] initWithConnection:connection];
    [pool setObject:poolItem forKey:argPath];
    return poolItem;
}

+ (TMOLevelDBQueue *)databaseWithIdentifier:(NSString *)argIdentifier directory:(NSSearchPathDirectory)argDirectory {
    NSString *basePath = [[NSSearchPathForDirectoriesInDomains(argDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/com.duowan.kvdb/"];
    NSString *dbPath = [basePath stringByAppendingString:[NSString stringWithFormat:@"%@/", argIdentifier]];
    return [self databaseWithPath:dbPath];
}

+ (TMOLevelDBQueue *)defaultDatabase {
    return [self databaseWithIdentifier:@"default" directory:NSCachesDirectory];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (instancetype)init {
    NSAssert(NO, @"Should !not! use init method by yourself!");
    return nil;
}

- (instancetype)initWithConnection:(LevelDB *)argConnection {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"kvdb.%@", self] UTF8String], NULL);
        self.connection = argConnection;
        [self setupCoder];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleApplicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (void)handleApplicationDidEnterBackground:(NSNotification *)sender {
    [self threadRemoveExpiredData];
}

- (void)setupCoder {
    self.connection.encoder = ^ NSData* (LevelDBKey *key, id object) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
        return data;
    };
    self.connection.decoder = ^ id (LevelDBKey *key, NSData * data) {
        id obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return obj;
    };
}

- (void)setObject:(id)argObject forKey:(NSString *)argKey {
    [NSThread detachNewThreadSelector:@selector(threadSetObject:) toTarget:self withObject:@[argObject, argKey]];
}

- (void)setObject:(id)argObject forKey:(NSString *)argKey expiredTime:(NSTimeInterval)argExpiredTime {
    
    NSNumber *expiredTimeNumber;
    if (argExpiredTime < 0) {
        [self removeObjectForKey:argKey];
        return;
    }
    else if (argExpiredTime == 0) {
        expiredTimeNumber = [NSNumber numberWithInteger:NSIntegerMax];
    }
    else {
        expiredTimeNumber = [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]+argExpiredTime];
    }
    NSDictionary *dataDictionary = @{@"_Type": @"expired", @"object": argObject, @"expiredTime": expiredTimeNumber};
    [self setObject:dataDictionary forKey:argKey];
}

- (void)removeObjectForKey:(NSString *)argKey {
    [self threadRemoveObject:argKey];
}

- (void)objectForKey:(NSString *)argKey withBlock:(void (^)(id object))argBlock {
    NSAssert(argBlock != nil, @"You should use block instard of return value");
    if (argBlock == nil) {
        return;
    }
    dispatch_async(_queue, ^{
        id object = [self objectForKey:argKey];
        dispatch_async(dispatch_get_main_queue(), ^{
            argBlock(object);
        });
    });
}

- (id)objectForKey:(NSString *)argKey {
    return [self overrideObjectForKey:argKey];
}

- (id)valueForKey:(NSString *)key {
    return [self objectForKey:key];
}

- (id)overrideObjectForKey:(NSString *)argKey {
    id object = [self.connection objectForKey:argKey];
    if ([object isKindOfClass:[NSDictionary class]]) {
        if ([object[@"_Type"] isEqualToString:@"expired"]) {
            if ([object[@"expiredTime"] integerValue] < [[NSDate date] timeIntervalSince1970]) {
                return nil;
            }
            else {
                return object[@"object"];
            }
        }
        else {
            return object;
        }
    }
    else {
        return object;
    }
}

- (void)threadRemoveExpiredData {
    [self.connection enumerateKeysUsingBlock:^(LevelDBKey *key, BOOL *stop) {
        NSString *stringKey = NSStringFromLevelDBKey(key);
        if ([self objectForKey:stringKey] == nil) {
            [self removeObjectForKey:stringKey];
        }
    }];
}

- (void)threadSetObject:(NSArray *)argObjects {
    dispatch_sync(_queue, ^{
        [self.connection setObject:argObjects[0] forKey:argObjects[1]];
    });
}

- (void)threadRemoveObject:(NSString *)argKey {
    dispatch_sync(_queue, ^{
        [self.connection removeObjectForKey:argKey];
    });
}

- (CGFloat)cacheSize {
    long long totalSize = 0;
    NSString *realPath = self.connection.path;
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:realPath];
    for (NSString *itemPath in enumerator) {
        NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:[realPath stringByAppendingString:itemPath] error:nil];
        totalSize += [fileAttr[NSFileSize] integerValue];
    }
    return totalSize;
}

- (void)removeAllObjects {
    dispatch_sync(_queue, ^{
        [self.connection removeAllObjects];
    });
}

- (void)releaseAllSpace {
    dispatch_sync(_queue, ^{
        NSString *thePath = [self.connection.path copy];
        [self.connection deleteDatabaseFromDisk];
        self.connection = [[LevelDB alloc] initWithPath:thePath andName:@"kvdb"];
        [self setupCoder];
    });
}

@end
