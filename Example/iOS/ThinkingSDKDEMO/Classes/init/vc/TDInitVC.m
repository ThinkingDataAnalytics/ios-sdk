//
//  InitVC.m
//  ThinkingSDKDEMO
//
//  Created by LiHuanan on 2020/9/18.
//  Copyright © 2020 thinking. All rights reserved.
//

#import "TDInitVC.h"
#import <ThinkingSDK/ThinkingSDK.h>
#import "ThinkingSDKAPI.h"
#import "UIColor+TDUtil.h"

@interface TDInitVC ()
@property(strong, nonatomic) UILabel *appIdNameLable;
@property(strong, nonatomic) UILabel *serverUrlNameLable;
@property(strong, nonatomic) UILabel *aliasNameLable;
@property(strong,nonatomic) UITextField *appidTF;
@property(strong,nonatomic) UITextField *serverTF;
@property(strong,nonatomic) UITextField *instanceNameTF;
@property(strong, nonatomic) UIButton *submitButton;

@end

static NSString * const APP_ID = @"8de3005299604ea1ba5541e564722d73";
static NSString * const SERVER_URL = @"http://10.82.2.137:8991";
static NSString * const ENCRYPT_PUBLIC_KEY =
    @"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqOvk7QsPiVQ+ygNXdwBB"
    @"InPs6+Cpgp7R4etlldsS0IlzUvWE9dEEWBCLMfuGmcPJf5b4vI9OaLjlUeiYt2tF"
    @"+rLpwc1s/XOnIqzv4qBd5yKcfnh/y9i26r9+HYUfxkoVawncIEXm9Ge4WAswtXVA"
    @"sHBEdJgy3LqCoBriLTJ1MWU7YlXQGyLAXzF/fMMWiU5rh2LRmc0q3sST5JLDtudO"
    @"zg5uzwrqdlAsrvkZJzLwOiRAhtbETS5tZcNRjNS32POhmPcrtD+QQ3caFpLpDELl"
    @"7y4e7qICjb8pKZqZoo1gA2xHgBC0okHOUT4eLrcLAYqJ/PCgByHCR5wkD6kGcdx0"
    @"hQIDAQAB";

@implementation TDInitVC

- (void)initTDAnalyticsSDK {
    [TDAnalytics enableLog:YES];

    TDConfig *config = [[TDConfig alloc] init];
    config.appid = self.appidTF.text.length ? self.appidTF.text : APP_ID;
    config.serverUrl = self.serverTF.text.length ? self.serverTF.text : SERVER_URL;
    config.name = self.instanceNameTF.text;
    config.mode = TDModeNormal;
//    config.disableRConfig = true;
    [config enableEncryptWithVersion:0 publicKey:ENCRYPT_PUBLIC_KEY];
    
    [TDAnalytics addWebViewUserAgent];

    [TDAnalytics startAnalyticsWithConfig:config];
    [TDAnalytics enableAutoTrack:TDAutoTrackEventTypeAll];
//    [TDAnalytics login:@"llb"];
//    [TDAnalytics track:@"iOS_001" properties:@{@"aaaa":@111334,@"name":@"002"}];
//    [TDAnalytics userDelete];
//    NSDictionary *autoProperties = @{
//           @"autoProperties": @"xzy_ta",
//           @"autoProperties_num": @1,
//       };
//    [TDAnalytics setAutoTrackProperties:(TDAutoTrackEventTypeAppInstall | TDAutoTrackEventTypeAppStart | TDAutoTrackEventTypeAppEnd)
//                                properties:autoProperties withAppId:@""];
//    [TDAnalytics enableAutoTrack:TDAutoTrackEventTypeAppInstall | TDAutoTrackEventTypeAppStart | TDAutoTrackEventTypeAppEnd];
}

//MARK: private method

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *appidDesLabel = [UILabel new];
    appidDesLabel.text = @"AppId:";
    appidDesLabel.textColor = kTDColor;
    appidDesLabel.font = [UIFont systemFontOfSize:kTDFontSize];
    self.appIdNameLable = appidDesLabel;
    [self.view addSubview:appidDesLabel];
    
    UITextField *appidTF = [UITextField new];
    appidTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:appidTF];
    appidTF.layer.masksToBounds = true;
    appidTF.layer.cornerRadius = kTDCornor;
    appidTF.layer.borderColor = kTDColor2.CGColor;
    appidTF.layer.borderWidth = kTDBorder;
    appidTF.text = APP_ID;
    appidTF.placeholder = @"Required";
    [appidTF setBackgroundColor:[UIColor whiteColor]];
    _appidTF = appidTF;
    
    UILabel *serverDesLabel = [UILabel new];
    serverDesLabel.text = @"ServerUrl:";
    serverDesLabel.textColor = kTDColor;
    serverDesLabel.font = [UIFont systemFontOfSize:kTDFontSize];
    self.serverUrlNameLable = serverDesLabel;
    [self.view addSubview:serverDesLabel];
    
    UILabel *InsNameLabel = [UILabel new];
    InsNameLabel.text = @"AliasName:";
    InsNameLabel.textColor = kTDColor;
    InsNameLabel.font = [UIFont systemFontOfSize:kTDFontSize];
    self.aliasNameLable = InsNameLabel;
    [self.view addSubview:InsNameLabel];
    
    UITextField *serverTF = [UITextField new];
    serverTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    _serverTF = serverTF;
    [self.view addSubview:serverTF];
    serverTF.layer.masksToBounds = true;
    serverTF.layer.cornerRadius = kTDCornor;
    [serverTF setBackgroundColor:[UIColor whiteColor]];
    serverTF.text = SERVER_URL;
    serverTF.placeholder = @"Required";
    
    UITextField *instanceNameTF = [UITextField new];
    instanceNameTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    _instanceNameTF = instanceNameTF;
    [self.view addSubview:instanceNameTF];
    instanceNameTF.layer.masksToBounds = true;
    instanceNameTF.layer.cornerRadius = kTDCornor;
    [instanceNameTF setBackgroundColor:[UIColor whiteColor]];
    instanceNameTF.text = @"";
    instanceNameTF.placeholder = @"Optional";
    
    UIButton* submitBtn = [UIButton new];
    [submitBtn setBackgroundColor:[UIColor whiteColor]];
    [submitBtn setTitleColor:UIColor.tc9 forState:UIControlStateNormal];
    self.submitButton = submitBtn;
    [self.view addSubview:submitBtn];
    [submitBtn setTitle:@"Click to initialize" forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(touchBtn) forControlEvents:UIControlEventTouchUpInside];
    self.submitButton.layer.cornerRadius = 5;
    self.submitButton.layer.masksToBounds = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat appIdTextFiledName_X = kTDLeftPadding;
    CGFloat appIdTextFiledName_Y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat appIdTextFiledName_W = 80;
    CGFloat appIdTextFiledName_H = kTDCommonH;
    CGRect appIdTextFiledNameRect = CGRectMake(appIdTextFiledName_X, appIdTextFiledName_Y, appIdTextFiledName_W, appIdTextFiledName_H);
    self.appIdNameLable.frame = appIdTextFiledNameRect;
    
    CGFloat appIdTextField_X = CGRectGetMaxX(appIdTextFiledNameRect);
    CGFloat appIdTextField_Y = appIdTextFiledName_Y;
    CGFloat appIdTextField_W = (self.view.frame.size.width - appIdTextField_X) - appIdTextFiledName_X;
    CGFloat appIdTextField_H = appIdTextFiledName_H;
    CGRect appIdTextFieldRect = CGRectMake(appIdTextField_X, appIdTextField_Y, appIdTextField_W, appIdTextField_H);
    self.appidTF.frame = appIdTextFieldRect;
    
    CGFloat serverUrlName_X = self.appIdNameLable.frame.origin.x;
    CGFloat serverUrlName_Y = CGRectGetMaxY(self.appIdNameLable.frame) + kTDLeftPadding;
    CGFloat serverUrlName_W = self.appIdNameLable.frame.size.width;
    CGFloat serverUrlName_H = self.appIdNameLable.frame.size.height;
    CGRect serverUrlNameRect = CGRectMake(serverUrlName_X, serverUrlName_Y, serverUrlName_W, serverUrlName_H);
    self.serverUrlNameLable.frame = serverUrlNameRect;
    
    CGFloat serverUrlTextField_X = self.appidTF.frame.origin.x;
    CGFloat serverUrlTextField_Y = CGRectGetMaxY(self.appidTF.frame) + kTDLeftPadding;
    CGFloat serverUrlTextField_W = self.appidTF.frame.size.width;
    CGFloat serverUrlTextField_H = self.appidTF.frame.size.height;
    CGRect serverUrlTextFieldRect = CGRectMake(serverUrlTextField_X, serverUrlTextField_Y, serverUrlTextField_W, serverUrlTextField_H);
    self.serverTF.frame = serverUrlTextFieldRect;
    
    CGFloat aliasNameLabel_X = self.serverUrlNameLable.frame.origin.x;
    CGFloat aliasNameLabel_Y = CGRectGetMaxY(self.serverUrlNameLable.frame) + kTDLeftPadding;
    CGFloat aliasNameLabel_W = self.serverUrlNameLable.frame.size.width;
    CGFloat aliasNameLabel_H = self.serverUrlNameLable.frame.size.height;
    CGRect aliasNameLabelRect = CGRectMake(aliasNameLabel_X, aliasNameLabel_Y, aliasNameLabel_W, aliasNameLabel_H);
    self.aliasNameLable.frame = aliasNameLabelRect;
    
    CGFloat aliasNameTextField_X = self.serverTF.frame.origin.x;
    CGFloat aliasNameTextField_Y = CGRectGetMaxY(self.serverTF.frame) + kTDLeftPadding;
    CGFloat aliasNameTextField_W = self.serverTF.frame.size.width;
    CGFloat aliasNameTextField_H = self.serverTF.frame.size.height;
    CGRect aliasNameTextFieldRect = CGRectMake(aliasNameTextField_X, aliasNameTextField_Y, aliasNameTextField_W, aliasNameTextField_H);
    self.instanceNameTF.frame = aliasNameTextFieldRect;
    
    CGFloat submitButton_X = kTDLeftPadding;
    CGFloat submitButton_W = self.view.frame.size.width - submitButton_X * 2;
    CGFloat submitButton_H = 70;
    CGFloat submitButton_Y = CGRectGetMaxY(self.view.frame) - submitButton_H - kTDBottomSafeHeight;
    CGRect submitButtonRect = CGRectMake(submitButton_X, submitButton_Y, submitButton_W, submitButton_H);
    self.submitButton.frame = submitButtonRect;
}

- (void)touchBtn {
    [self.navigationController popViewControllerAnimated:true];
    
    [self initTDAnalyticsSDK];
            
    if (_callback != nil) {
        _callback();
    }
}

@end
