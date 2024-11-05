//
//  WKWebViewController.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/28.
//  Copyright © 2019 thinking. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>
#import "ThinkingSDKAPI.h"
#import <ThinkingSDK/ThinkingSDK.h>

@interface WKWebViewController ()<UIWebViewDelegate,WKUIDelegate,WKNavigationDelegate>

@property (strong) WKWebView *webView;

@end

@implementation WKWebViewController

- (void)setView
{
    [super setView];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.applicationNameForUserAgent = [NSString stringWithFormat:@"%@ %@", config.applicationNameForUserAgent ?: @"", @"/td-sdk-ios"];
    
    WKPreferences *preference = [[WKPreferences alloc]init];
    preference.minimumFontSize = 40;
    config.preferences = preference;
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"index.html"];
    NSString *htmlstring = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlstring baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle] bundlePath]]];
    [self.view addSubview:_webView];
    
    [_webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id __nullable userAgent, NSError * __nullable error) {
        NSLog(@"[ThinkingSDK] UserAgent: %@", userAgent);
    }];
}
- (NSString*)rightTitle
{
    return @"WKWebview Test";
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([TDAnalytics showUpWebView:webView withRequest:navigationAction.request]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}
@end
