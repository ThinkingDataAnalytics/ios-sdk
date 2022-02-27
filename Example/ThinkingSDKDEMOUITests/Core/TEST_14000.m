


//
//  TEST_14000.m
//  ThinkingSDKDEMOUITests
//
//  Created by wwango on 2021/12/14.
//  Copyright © 2021 thinking. All rights reserved.
//

#import "TEST_14000.h"
#import "NSDictionary+TEST.h"
#import "HMCThreadSafeMutableArray.h"

/**
 压力测试-在多个线程同时track一万条数据
 
 验证内容：
 1. 验证在高并发的情况下数据的准确性和完整性
 2. 高并发情况下是否有crash的情况发生
 
 
 验证方式：
 创建两个实例，每个实例分别使用两个线程发送track数据，在四条线程中分别持续发送一万条数据。
 待四个线程数据都发送完成后，验证两个实例发送的数据是否都在数据库中。
 */


// 每一并发执行的数量
#define TEST_MaxNumEvents 10

@interface TEST_14000 ()

@property(nonatomic, strong)dispatch_group_t group;

@property(nonatomic, strong)dispatch_queue_t queue1;
@property(nonatomic, strong)dispatch_queue_t queue2;
@property(nonatomic, strong)dispatch_queue_t queue3;
@property(nonatomic, strong)dispatch_queue_t queue4;

@property(nonatomic, strong)ThinkingAnalyticsSDK *ins1;
@property(nonatomic, strong)ThinkingAnalyticsSDK *ins2;

@property(nonatomic, strong)TEST_Input_Model *input1;
@property(nonatomic, strong)TEST_Input_Model *input2;

@property(nonatomic, strong)HMCThreadSafeMutableArray *dataSource1;
@property(nonatomic, strong)HMCThreadSafeMutableArray *dataSource2;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation TEST_14000

- (void)setUp {
    self.models = [NSMutableArray arrayWithArray:[TEST_Model getTestDatas:@"TEST_11000"]];
    NSMutableDictionary *dic = [ThinkingAnalyticsSDK performSelector:@selector(_getAllInstances)];
    [dic removeAllObjects];
    dic = nil;
    [TEST_Helper deleteNSLibraryDirectory];
    
    
    self.dataSource1 = [[HMCThreadSafeMutableArray alloc] init];
    self.dataSource2 = [[HMCThreadSafeMutableArray alloc] init];

    _group = dispatch_group_create();
    _queue1 = dispatch_queue_create("queue1", DISPATCH_QUEUE_SERIAL);
    _queue2 = dispatch_queue_create("queue2", DISPATCH_QUEUE_SERIAL);
    _queue3 = dispatch_queue_create("queue3", DISPATCH_QUEUE_SERIAL);
    _queue4 = dispatch_queue_create("queue4", DISPATCH_QUEUE_SERIAL);
}

- (void)tearDown {
    self.dataSource1 = [[HMCThreadSafeMutableArray alloc] init];
    self.dataSource2 = [[HMCThreadSafeMutableArray alloc] init];
}

- (void)test_14000 {
    
    TDConfig.maxNumEvents = TEST_MaxNumEvents * 10;
    
    TEST_Model *model1 = self.models[0];
    TEST_Input_Model *input1 = model1.input;
    TDConfig *config1 = [[TDConfig alloc] initWithAppId:input1.appid serverUrl:input1.serverURL];
    ThinkingAnalyticsSDK *ins1 = [ThinkingAnalyticsSDK startWithConfig:config1];
    [ins1 identify:input1.distinctid];
    [ins1 login:input1.accountid];
    self.ins1 = ins1;
    self.input1 = input1;
    
    
    TEST_Model *model2 = self.models[1];
    TEST_Input_Model *input2 = model2.input;
    TDConfig *config2 = [[TDConfig alloc] initWithAppId:input2.appid serverUrl:input2.serverURL];
    ThinkingAnalyticsSDK *ins2 = [ThinkingAnalyticsSDK startWithConfig:config2];
    [ins2 identify:input2.distinctid];
    [ins2 login:input2.accountid];
    self.ins2 = ins2;
    self.input2 = input2;
    
    [[ins1 valueForKey:@"dataQueue"] aspect_hookSelector:@selector(removeDataWithuids:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
    
    } error:nil];
    
    [[ins2 valueForKey:@"dataQueue"] aspect_hookSelector:@selector(removeDataWithuids:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info, NSDictionary *dataDic){
    
    } error:nil];
    
    
    XCTestExpectation* expect1 = [[XCTestExpectation alloc] initWithDescription:@"time out !!"];

    dispatch_group_async(_group, _queue1, ^{
        NSLog(@"#####_queue1-currnet_thread: %@", [NSThread currentThread]);
        [self thread1_action];
    });

    
    dispatch_group_async(_group, _queue2, ^{
        NSLog(@"#####_queue2-currnet_thread: %@", [NSThread currentThread]);
        [self thread2_action];
    });
    
    dispatch_group_async(_group, _queue3, ^{
        NSLog(@"#####_queue3-currnet_thread: %@", [NSThread currentThread]);
        [self thread3_action];
    });
    
    dispatch_group_async(_group, _queue4, ^{
        NSLog(@"#####_queue4-currnet_thread: %@", [NSThread currentThread]);
        [self thread4_action];
    });
    

    dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
    
        [ins1 flush];
        [ins2 flush];
        
        [TEST_Helper dispatchQueue:^{
            // 从数据库取数据
            NSMutableDictionary *dic = [ThinkingAnalyticsSDK performSelector:@selector(_getAllInstances)];
            @synchronized (dic) {
                // 从数据库取数据
                NSDictionary *dic1 = [[ins1 valueForKey:@"dataQueue"] performSelector:@selector(getFirstRecords:withAppid:) withObject:@(TEST_MaxNumEvents*2) withObject:input1.appid];
                NSDictionary *dic2 = [[ins2 valueForKey:@"dataQueue"] performSelector:@selector(getFirstRecords:withAppid:) withObject:@(TEST_MaxNumEvents*2) withObject:input2.appid];
                NSArray *contents1 = dic1[@"recoders"];
                NSArray *contents2 = dic2[@"recoders"];
                
                // 数量是否准确
                NSLog(@"dataSource1 %lu, contents1 %lu", self.dataSource1.toNSArray.count , contents1.count);
                NSLog(@"dataSource2 %lu, contents2 %lu", self.dataSource2.toNSArray.count , contents2.count);
                XCTAssertTrue(self.dataSource1.toNSArray.count == contents1.count);
                XCTAssertTrue(self.dataSource2.toNSArray.count == contents2.count);
                
                // 处理数据
                [contents1 makeObjectsPerformSelector:@selector(handleDatas)];
                [contents2 makeObjectsPerformSelector:@selector(handleDatas)];
                
                NSMutableSet *dataSourceSet1 = [NSMutableSet setWithArray:self.dataSource1.toNSArray];
                NSMutableSet *dataSourceSet2 = [NSMutableSet setWithArray:self.dataSource2.toNSArray];
                
                NSMutableSet *contentsSet1 = [NSMutableSet setWithArray:contents1];
                NSMutableSet *contentsSet2 = [NSMutableSet setWithArray:contents2];
                
                // 数据是否一样
                XCTAssertTrue([dataSourceSet1 isEqual:contentsSet1]);
                XCTAssertTrue([dataSourceSet2 isEqual:contentsSet2]);
                
                [expect1 fulfill];
            }

        }];
    });
    
    NSLog(@"home %@", NSHomeDirectory());
    
    [self waitForExpectations:@[expect1] timeout:100000000000000];
    
}

// ins1 线程1 发track
- (void)thread1_action {
    for (int i = 1; i<=TEST_MaxNumEvents; i++) {
        NSString *eventName = [NSString stringWithFormat:@"event_name_ins1_thread1_%i", i];
        NSString *key = [NSString stringWithFormat:@"key_ins1_thread1_%i", i];
        NSString *value = [NSString stringWithFormat:@"value_ins1_thread1_%i", i];
        NSDictionary *property = @{key: value};
        [self.dataSource1 addObject:@{@"#event_name":eventName,
                                      @"properties":property,
                                      @"#account_id":_input1.accountid,
                                      @"#distinct_id":_input1.distinctid}];
        [self.ins1 track:eventName properties:property];
        NSLog(@"@@@@@@@@@@@thread1_action_%d", i);

    }
}

// ins1 线程2 发track
- (void)thread2_action {
    for (int i = 1; i<=TEST_MaxNumEvents; i++) {
        NSString *eventName = [NSString stringWithFormat:@"event_name_ins1_thread2_%i", i];
        NSString *key = [NSString stringWithFormat:@"key_ins1_thread2_%i", i];
        NSString *value = [NSString stringWithFormat:@"value_ins1_thread2_%i", i];
        NSDictionary *property = @{key: value};
        [self.dataSource1 addObject:@{@"#event_name":eventName,
                                      @"properties":property,
                                      @"#account_id":_input1.accountid,
                                      @"#distinct_id":_input1.distinctid}];
        [self.ins1 track:eventName properties:property];
        NSLog(@"@@@@@@@@@@@thread2_action_%d", i);

    }
}

- (void)thread3_action {
    for (int i = 1; i<=TEST_MaxNumEvents; i++) {
        NSString *eventName = [NSString stringWithFormat:@"event_name_ins2_thread3_%i", i];
        NSString *key = [NSString stringWithFormat:@"key_ins2_thread3_%i", i];
        NSString *value = [NSString stringWithFormat:@"value_ins2_thread3_%i", i];
        NSDictionary *property = @{key: value};
        [self.dataSource2 addObject:@{@"#event_name":eventName,
                                      @"properties":property,
                                      @"#account_id":_input2.accountid,
                                      @"#distinct_id":_input2.distinctid}];
        [self.ins2 track:eventName properties:property];
        NSLog(@"@@@@@@@@@@@thread3_action_%d", i);

    }
}

- (void)thread4_action {
    for (int i = 1; i<=TEST_MaxNumEvents; i++) {
        NSString *eventName = [NSString stringWithFormat:@"event_name_ins2_thread3_%i", i];
        NSString *key = [NSString stringWithFormat:@"key_ins2_thread4_%i", i];
        NSString *value = [NSString stringWithFormat:@"value_ins2_thread4_%i", i];
        NSDictionary *property = @{key: value};
        [self.dataSource2 addObject:@{@"#event_name":eventName,
                                      @"properties":property,
                                      @"#account_id":_input2.accountid,
                                      @"#distinct_id":_input2.distinctid}];
        [self.ins2 track:eventName properties:property];
        NSLog(@"@@@@@@@@@@@thread4_action_%d", i);

    }
}

@end

#pragma clang diagnostic pop
