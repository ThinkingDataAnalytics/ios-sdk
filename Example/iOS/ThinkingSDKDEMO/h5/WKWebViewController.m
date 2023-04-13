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
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

@interface WKWebViewController ()<UIWebViewDelegate,WKUIDelegate,WKNavigationDelegate>

@property (strong) WKWebView *webView;

@end

@implementation WKWebViewController
- (void)setView
{
    [super setView];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKPreferences *preference = [[WKPreferences alloc]init];
    preference.minimumFontSize = 40;
    config.preferences = preference;
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    _webView.customUserAgent = @" /td-sdk-ios";
    
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"index.html"];
    NSString *htmlstring = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlstring baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle] bundlePath]]];
    [self.view addSubview:_webView];
}
- (NSString*)rightTitle
{
    return @"WKWebview Test";
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  
    if ([[ThinkingSDKAPI getInstance] showUpWebView:webView WithRequest:navigationAction.request]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}
@end
