//
//  WKWebViewController.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/28.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>

@interface WKWebViewController ()<UIWebViewDelegate,WKUIDelegate,WKNavigationDelegate>

@property (strong) WKWebView *webView;

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
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
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([[ThinkingAnalyticsSDK sharedInstance] showUpWebView:webView WithRequest:navigationAction.request]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
