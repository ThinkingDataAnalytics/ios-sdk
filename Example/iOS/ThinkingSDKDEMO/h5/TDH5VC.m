//
//  H5VC.m
//  ThinkingSDKDEMO
//
//  Created by LiHuanan on 2020/9/21.
//  Copyright © 2020 thinking. All rights reserved.
//

#import "TDH5VC.h"
#import "ActionModel.h"
#import "WEBViewController.h"
#import "WKWebViewController.h"
@interface TDH5VC ()

@end

@implementation TDH5VC

- (NSString*)rightTitle
{
    return @"H5页面测试";
}
- (void)setData
{
    self.commands = [NSMutableArray array];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"H5 打通 UIWebView" action:^{
        WEBViewController *webVC = [[WEBViewController alloc] init];
        [TDUtil.jsd_findVisibleViewController.navigationController pushViewController:webVC animated:YES];
    }]];
    [self.commands addObject:[[ActionModel alloc]initWithName:@"H5 打通 WKWebView" action:^{
        WKWebViewController *webVC = [[WKWebViewController alloc] init];
        [TDUtil.jsd_findVisibleViewController.navigationController pushViewController:webVC animated:YES];
    }]];
}
@end
