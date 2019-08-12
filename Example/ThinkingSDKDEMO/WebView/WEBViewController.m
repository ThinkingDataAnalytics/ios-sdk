//
//  WEBViewController.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/27.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import "WEBViewController.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

@interface WEBViewController () <UIWebViewDelegate>

@property (strong) UIWebView *webView;

@end

@implementation WEBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"index.html"];
    NSString *htmlstring=[[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlstring baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle] bundlePath]]];
    _webView.delegate = self;
    [self.view addSubview:_webView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[ThinkingAnalyticsSDK sharedInstance] showUpWebView:webView WithRequest:request]) {
        return NO;
    }
    
    /*
        other code
    */
    
    return YES;
}

@end
