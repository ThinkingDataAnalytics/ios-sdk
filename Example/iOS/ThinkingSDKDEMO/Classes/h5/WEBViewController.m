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

UIKIT_EXTERN API_DEPRECATED("No longer supported; please adopt WKWebView.", ios(2.0, 12.0)) API_UNAVAILABLE(visionos) API_UNAVAILABLE(tvos, macos, macCatalyst) NS_SWIFT_UI_ACTOR
@interface WEBViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;

@end

UIKIT_EXTERN API_DEPRECATED("No longer supported; please adopt WKWebView.", ios(2.0, 12.0)) API_UNAVAILABLE(visionos) API_UNAVAILABLE(tvos, macos, macCatalyst) NS_SWIFT_UI_ACTOR
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
    if ([TDAnalytics showUpWebView:webView withRequest:request]) {
        return NO;
    }
    /*
        other code
    */
    
    return YES;
}

@end
