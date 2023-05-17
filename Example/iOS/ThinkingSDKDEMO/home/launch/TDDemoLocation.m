//
//  TDDemoLocation.m
//  ThinkingSDKDEMO
//
//  Created by wwango on 2021/9/30.
//  Copyright © 2021 thinking. All rights reserved.
//

#import "TDDemoLocation.h"
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>

@interface TDDemoLocation () <CLLocationManagerDelegate>

@property (nonatomic ,strong) CLLocationManager *locationMgr;


@end

@implementation TDDemoLocation


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addLocation];
    }
    return self;
}

- (void)addLocation {
    _locationMgr = [[CLLocationManager alloc] init];
    _locationMgr.delegate = self;
    _locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    _locationMgr.distanceFilter = 10;
    // 主动请求定位授权
    [_locationMgr requestAlwaysAuthorization];
    // 这是iOS9中针对后台定位推出的新属性 不设置的话 可是会出现顶部蓝条的哦(类似热点连接)
    if (@available(iOS 9.0, *)) {
        [_locationMgr setAllowsBackgroundLocationUpdates:YES];
    }
    _locationMgr.pausesLocationUpdatesAutomatically = NO;
    [_locationMgr startMonitoringSignificantLocationChanges];
    [self starMonitorRegion];
}


#pragma mark - location



// 监听的位置
- (NSArray *)locationArr {
    /*
     需求根据对应地图设置坐标
     iOS，原生坐标系为 WGS-84
     高德以及国内坐标系：GCS-02
     百度的偏移坐标系：BD-09
     */
    // 环球港，121.418251,31.238279
    // 天安门 116.397451, 39.909187
    return  @[ @{@"latitude":@"31.238279", @"longitude":@"121.418251"}];
}

// 开始监听
- (void)starMonitorRegion {
    for (CLRegion *monitoredRegion in self.locationMgr.monitoredRegions) {
        NSLog(@"移除: %@", monitoredRegion.identifier);
        [self.locationMgr stopMonitoringForRegion:monitoredRegion];
    }
    
    for (NSDictionary *dict in self.locationArr) {
        CLLocationDegrees latitude = [dict[@"latitude"] doubleValue];
        CLLocationDegrees longitude = [dict[@"longitude"] doubleValue];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
        [self regionObserveWithLocation:location];
    }
}

// 设置监听的位置
- (void)regionObserveWithLocation:(CLLocationCoordinate2D)location {
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"您的设备不支持定位");
        return;
    }
    
    // 设置区域半径
    CLLocationDistance radius = 200;
    // 使用前必须判定当前的监听区域半径是否大于最大可被监听的区域半径
    if(radius > self.locationMgr.maximumRegionMonitoringDistance) {
        radius = self.locationMgr.maximumRegionMonitoringDistance;
    }
    // 设置id
    NSString *identifier =
    [NSString stringWithFormat:@"%f , %f", location.latitude, location.longitude];
    // 使用CLCircularRegion创建一个圆形区域，
    CLRegion *fkit = [[CLCircularRegion alloc] initWithCenter:location
                                                       radius:radius
                                                   identifier:identifier];
    // 开始监听fkit区域
    [self.locationMgr startMonitoringForRegion:fkit];
}

// 进入指定区域以后将弹出提示框提示用户
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    NSString *msg = [NSString stringWithFormat:@"进入指定区域 %@", region.identifier];
    [self dealAlertWithStr:msg];
}

// 离开指定区域以后将弹出提示框提示用户
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    NSString *msg = [NSString stringWithFormat:@"离开指定区域 %@", region.identifier];
    [self dealAlertWithStr:msg];
}

-  (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self registerNotificationWithMsg:@"didUpdateLocations"];
}

- (void)dealAlertWithStr:(NSString *)msg {
    // 程序在后台
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self registerNotificationWithMsg:msg];
    } else { // 程序在前台
        [self alertWithMsg:msg];
    }
}

// 本地通知
- (void)registerNotificationWithMsg:(NSString *)msg {
    
    if (@available(iOS 10.0, *)) {
        // 使用 UNUserNotificationCenter 来管理通知
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        // 需创建一个包含待通知内容的 UNMutableNotificationContent 对象
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"通知"
                                                              arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:msg
                                                             arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        NSInteger alerTime = 1;
        // 在 alertTime 后推送本地推送
        UNTimeIntervalNotificationTrigger *trigger =
        [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:alerTime
                                                           repeats:NO];
        UNNotificationRequest* request =
        [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                             content:content
                                             trigger:trigger];
        
        //添加推送成功后的处理！
        [center addNotificationRequest:request withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"添加推送失败 error : %@", error);
            } else {
                NSLog(@"添加推送成功");
            }
        }];
    }
}

- (void)alertWithMsg:(NSString *)msg {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"通知"
                                        message:msg
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:action];
    UIViewController *vc =
    [UIApplication sharedApplication].keyWindow.rootViewController;
    [vc presentViewController:alert animated:YES completion:nil];
}

@end
