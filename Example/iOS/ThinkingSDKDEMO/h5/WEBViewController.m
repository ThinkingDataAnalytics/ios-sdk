//
//  WEBViewController.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/27.
//  Copyright © 2019 thinking. All rights reserved.
//

#import "WEBViewController.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#import "ThinkingSDKAPI.h"
@interface WEBViewController () <UIWebViewDelegate>

@property (strong) UIWebView *webView;

@end

@implementation WEBViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webView.delegate = self;

    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"index.html"];
    NSString *htmlstring=[[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlstring baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle] bundlePath]]];
    [self.view addSubview:_webView];
}

- (NSString*)rightTitle
{
    return @"UIWebview Test";
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[ThinkingAnalyticsSDK sharedInstance] showUpWebView:webView WithRequest:request]
        || [[ThinkingAnalyticsSDK sharedInstanceWithAppid:@"aaaa"] showUpWebView:webView WithRequest:request]) {
        return NO;
    }
    /*
        other code
    */
    
    return YES;
}

@end
