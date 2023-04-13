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

    [_locationMgr requestAlwaysAuthorization];
    
    if (@available(iOS 9.0, *)) {
        [_locationMgr setAllowsBackgroundLocationUpdates:YES];
    }
    _locationMgr.pausesLocationUpdatesAutomatically = NO;
    [_locationMgr startMonitoringSignificantLocationChanges];
    [self starMonitorRegion];
}


#pragma mark - location



- (NSArray *)locationArr {


    return  @[ @{@"latitude":@"31.238279", @"longitude":@"121.418251"}];
}


- (void)starMonitorRegion {
    for (CLRegion *monitoredRegion in self.locationMgr.monitoredRegions) {
        NSLog(@"remove %@", monitoredRegion.identifier);
        [self.locationMgr stopMonitoringForRegion:monitoredRegion];
    }
    
    for (NSDictionary *dict in self.locationArr) {
        CLLocationDegrees latitude = [dict[@"latitude"] doubleValue];
        CLLocationDegrees longitude = [dict[@"longitude"] doubleValue];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
        [self regionObserveWithLocation:location];
    }
}


- (void)regionObserveWithLocation:(CLLocationCoordinate2D)location {
    if (![CLLocationManager locationServicesEnabled]) {
        
        return;
    }
    
    
    CLLocationDistance radius = 200;
    
    if(radius > self.locationMgr.maximumRegionMonitoringDistance) {
        radius = self.locationMgr.maximumRegionMonitoringDistance;
    }
    
    NSString *identifier =
    [NSString stringWithFormat:@"%f , %f", location.latitude, location.longitude];
    
    CLRegion *fkit = [[CLCircularRegion alloc] initWithCenter:location
                                                       radius:radius
                                                   identifier:identifier];
    
    [self.locationMgr startMonitoringForRegion:fkit];
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    NSString *msg = [NSString stringWithFormat:@"inter area%@", region.identifier];
    [self dealAlertWithStr:msg];
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"%@_%@",@"DEMO_",NSStringFromSelector(_cmd));
    NSString *msg = [NSString stringWithFormat:@"out area %@", region.identifier];
    [self dealAlertWithStr:msg];
}

-  (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self registerNotificationWithMsg:@"didUpdateLocations"];
}

- (void)dealAlertWithStr:(NSString *)msg {
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self registerNotificationWithMsg:msg];
    } else {
        [self alertWithMsg:msg];
    }
}


- (void)registerNotificationWithMsg:(NSString *)msg {
    
    if (@available(iOS 10.0, *)) {
        
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        
        UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"Notification"
                                                              arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:msg
                                                             arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        NSInteger alerTime = 1;
        
        UNTimeIntervalNotificationTrigger *trigger =
        [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:alerTime
                                                           repeats:NO];
        UNNotificationRequest* request =
        [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                             content:content
                                             trigger:trigger];
        
        
        [center addNotificationRequest:request withCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"add push error : %@", error);
            } else {
                NSLog(@"add push success");
            }
        }];
    }
}

- (void)alertWithMsg:(NSString *)msg {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"Notification"
                                        message:msg
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"yes"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:action];
    UIViewController *vc =
    [UIApplication sharedApplication].keyWindow.rootViewController;
    [vc presentViewController:alert animated:YES completion:nil];
}

@end
