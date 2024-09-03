//
//  TAInitinalViewController.m
//  ThinkingSDKMac
//
//  Created by yangxiong on 2022/7/5.
//

#import "TAInitinalViewController.h"
#import <ThinkingSDK/ThinkingSDK.h>

@interface TAInitinalViewController ()
@property (nonatomic, weak) IBOutlet NSTextField *appidTextField;
@property (nonatomic, weak) IBOutlet NSTextField *serverUrlTextField;

@end

@implementation TAInitinalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *appid = @"appid";
    NSString *url = @"http://thinkingdata.cn";

    self.appidTextField.stringValue = appid;
    self.serverUrlTextField.stringValue = url;
}

- (IBAction)cancelAction:(NSButton *)button {
    [self dismissViewController:self];
}

- (IBAction)initAction:(id)sender {
    [self dismissViewController:self];
    [self initThinkingAnalytics];
}

- (void)initThinkingAnalytics {
    [TDAnalytics enableLog:YES];
    TDConfig *config = [TDConfig new];
    config.appid = self.appidTextField.stringValue;
    config.serverUrl = self.serverUrlTextField.stringValue;
    [TDAnalytics startAnalyticsWithConfig:config];
}


@end
