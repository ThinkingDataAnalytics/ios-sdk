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
@interface TDInitVC ()
@property(strong,nonatomic) UITextField *appidTF;
@property(strong,nonatomic) UITextField *serverTF;
@end

@implementation TDInitVC

- (void)setView
{
    [super setView];
    UILabel *appidDesLabel = [UILabel new];
    appidDesLabel.text = @"APPID:";
    appidDesLabel.textColor = kTDColor;
    appidDesLabel.font = [UIFont systemFontOfSize:kTDFontSize];
    [self.view addSubview:appidDesLabel];
    [appidDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kTDLeftPadding);
        make.top.mas_equalTo(kTDY(kTDLeftPadding));
    }];
    
    UITextField *appidTF = [UITextField new];
    appidTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:appidTF];
    appidTF.layer.masksToBounds = true;
    appidTF.layer.cornerRadius = kTDCornor;
    appidTF.layer.borderColor = kTDColor2.CGColor;
    appidTF.layer.borderWidth = kTDBorder;
    //appidTF.text = @"7a055a4bd7ec423fa5294b4a2c1eff28";
    appidTF.text = @"d265efeedb2d469ca275fc3bfe569631";
//    appidTF.text = @"1b1c1fef65e3482bad5c9d0e6a823356";
    [appidTF setBackgroundColor:[UIColor whiteColor]];
    [appidTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(appidDesLabel.mas_right).offset(kTDCommonPadding);
        make.height.mas_equalTo(kTDCommonH);
        make.width.mas_equalTo(kTDCommonW);
        make.centerY.mas_equalTo(appidDesLabel);
    }];
    _appidTF = appidTF;
    
    UILabel *serverDesLabel = [UILabel new];
    serverDesLabel.text = @"SERVER:";
    serverDesLabel.textColor = kTDColor;
    serverDesLabel.font = [UIFont systemFontOfSize:kTDFontSize];
    [self.view addSubview:serverDesLabel];
    [serverDesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kTDLeftPadding);
        make.top.mas_equalTo(appidDesLabel.mas_bottom).offset(kTDCommonMargin);
    }];
    
    UITextField *serverTF = [UITextField new];
    serverTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    _serverTF = serverTF;
    [self.view addSubview:serverTF];
    serverTF.layer.masksToBounds = true;
    serverTF.layer.cornerRadius = kTDCornor;
    [serverTF setBackgroundColor:[UIColor whiteColor]];
    [serverTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(appidTF);
        make.height.mas_equalTo(kTDCommonH);
        make.width.mas_equalTo(kTDCommonW);
        make.centerY.mas_equalTo(serverDesLabel);
    }];
//    serverTF.text = @"https://receiver-ta-dev.thinkingdata.cn";
    
    serverTF.text = @"https://receiver-ta-demo.thinkingdata.cn";
//    serverTF.text = @"http://receiver.ta.thinkingdata.cn/";
    
    UIButton* submitBtn = [UIButton new];
    [submitBtn setBackgroundColor:[UIColor whiteColor]];
    [submitBtn setTitleColor:UIColor.tc9 forState:UIControlStateNormal];
    [self.view addSubview:submitBtn];
    [submitBtn setTitle:@"点击初始化" forState:UIControlStateNormal];
    [submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.mas_equalTo(kTDBottomSafeHeight+50);
    }];
    [submitBtn addTarget:self action:@selector(touchBtn) forControlEvents:UIControlEventTouchUpInside];
      
    //CGRect appidDesFrame= CGRectMake(, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
//    UITextField *appidTF = [UITextField new];
//    [self.view addSubview:appidTF];
//    appidTF.text = @"debug-appid";
//    CGRect appidRec = CGRectMake(0, kTDNavBarAndStatusBarHeight, 150, 35);
//    appidTF.backgroundColor = [UIColor redColor];
//    appidTF.frame = appidRec;
}
- (NSString*)rightTitle
{
    return  @"初始化功能";
    
}
- (void)setData
{
    
}
- (void)touchBtn
{
    [self.navigationController popViewControllerAnimated:true];
    if([ThinkingSDKAPI getInstance] == nil)
    {
        TDConfig *config = [TDConfig new];
        config.appid = _appidTF.text;
        config.configureURL = _serverTF.text;
        config.enableEncrypt = YES;
//        config.debugMode = ThinkingAnalyticsDebug;
        config.localSecretKey = ^TDSecretKey * _Nonnull{
            return [[TDSecretKey alloc] initWithVersion:1
                                              publicKey:@"MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA53jcQ05rxq7Vk5FSbyKw8iQf/OSaTpH/Qh9Y3X3SKWDY9YI+kE52USeg66g1KzT10slMwB1lVBshi1ornhbq0wDoUQE2bzSti3X6AYm/qvv37y7J/XRKLyyFaQFYfdKsHlS6zyDep7pQvkMCIxQY/2ZresFDGD+wwcMFolp0qh/O1vRM8Zu4X/10xHJvzGbRRVgDnx/quycuXt6fmlFHVOQXd2yOinfv5QTWO39SWce960PyIv+MDgl09COOKEcxbBSQBotdT0s4FBh9wtHosO7qSY4JPmabxdxVqWleWgtR7PStEjNeZgCUzi0aAgt+g9ISI3dzfexh4vkn5p7xKwIDAQAB"];
        };
//        config.debugMode = ThinkingAnalyticsDebug;
        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
        ThinkingAnalyticsSDK* instance =  [ThinkingAnalyticsSDK startWithConfig:config];
//        ThinkingAnalyticsSDK* instance =  [ThinkingAnalyticsSDK startWithAppId:_appidTF.text withUrl:_serverTF.text withConfig:config];
        [ThinkingSDKAPI setInstance:instance];
//        [ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];
        
        if(_callback != nil)
        {
            _callback();
        }
    }
    
}

@end
