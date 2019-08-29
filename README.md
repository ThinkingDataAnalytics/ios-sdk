# ThinkingData iOS SDK

ThinkingData iOS SDK 为 iOS 代码埋点提供了 API. 主要功能包括:
- 上报事件数据和用户属性数据
- 本地数据缓存
- 多实例上报
- 用户数据自动采集

本项目包括以下模块:
- ThinkingSDK: 核心功能的实现
- Example 示例应用（仅仅为了展示API使用方法）

## 上报数据

在上报之前，首先通过以下方法初始化 SDK

```objective-c
ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithAppId:@"TA_APP_ID" withUrl:@"TA_SERVER_URL"];
```

参数`TA_APP_ID`是您的项目的APP\_ID，在您申请项目时会给出，请在此处填入

参数`TA_SERVER_URL`为数据上传的URL

如果您使用的是数数科技云服务，请输入以下URL:

http://receiver.ta.thinkingdata.cn

或https://receiver.ta.thinkingdata.cn

如果您使用的是私有化部署的版本，请输入以下URL:

http://<font color="red">数据采集地址</font>

后续可以通过如下两种方法使用 SDK

```objective-c
instance.track("some_event");

[[ThinkingAnalyticsSDK sharedInstanceWithAppid:@"TA_APP_ID"] track:@"some_event"];
```

详细的使用指南可以查看[iOS SDK 使用指南](http://doc.thinkinggame.cn/tgamanual/installation/ios_sdk_installation.html)

## 感谢

- [mixpanel-ios](https://github.com/mixpanel/mixpanel-iphone.git)


