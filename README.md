iOS SDK 使用指南

::: tip 提示

 在接入前, 请先阅读[接入前准备](https://thinkingdata.feishu.cn/wiki/wikcny3Gq0wAYVKbpy0fAtOED1D)。

您可以在 [GitHub](https://github.com/ThinkingDataAnalytics/ios-sdk) 获取 iOS SDK 源码。

iOS SDK 要求最低系统版本为iOS 8.0

iOS SDK ( Framework 格式) 大小约为 8.1 MB

:::

**最新版本为:** 2.8.1

**更新时间为:** 2022-06-13

**[下载地址](https://download.thinkingdata.cn/client/release/ta_ios_sdk.zip)**

## 一、集成与初始化 SDK

### 1.1 自动集成 SDK

- 使用 CocoaPods 安装 SDK

1.创建并编辑 Podfile 内容（如果已有，直接编辑）：

创建 Podfile，项目工程（`.xcodeproj`）文件同目录下命令行执行命令：

```Shell
pod init
```

编辑 Podfile 的内容如下：

```Ruby
platform :ios, '9.0'

target 'YourProjectTarget' do

  pod 'ThinkingSDK'  #ThinkingSDK

end
```

从 v2.8.1 版本开始，SDK 支持在 AppExtension 中进行数据采集。

如果您的项目存在 AppExtension，那么编辑 Podfile 的内容如下：

```Ruby
target 'YourAppExtensionTarget' do

  pod "ThinkingSDK/Extension"

end
```

  

2.执行安装命令

```
pod install
```

成功以后，会出现如下记录：

![img](https://thinkingdata.feishu.cn/space/api/box/stream/download/asynccode/?code=ODAwYzk0OTA2MmQ4NDJlMDFlODdkZjg1MGQ4NGZhZmNfdnVsTVp0M05aUllvcXFLVDR5eEQ2aDhIV3VodDFrVHNfVG9rZW46Ym94Y25pdHhGMzVVbzh3MXFWR2VVYXJsektnXzE2NTUxNzE0OTM6MTY1NTE3NTA5M19WNA)

3.导入成功，启动工程

命令执行成功后，会生成 `.xcworkspace` 文件，说明您已成功导入 `iOS SDK`。打开 `.xcworkspace` 文件以启动工程（注意：此时不能同时开启 `.xcodeproj` 文件）

- 使用Carthage方式安装SDK

1.在 Cartfile 文件中添加以下配置：

```
github "ThinkingDataAnalytics/ios-sdk"
```

2.执行 `carthage update --platform iOS` 并将 `ThinkingSDK.framework` 添加到您的项目中

### 1.2 手动集成 SDK

1.下载并解压 [iOS SDK](https://download.thinkingdata.cn/client/release/ta_ios_sdk.zip)

2.将 `ThinkingSDK.framework`拖入 XCode Project Workspace 工程项目中

3.修改工程设置 Targets 选项下的 Build Settings 选项卡中 Other linker flags 的设置 添加 -ObjC

![img](https://thinkingdata.feishu.cn/space/api/box/stream/download/asynccode/?code=NDljOGU1ZGUwOTk1Mzk4MmRjYmRlOTEwN2Q5YzY4NmVfc2l3TFBmS2Y2blYzZzNOZnpHbFZHc1AwV1ZnUzNvbE5fVG9rZW46Ym94Y25wWTF6VmFjdkFCSUg1d3RvOEM2T0JiXzE2NTUxNzE0OTM6MTY1NTE3NTA5M19WNA)

4.切换到 Build Phases 选项卡，在 Link Binary With Libraries 栏目下添加如下依赖项：

```
libz.dylib`、`Security.framework`、`SystemConfiguration.framework`、`libsqlite3.tbd
```

![img](https://thinkingdata.feishu.cn/space/api/box/stream/download/asynccode/?code=MTgzOTk5NzYwNzljZDc4MmQ5NjU5YmNlODFlMzU5Y2JfVDE3M1o0QnhTZ2Nxd2VLaGFHSlVHWnpWOXZWUUM2S05fVG9rZW46Ym94Y24yYUs2dnVuMVJ0SzMwS3JxMzF1c3pmXzE2NTUxNzE0OTM6MTY1NTE3NTA5M19WNA)

### 1.3 初始化 SDK

在 v1.2.0 版本中，新增多 APP ID 实例的特性，关于多 APPID 的使用指南，请参考 [iOS SDK 多 APPID 指南](https://thinkingdata.feishu.cn/wiki/wikcn1DTIK0bEWLjS6JiMDyzIPf)一节

在 AppDelegate.m 中添加 `#import <ThinkingSDK/ThinkingAnalyticsSDK.h>`

然后在 `application:didFinishLaunchingWithOptions:` 中添加初始化

如下

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 初始化

ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithAppId:APP_ID withUrl:SERVER_URL];



// 支持初始化多个APPID实例

// ThinkingAnalyticsSDK *instance2 = [ThinkingAnalyticsSDK startWithAppId:APP_ID2 withUrl:SERVER_URL2];
```

:::

::: el-tab-pane label=Swift

```Swift
// 初始化

let instance = ThinkingAnalyticsSDK.start(withAppId: "YOUR_APPID", withUrl: "YOUR_SERVER_URL")



// 支持初始化多个APPID实例

// let instance2 = ThinkingAnalyticsSDK.start(withAppId: "YOUR_APPID2", withUrl: "YOUR_SERVER_URL2")
```

:::

::::

参数 `APP_ID` 是您的项目的 APP_ID ，在您申请项目时会给出，请在此处填入

参数 `SERVER_URL` 为数据上传的 URL

如果您使用的是云服务，请输入以下 URL:

https://receiver.ta.thinkingdata.cn

如果您使用的是私有化部署的版本，请输入以下 URL:

https://数据采集地址

使用 https 协议，请自行申请具有 SSL 证书的域名，TA 工作人员将会协助进行端口配置。

在完成初始化后，您可以按以下方式来使用 SDK ：

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 后续可以通过如下两种方法使用 SDK

[instance track:@"event_name" properties:eventProperties];

// [[ThinkingAnalyticsSDK sharedInstanceWithAppid:APP_ID] track:@"event_name" properties:eventProperties];



// v1.2.0版本之前，或者单实例可使用下列使用 SDK

// [[ThinkingAnalyticsSDK sharedInstance] track:@"event_name" properties:eventProperties];
```

:::

::: el-tab-pane label=Swift

```Swift
// 后续可以通过如下两种方法使用 SDK

let properties:Dictionary<String,String>=["key":"value"];

instance.track("event_name", properties:properties)



// v1.2.0版本之前，或者单实例可使用下列使用 SDK

// ThinkingAnalyticsSDK.sharedInstance(withAppid: "YOUR_APPID").track("event_name", properties:eventProperties)
```

:::

::::

在 v2.7.3 版本中，新增实例名特性，在实例初始化时传入实例名称 name ，用于标识实例。您也可以根据实例名称 name 获取实例。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// v2.7.2版本以后为实例设置 name

TDConfig *config = [[TDConfig alloc] initWithAppId:@"YOUR_APPID" serverUrl:@"YOUR_SERVER_URL"];

config.name = @"YOUR_NAME";

[ThinkingAnalyticsSDK startWithConfig:config];



// 根据name获取实例

ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK sharedInstanceWithAppid: @"YOUR_NAME"];
```

:::

::: el-tab-pane label=Swift

```Swift
// v2.7.2版本以后为实例设置 name

let config = TDConfig.init(appId: "YOUR_APPID", serverUrl: "YOUR_SERVER_URL")

config.name = "YOUR_NAME"

ThinkingAnalyticsSDK.start(with: config)



// 根据 name 获取实例

let instance = ThinkingAnalyticsSDK.sharedInstance(withAppid: "YOUR_NAME")
```

:::

::::

### 1.4 后台自启事件说明

iOS 12 及以下版本（iOS 13 没有使用 `EnableSceneSupport`）时，后台自启事件默认不统计，通过 `trackRelaunchedInBackgroundEvents` 来配置，`YES` 表示采集，`NO` 表示不采集。

iOS 13 使用了 `EnableSceneSupport` ，必须传入 `launchOptions` 参数。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // ...

    TDConfig *config = [[TDConfig alloc] init];

    config.launchOptions = launchOptions;

    config.trackRelaunchedInBackgroundEvents = YES;

    ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithAppId:@"YOUR_APPID" withUrl:@"YOUR_SERVER_URL" withConfig:config];

    return YES;

}
```

:::

::: el-tab-pane label=Swift

```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {



    let config = TDConfig()

    config.launchOptions = launchOptions ?? [:]

    config.trackRelaunchedInBackgroundEvents = true

    ThinkingAnalyticsSDK.start(withAppId: "APP_ID", withUrl: "SERVICE_URL", with: config)



    return true

}
```

:::

::::

### 1.5 开启与 H5 页面的打通（可选）

如果需要与采集 H5 页面数据的 JavaScript SDK 进行打通，请调用如下接口，详情请参考 [H5 与 APP SDK 打通](https://thinkingdata.feishu.cn/wiki/wikcn9teoUAN09S9m59j9IRO9te)一节

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 打通H5页面数据

[instance addWebViewUserAgent];

// [[ThinkingAnalyticsSDK sharedInstanceWithAppid:APP_ID] addWebViewUserAgent];
```

:::

::: el-tab-pane label=Swift

```Swift
// 打通H5页面数据

instance.addWebViewUserAgent()
```

:::

::::

### 1.6 AppExtension 事件采集

SDK 从 2.8.1 版本后支持在 AppExtension 中进行事件采集。

在 AppExtension 中初始化专用事件采集模块：

```Objective-C
// 如果需要时间校准，请开启这一行代码

[TAAppExtensionAnalytic calibrateTimeWithNtp:@"time.apple.com"];



// 初始化

NSString *token = @"您的事件采集类的唯一标识，一般为appid";

NSString *appGroupId = @"您的应用组标识";

TAAppExtensionAnalytic *analytic = [TAAppExtensionAnalytic analyticWithInstanceName:token appGroupId:appGroupId];
```

AppExtension 中的事件采集操作：

```Objective-C
[analytic writeEvent:@"event_name" properties:@{@"property_key": @"value"}];
```

AppExtension 中的事件采集，只做记录，不会上报，数据存储在 AppGroup 的共享存储中。所以需要在主 App 启动时，从共享存储获取数据，并进行上报。在主 App 启动完成，且 SDK 初始化完成后，调用如下代码：

```Objective-C
NSString *token = @"您的事件采集类的唯一标识，一般为appid";

ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK sharedInstanceWithAppid:token];

    

NSString *appGroupId = @"您的应用组标识";

[instance trackFromAppExtensionWithAppGroupId:appGroupId];
```

## 二、设置用户 ID

SDK 实例会使用随机 UUID 作为每个用户的默认访客 ID，该 ID 将会作为用户在未登录状态下身份识别 ID。需要注意的是，访客 ID 在用户重新安装 App 以及更换设备时将会变更。

### 2.1 设置访客 ID（可选）

如果用户在您的产品中可以未登录状态下使用，且您需要配置用户在未登录状态下的访客 ID ，则您可以调用 `identify:` 来进行设置：

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
[instance identify:@"123ABCabc"];
```

:::

::: el-tab-pane label=Swift

```Swift
instance.identify("123ABCabc")
```

:::

::::

如果您需要替换访客 ID ，则应当在初始化 SDK 结束之后立即进行调用，请勿多次调用，以免产生无用的账号

如果需要获得当前访客 ID，可以调用 `getDistinctId` 获取：

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 返回访客 ID，多实例的情况下，返回的是调用实例的访客 ID

[instance getDistinctId];
```

:::

::: el-tab-pane label=Swift

```Swift
// 返回访客 ID，多实例的情况下，返回的是调用实例的访客 ID

instance.getDistinctId()
```

:::

::::

### 2.2 设置账号 ID

在用户进行登录时，可调用 `login:` 来设置用户的账号 ID， TA 平台优先以账号 ID 作为身份标识，设置后的账号 ID 将会被保存，多次调用 `login:` 将覆盖先前的账号 ID ：

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
[instance login:@"123ABCabc@thinkingdata.cn"];
```

:::

::: el-tab-pane label=Swift

```Swift
instance.login("123ABCabc@thinkingdata.cn")
```

:::

::::

**请注意，该方法不会上传用户登录的事件**

### 2.3 清空账号 ID

在用户产生登出行为之后，可调用 `logout` 来清除账号 ID ，在下次调用 `login:` 之前，将会以访客 ID 进行身份识别

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
[instance logout];
```

:::

::: el-tab-pane label=Swift

```Swift
instance.logout()
```

:::

::::

我们推荐您在显性的登出事件时调用 `logout`，比如用户产生注销行为时才调用，不需要在关闭 App 时进行调用。

**请注意，该方法不会上传用户登出的事件**

## 三、发送事件

在 SDK 初始化完成之后，您就可以调用 `track:`、 `track:properties:`来上传事件，一般情况下，您可能需要上传 20~100 个不同的事件，如果您是第一次使用 TA 后台，我们推荐您先上传几个关键事件。

### 3.1 发送事件

您可以调用 `track:`、 `track:properties:` 来上传事件，建议您根据先前梳理的文档来设置事件的属性以及发送信息的条件：

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 该事件没有设置属性

[instance track:@"StartApp"];



// 上传购买商品事件

NSDictionary *eventProperties = @{

    @"product_name": @"商品名",

    @"product_num": @(1),

    @"IsFirstBuy": @(YES)

};

[instance track:@"product_buy" properties:eventProperties];
```

:::

::: el-tab-pane label=Swift

```Swift
// 该事件没有设置属性

instance.track("StartApp")



// 上传购买商品事件

let properties = [

    "productName": "商品名",

    "productNumber": 1,

    "isFirstBuy": true

] as [String: Any]

ThinkingAnalyticsSDK.sharedInstance()?.track("event_name", properties: properties)
```

:::

::::

事件的名称是 `NSString` 类型，只能以字母开头，可包含数字，字母和下划线“_”，长度最大为 50 个字符，对字母大小写不敏感。

- 事件的属性是一个 `NSDictionary` 对象，其中每个元素代表一个属性。
- Key 的值为属性的名称，为 `NSString` 类型，规定只能以字母开头，包含数字，字母和下划线“_”，长度最大为 50 个字符，对字母大小写不敏感。
- Value 为该属性的值，可以为 `NSString`、`NSNumber`、`NSDate`、 `NSArray`、`NSDictionary`。`NSDictionary`中的内容可以包含`NSString`、`NSNumber`、`NSDate` 以及 `NSArray`(其中内容为字符串)； `NSArray` 中的内容可以包含 `NSDictionary` 和 `NSString`
- **如果您需要上传布尔型的属性，则请以** `@YES` **与** `@NO` **或** `[NSNumber numberWithBool:YES]` **与** `[NSNumber numberWithBool:NO]` **来赋值。**

 **不可以使用** `@true`**、** `@false`**、** `@TRUE` **和** `@FALSE` **赋值布尔型数据。**

> 注意: 

> NSArray 类型在 v2.4.0 版本开始支持，需配合 TA 后台 v2.5 及后续版本使用.

> NSDictionary类型v2.7.3 版本开始支持，需配合TA后台v3.5及后续版本使用

在 v2.2.0 版本中加入了设置事件触发时间及时间偏移的方法重载，支持传入 NSDate类型的参数来设置事件触发时间，以 NSTimeZone 类型的参数来设置时间偏移。不传入该参数，则取 track: 被调用时的本机时间以及偏移作为事件触发时间以及时区偏移：

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
NSDictionary *properties = @{

    @"product_name": @"商品名",

    @"product_num": @1,

    @"IsFirstBuy": @YES

};

[instance track:@"product_buy"

     properties:properties

           time:[NSDate date]

       timeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
```

:::

::: el-tab-pane label=Swift

```Swift
let properties = ["product_name": "商品名", "product_num": NSNumber.init(value: 1), "IsFirstBuy": true] as [String: Any]

instance.track("product_buy", properties:properties time: Date(), timeZone: NSTimeZone(name: "Asia/Shanghai")! as TimeZone)
```

:::

::::

> 注意：尽管事件可以设置触发时间，但是接收端会做如下的限制，只接收相对服务器时间在前 10 天至后 3 天的数据，超过时限的数据将会被视为异常数据，整条数据无法入库。

自 v2.3.1 版本开始，您可以通过设置 SDK 默认时区的方式，对齐多个时区下的事件时间，请参考[设置默认时区](https://thinkingdata.feishu.cn/wiki/wikcnEZ7EnmOnSq6Q4qPntLVASg#u9RgDy)小节。

自 v2.5.0 开始，您可以通过校准 SDK 时间接口来统一使用服务端时间完成数据采集。请参考[校准时间](https://thinkingdata.feishu.cn/wiki/wikcnEZ7EnmOnSq6Q4qPntLVASg#KFuHq5)小节。

### 3.2 设置公共事件属性

对于一些重要的属性，譬如用户的会员等级、来源渠道等，这些属性需要设置在每个事件中，此时您可以将这些属性设置为公共事件属性。公共事件属性指的就是每个事件都会带有的属性，您可以调用 `setSuperProperties:` 来设置公共属性 ，我们推荐您在发送事件前，先设置公共事件属性。

公共事件属性的格式要求与事件属性一致。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
[instance setSuperProperties:@{@"Channel": @"ABC", @"isTest": @YES}];



// 设置后上传数据：

[instance track:@"product_view"

     properties:@{@"product_id": @"A1234"}];



// 相当于在事件中设置了属性：

NSDictionary *properties = @{

    @"Channel": @"ABC",

    @"isTest": @YES,

    @"product_id": @"A1234"

};

[instance track:@"product_view"

     properties:properties];
```

:::

::: el-tab-pane label=Swift

```Swift
instance.setSuperProperties(["Channel" : "ABC", "isTest": true])



// 设置后上传数据：

instance.track("product_view", properties: ["product_id" : "A1234"])



// 相当于在事件中设置了属性：

let properties = ["Channel": "ABC", "isTest": true, "product_id": "A1234"] as [String: Any]

instance.track("product_view", properties: properties)
```

:::

::::

公共事件属性将会被保存到缓存中，无需每次启动 App 时调用。如果调用 `setSuperProperties:` 设置了先前已设置过的公共事件属性，则会覆盖之前的属性。如果公共事件属性和 `track:properties:` 上传的某个属性的 Key 重复，则该事件的属性会覆盖公共事件属性：

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
[instance setSuperProperties:@{@"Channel": @"ABC", @"isTest": @YES}];



// 覆盖"Channel"，此时属性"Channel"的值为"XYZ"

[instance setSuperProperties:@{@"Channel": @"XYZ"}];



// 覆盖"isTest"，"isTest"的值为False

[instance track:@"product_view"

     properties:@{@"isTest": @NO}];
```

:::

::: el-tab-pane label=Swift

```Swift
instance.setSuperProperties(["Channel": "ABC", "isTest": true])



// 覆盖"Channel"，此时属性"Channel"的值为"XYZ"

instance.setSuperProperties(["Channel": "XYZ"])



// 覆盖"isTest"，"isTest"的值为False

instance.track("product_view", properties: ["isTest": false])
```

:::

::::

如果您需要删除某个公共事件属性，可以调用 `unsetSuperProperty:` 清除指定的公共事件属性；如果您想要清空所有公共事件属性，则可以调用 `clearSuperProperties`;如果您想要获取所有公共事件属性，可以调用`currentSuperProperties`;

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 清除一条公共事件属性，将之前设置"isTest"属性清除

[instance unsetSuperProperty:@"isTest"];



// 清除所有公共事件属性

[instance clearSuperProperties];



//获取所有公共属性

[instance currentSuperProperties];
```

:::

::: el-tab-pane label=Swift

```Swift
// 清除一条公共事件属性，将之前设置"isTest"属性清除

instance.unsetSuperProperty("isTest")



// 清除所有公共事件属性

instance.clearSuperProperties()



//获取所有公共属性

instance.currentSuperProperties()
```

:::

::::

### 3.3 设置动态公共属性

在 v1.2.0 版本中，新增了动态公共属性的特性，即公共属性可以上报时获取当时的值，使得诸如会员等级之类的可变公共属性可以被便捷地上报。通过 `registerDynamicSuperProperties` 设置动态公共属性类之后，SDK 将会在事件上报时自动执行并获取返回值中的属性，添加到触发的事件中。以下例子是每次上报时将获取当前时间并切换时区，当任意事件触发时，SDK 会将返回的时间加入到该事件的属性中。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 设置动态公共属性，在事件上报时动态获取事件发生时刻

[instance registerDynamicSuperProperties:^NSDictionary * _Nonnull{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];

    formatter.timeZone = [NSTimeZone timeZoneWithName:@"America/Chicago"];

    NSDate *datenow = [NSDate date];

    NSString *currentTimeString = [formatter stringFromDate:datenow];

    return @{@"AmericaTime": currentTimeString};

}];
```

:::

::: el-tab-pane label=Swift

```Swift
// 设置动态公共属性，在事件上报时动态获取事件发生时刻

instance.registerDynamicSuperProperties { () -> [String : Any] in

    let formatter = DateFormatter()

    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

    formatter.timeZone = TimeZone(abbreviation: "CDT")

    let currentTimeString = formatter.string(from: Date())

    return ["AmericaTime": currentTimeString]

}
```

:::

::::

### 3.4 记录事件时长

如果您需要记录某个事件的持续时长，可以调用 `timeEvent` 来开始计时，配置您想要计时的事件名称，当您上传该事件时，将会自动在您的事件属性中加入 `#duration` 这一属性来表示记录的时长，单位为秒。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 开始计时，记录的事件为 "product_view"

[instance timeEvent:@"product_view"];



//其他代码...



// 上传事件，计时结束，"product_view" 这一事件中将会带有表示事件时长的属性 "#duration"

[instance track:@"product_view"];
```

:::

::: el-tab-pane label=Swift

```Swift
// 开始计时，记录的事件为 "product_view"

instance.timeEvent("product_view")



// 其他代码...



// 上传事件，计时结束，"product_view" 这一事件中将会带有表示事件时长的属性 "#duration"

instance.track("product_view")
```

:::

::::

## 四、用户属性

TA 平台目前支持的用户属性设置接口为 `user_set:`、`user_setOnce:`、`user_add:`、`user_unset:`、`user_delete`与`user_append`

### 4.1 user_set

对于一般的用户属性，您可以调用 `user_set:` 来进行设置，使用该接口上传的属性将会覆盖原有的属性值，如果之前不存在该用户属性，则会新建该用户属性，类型与传入属性的类型一致

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 设置用户属性

[instance user_set:@{@"UserName": @"TA", @"Age": @20}];
```

:::

::: el-tab-pane label=Swift

```Swift
// 设置用户属性

instance.user_set(["UserName": "TA", "Age": 20])
```

:::

::::

> 属性格式要求与事件属性保持一致。

### 4.2 user_setOnce

如果您要上传的用户属性只要设置一次，则可以调用 `user_setOnce:`来进行设置，当该属性之前已经有值的时候，将会忽略这条信息。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 设置用户名

[instance user_setOnce:@{@"UserName": @"TA"}];

// 此时用户名为TA



[instance user_setOnce:@{@"UserName": @"ABC"}];

// 此时用户名仍为TA，此条数据被忽略
```

:::

::: el-tab-pane label=Swift

```Swift
// 设置用户名

instance.user_setOnce(["UserName": "TA"])

// 此时用户名为TA



instance.user_setOnce(["UserName": "ABC"])

// 此时用户名仍为TA，此条数据被忽略
```

:::

::::

> 属性格式要求与事件属性保持一致。

### 4.3 user_add

当您要上传数值型的属性时，您可以调用 `user_add:`来对该属性进行累加操作，如果该属性还未被设置，则会赋值 0 后再进行计算

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 设置累计付费金额

[instance user_add:@{@"TotalRevenue": @6}];

// 此时累计付费值为6



[instance user_add:@{@"TotalRevenue": @30}];

// 此时累计付费值为36
```

:::

::: el-tab-pane label=Swift

```Swift
// 设置累计付费金额

instance.user_add(["TotalRevenue": 6])

// 此时累计付费值为6



instance.user_add(["TotalRevenue": 30])

// 此时累计付费值为36
```

:::

::::

> 设置的属性key为字符串，Value 只允许为数值。

### 4.4 user_unset

当您要清空用户的某个用户属性值时，您可以调用 `user_unset:`来对指定属性进行清空操作，如果该属性还未在集群中被创建，则 `user_unset:` **不会**创建该属性

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 清空该用户的累计付费金额属性值

[instance user_unset:@"TotalRevenue"];
```

:::

::: el-tab-pane label=Swift

```Swift
// 清空该用户的累计付费金额属性值

instance.user_unset("TotalRevenue")
```

:::

::::

> user_unset传入值为被清空属性的 Key 值。

### 4.5 user_delete

如果您要删除某个用户，可以调用 `user_delete`将这名用户删除，您将无法再查询该名用户的用户属性，但该用户产生的事件仍然可以被查询到

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
[instance user_delete];
```

:::

::: el-tab-pane label=Swift

```Swift
instance.user_delete()
```

:::

::::

### 4.6 user_append

从 v2.4.0 版本开始，您可以调用 `user_append` 对 NSArray 类型的用户属性进行追加操作。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 调用 user_append 为用户属性 product_buy 追加元素。如果不存在，会新建该元素

[instance user_append:@{@"product_buy": @[@"product_name1", @"product_name2"]}];
```

:::

::: el-tab-pane label=Swift

```Swift
instance.user_append(["product_buy": ["product_name1", "product_name2"]])
```

:::

::::



### 4.7 user_uniqAppend

从 v2.8.0 版本开始，您可以调用 `user_uniqAppend` 对 NSArray 类型的用户属性进行追加操作。

和 `user_append` 接口的区别，调用 `user_uniqAppend` 接口会对追加的用户属性进行去重， `user_append` 接口不做去重，用户属性可存在重复。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 调用 user_uniqAppend 为用户属性 product_buy 追加元素。如果不存在，会新建该元素

[instance user_uniqAppend:@{@"product_buy": @[@"product_name1", @"product_name2"]}];
```

:::

::: el-tab-pane label=Swift

```Swift
instance.user_uniqAppend(["product_buy": ["product_name1", "product_name2"]])
```

:::

::::



## 五、自动采集事件

关于自动采集事件的具体使用方法，请参考 [iOS SDK 自动采集指南](https://thinkingdata.feishu.cn/wiki/wikcnnwm5AVVljOvEOwUb6DFIWh)一章。

## 六、SDK 配置

### 6.1 设置上传的网络条件

在默认情况下，SDK 将会网络条件为在 2G, 3G, 4G, 5G 及 Wifi 时上传数据，您可以通过下列方法修改允许上传的网络条件：

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 在 2G, 3G, 4G, 5G 及 Wifi 时上传数据

[instance setNetworkType:TDNetworkTypeALL];



// 只在 Wifi 环境下上报数据

[instance setNetworkType:TDNetworkTypeOnlyWIFI];



// 在 2G ,3G, 4G, 5G 及 Wifi 时上传数据, 默认设置

[instance setNetworkType:TDNetworkTypeDefault];
```

:::

::: el-tab-pane label=Swift

```Swift
// 在 2G, 3G, 4G 及 Wifi 时上传数据

ThinkingAnalyticsSDK.sharedInstance()?.setNetworkType(ThinkingAnalyticsNetworkType.TDNetworkTypeALL)



// 只在 Wifi 环境下上报数据

ThinkingAnalyticsSDK.sharedInstance()?.setNetworkType(ThinkingAnalyticsNetworkType.TDNetworkTypeOnlyWIFI)



// 在 3G, 4G 及 Wifi 时上传数据, 默认设置

ThinkingAnalyticsSDK.sharedInstance()?.setNetworkType(ThinkingAnalyticsNetworkType.TDNetworkTypeDefault)
```

:::

::::

### 6.2 数据上报状态

在 v2.8.0 版本中，新增了 SDK 数据上报状态，一共有四种状态：

#### 6.2.1 暂停 SDK 上报（TATrackStatusPause）

您可能希望在一些场景下，暂时停止 SDK 的数据采集以及上报，比如用户处于测试环境中、或者用户登录了一个测试账号，此时您可以调用下列接口，暂时停止 SDK 的上报。

您可以通过某一实例（包括主要实例以及轻实例）调用 `setTrackStatus:`，传入 `TATrackStatusPause` 来暂停 SDK 的上报，该实例已经设置的 `#distinct_id`、`#account_id`、公共属性等将保留；该实例已经采集但还未上报成功的数据将继续尝试上报；后续该实例不能采集以及上报任何新数据、不能设置访客 ID、账户 ID 以及公共属性等，但是可以读取该实例已经设置的公共属性和设备 ID、访客 ID、账号 ID 等信息。

实例的停止状态将会被保存在本地缓存，直到调用 `setTrackStatus:`  、传入 `TATrackStatusNormal` ，SDK 实例将会重新恢复数据采集以及上报，需要注意轻实例因为不进行缓存，因此每次打开 APP 后，轻实例的暂停状态不会被保留，将重新开启上报。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 暂停上报

[instance setTrackStatus: TATrackStatusPause];



// 恢复上报

[instance setTrackStatus: TATrackStatusNormal];
```

:::

::: el-tab-pane label=Swift

```Swift
// 暂停上报

instance.setTrackStatus(.pause)



// 恢复上报

instance.setTrackStatus(.normal)
```

:::

::::

#### 6.2.2 停止SDK上报并清除缓存（TATrackStatusStop）

在一些特殊场景下，您可能需要完全停止 SDK 的功能，比如在适用 GDPR 的地区，用户选择不提供数据采集权限，则您可以调用如下接口完全关闭 SDK 的功能。

`TATrackStatusStop` 只能通过主要实例调用，与 `TATrackStatusPause` 的最大区别在于，其将会清空该实例的本地缓存，包括本实例的访客 ID，账号 ID，公共属性，以及未上报的数据队列。之后再关闭该实例的采集和上报功能。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 停止上报，并重置本地缓存

[instance setTrackStatus: TATrackStatusStop];
```

:::

::: el-tab-pane label=Swift

```Swift
// 停止上报，并重置本地缓存

instance.setTrackStatus(.stop)
```

:::

::::

实例的停止状态也将保存在本地缓存，直到调用 `setTrackStatus:`  、传入 `TATrackStatusNormal` ，后续可以继续上报，但此时相当于一个全新的实例

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 重新开启上报

[instance setTrackStatus: TATrackStatusNormal];
```

:::

::: el-tab-pane label=Swift

```Swift
// 重新开启上报

instance.setTrackStatus(.normal)
```

:::

::::

#### 6.2.3 数据采集入库但暂停上报数据（TATrackStatusSaveOnly）

您可能希望在一些场景下，暂时停止 SDK 数据的网络上报，以免影响用户体验，比如用户处于游戏战斗场景，此时您可以调用下列接口，暂时停止 SDK 的网络上报。

您可以通过某一实例（包括主要实例以及轻实例）调用 `setTrackStatus:` ，传入 `TATrackStatusSaveOnly` 来暂停 SDK 的网络上报（数据采集依然存在）；

实例的停止状态将会被保存在本地缓存，直到调用 `setTrackStatus:`  、传入 `TATrackStatusNormal` ，SDK 实例将会把本地库中未上报数据立即上报，需要注意轻实例因为不进行缓存，因此每次打开 APP 后，轻实例的暂停状态不会被保留，将重新开启上报。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 可以采集入库 暂停发送数据

[instance setTrackStatus: TATrackStatusSaveOnly];



// 恢复上报

[instance setTrackStatus: TATrackStatusNormal];
```

:::

::: el-tab-pane label=Swift

```Swift
// 可以采集入库 暂停发送数据

instance.setTrackStatus(.saveOnly)



// 恢复上报

instance.setTrackStatus(.normal)
```

:::

::::

#### 6.2.4 正常状态（TATrackStatusNormal）

SDK 正常状态`TATrackStatusNormal`，数据会进行采集并网络上报。

SDK不进行数据上报状态设置的话，就是默认此状态。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 正常状态（默认状态） 可以不进行设置

[instance setTrackStatus: TATrackStatusNormal];
```

:::

::: el-tab-pane label=Swift

```Swift
// 正常状态（默认状态） 可以不进行设置

instance.setTrackStatus(.normal)
```

:::

::::

### 6.3 打印数据 Log

可以调用`setLogLevel`来开启（默认是关闭的）：

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
[ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];

// TDLoggingLevelError :Error Log

// TDLoggingLevelInfo  :Info  Log

// TDLoggingLevelDebug :Debug Log
```

:::

::: el-tab-pane label=Swift

```Swift
ThinkingAnalyticsSDK.setLogLevel(TDLoggingLevel.debug)

// TDLoggingLevel.error :Error Log

// TDLoggingLevel.info  :Info  Log

// TDLoggingLevel.debug :Debug Log
```

:::

::::



### 6.4 获取设备 ID

在 v2.0.0 版本，加入了获取设备 ID（也就是预置属性`#device_id`）的接口，您可以通过调用 `getDeviceId` 来获取设备 ID：

```Objective-C
[instance getDeviceId];



 // 如果需要将设备ID设置成访客ID可以如下调用

 // [instance identify:[instance getDeviceId]];
```

### 6.5 配置 HTTPS 校验方法:

从 v2.3.0 版本开始，SDK 可以配置 HTTPS 校验方法，需要在初始化的时候首先获取 TDConfig 实例，然后用 TDConfig 完成初始化。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
 TDConfig *config = [[TDConfig alloc] init];

 TDSecurityPolicy *securityPolicy = [TDSecurityPolicy policyWithPinningMode:TDSSLPinningModeNone];

 // TDSSLPinningModeNone:默认认证方式，只会在系统的信任的证书列表中对服务端返回的证书进行验证

 // TDSSLPinningModePublicKey:校验证书的公钥

 // TDSSLPinningModeCertificate:校验证书的所有内容

 securityPolicy.allowInvalidCertificates = YES; // 是否允许自建证书或者过期SSL证书，默认NO

 securityPolicy.validatesDomainName = NO; // 是否验证证书域名，默认YES

 config.securityPolicy = securityPolicy;

 [ThinkingAnalyticsSDK startWithAppId:@"YOUR_APPID" withUrl:@"YOUR_SERVER_URL" withConfig:config];
```

:::

::: el-tab-pane label=Swift

```Swift
let tdconfig = TDConfig();

let tdSecurityPolicy = TDSecurityPolicy(pinningMode: TDSSLPinningMode.publicKey);

// TDSSLPinningMode [] 默认认证方式，只会在系统的信任的证书列表中对服务端返回的证书进行验证

// TDSSLPinningMode.publicKey 校验证书的公钥

// TDSSLPinningMode.certificate 校验证书的所有内容

tdSecurityPolicy.allowInvalidCertificates = true // 是否允许自建证书或者过期SSL证书，默认NO

tdSecurityPolicy.validatesDomainName = false // 是否验证证书域名，默认YES

tdconfig.securityPolicy = tdSecurityPolicy;

ThinkingAnalyticsSDK.start(withAppId: "YOUR_APPID", withUrl: "YOUR_SERVER_URL", with: tdconfig);
```

:::

::::



### 6.6 设置默认时区

默认情况下，如果用户不指定事件发生时间，SDK 默认会使用接口调用时的本机时间作为事件发生时间上报。自 v2.3.1 版本开始，您也可以通过设置默认时区接口，指定默认的时区，这样所有的事件（包括自动采集事件）都将按照您设置的时区来对齐事件时间：

```Objective-C
// 获取 TDConfig 实例

TDConfig *config = [[TDConfig alloc] init];

// 设置默认时区为 UTC

config.defaultTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];

// 初始化 SDK

ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithAppId:@"YOUR_APPID" withUrl:@"YOUR_SERVER_URL" withConfig:config];
```

> 注意：用指定时区对齐事件时间，会丢掉设备本机时区信息。如果需要保留设备本机时区信息，目前需要您自己为事件添加相关属性。

### 6.7 开启 Debug 模式

从 v2.4.0 版本开始，客户端 SDK 支持 Debug 模式，需要配合 TA 平台 2.5 之后的版本使用。

Debug 模式可能会影响数据采集质量和 App 的稳定性，只用于集成阶段数据验证，不要在线上环境使用。

当前 SDK 实例支持三种运行模式，在 `TDConfig` 中定义：

```Objective-C
/**

Debug模式



- ThinkingAnalyticsDebugOff : 默认 不开启Debug模式

*/

typedef NS_OPTIONS(NSInteger, ThinkingAnalyticsDebugMode) {

    /**

     默认 不开启Debug模式

     */

    ThinkingAnalyticsDebugOff      = 0,



    /**

     开启Debug_only模式，只对数据做校验，不会入库

     */

    ThinkingAnalyticsDebugOnly     = 1 << 0,



    /**

     Debug 模式，数据逐条上报。当出现问题时会以日志和异常的方式提示用户

     */

    ThinkingAnalyticsDebug         = 1 << 1

};
```

为了设置 SDK 实例运行模式，请使用 `TDConfig` 来完成 SDK 初始化：

```Plain%20Text
// 获取 TDConfig 实例

TDConfig *config = [[TDConfig alloc] init];

// 设置运行模式为 Debug 模式

config.debugMode = ThinkingAnalyticsDebug;

// 初始化 SDK

ThinkingAnalyticsSDK *instance = [ThinkingAnalyticsSDK startWithAppId:@"YOUR_APPID" withUrl:@"YOUR_SERVER_URL" withConfig:config];
```

为了避免 Debug 模式在生产环境上线，规定只有指定的设备才能开启 Debug 模式。只有在客户端开启了 Debug 模式，并且设备 ID 在 TA 后台的"埋点管理"页的"Debug 数据"板块中配置了的设备才能开启 Debug 模式。

![img](https://thinkingdata.feishu.cn/space/api/box/stream/download/asynccode/?code=MTk2MGUxYzdlYjc1NGQ4NDkxMDRjYWUzZWFjYTc3YzNfcTVPeExjenVTMU5vRWVsc1FqQUd2WTJqaUNEdk5lajBfVG9rZW46Ym94Y24xZ3ZOcnp4MnUwWEhRQzBYaGVUcTNjXzE2NTUxNzE0OTM6MTY1NTE3NTA5M19WNA)

设备 ID 可以通过以下三种方式获取：

- TA 平台中事件数据中的 #device_id 属性
- 客户端日志：SDK 初始化完成后会打印设备 DeviceId
- 通过实例接口调用：[获取设备 ID](https://thinkingdata.feishu.cn/wiki/wikcnEZ7EnmOnSq6Q4qPntLVASg#jWxmJw)



### 6.8 校准时间

SDK 默认会使用本机时间作为事件发生时间上报，如果用户手动修改设备时间会影响到您的业务分析，自 v2.5.0 版本开始，您可以使用从服务端获取的当前时间戳对 SDK 的时间进行校准。此后，所有为指定时间的调用，包括事件数据和用户属性设置操作，都会使用校准后的时间作为发生时间。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 1585633785954 为当前 unix 时间戳，单位为毫秒，对应北京时间 2020-03-31 13:49:45

[ThinkingAnalyticsSDK calibrateTime:1585633785954];
```

:::

::: el-tab-pane label=Swift

```Swift
// 1585633785954 为当前 unix 时间戳，单位为毫秒，对应北京时间 2020-03-31 13:49:45

ThinkingAnalyticsSDK.calibrateTime(1585633785954)
```

:::

::::

我们也提供了从 NTP 获取时间对 SDK 校准的功能。您需要传入您的用户可以访问的 NTP 服务器地址。之后 SDK 会尝试从传入的 NTP 服务地址中获取当前时间，并对 SDK 时间进行校准。如果在默认的超时时间（3 秒）之内，未获取正确的返回结果，后续将使用本地时间上报数据。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 使用苹果公司 NTP 服务对时间进行校准

[ThinkingAnalyticsSDK calibrateTimeWithNtp:@"time.apple.com"];
```

:::

::: el-tab-pane label=Swift

```Swift
ThinkingAnalyticsSDK.calibrateTime(withNtp: "time.apple.com")
```

:::

::::

**注意：**

- 您需要谨慎地选择您的 NTP 服务器地址，以保证网络状况良好的情况下，用户设备可以很快的获取到服务器时间。
- 使用 NTP 服务进行时间校准存在一定的不确定性，建议您优先考虑用时间戳校准的方式。

除了以上校准时间接口外，在 v2.5.0 提供了所有用户属性接口的时间函数重载，您可以在调用用户属性相关接口时，传入 Date 对象，则系统会使用传入的 Date 对象来设定数据的 `#time` 字段。

## 七、相关预置属性

### 7.1 所有事件带有的预置属性

以下预置属性，是 iOS SDK 中所有事件（包括自动采集事件）都会带有的预置属性

| **属性名**       | **中文名**       | **说明**                                                     |
| ---------------- | ---------------- | ------------------------------------------------------------ |
| #ip              | IP 地址          | 用户的 IP 地址，TA 将以此获取用户的地理位置信息              |
| #country         | 国家             | 用户所在国家，根据 IP 地址生成                               |
| #country_code    | 国家代码         | 用户所在国家的国家代码(ISO 3166-1 alpha-2，即两位大写英文字母)，根据 IP 地址生成 |
| #province        | 省份             | 用户所在省份，根据 IP 地址生成                               |
| #city            | 城市             | 用户所在城市，根据 IP 地址生成                               |
| #os_version      | 操作系统版本     | iOS 11.2.2、Android 8.0.0 等                                 |
| #manufacturer    | 设备制造商       | 用户设备的制造商，如 Apple，vivo 等                          |
| #os              | 操作系统         | 如 Android、iOS 等                                           |
| #device_id       | 设备 ID          | 用户的设备 ID，iOS 取用户的 IDFV 或 UUID，Android 取 androidID |
| #screen_height   | 屏幕高度         | 用户设备的屏幕高度，如 1920 等                               |
| #screen_width    | 屏幕宽度         | 用户设备的屏幕高度，如 1080 等                               |
| #device_model    | 设备型号         | 用户设备的型号，如 iPhone 8 等                               |
| #app_version     | APP 版本         | 您的 APP 的版本                                              |
| #bundle_id       | 应用唯一标识     | 应用包名或进程名                                             |
| #lib             | SDK 类型         | 您接入 SDK 的类型，如 Android，iOS 等                        |
| #lib_version     | SDK 版本         | 您接入 SDK 的版本                                            |
| #network_type    | 网络状态         | 上传事件时的网络状态，如 WIFI、3G、4G 等                     |
| #carrier         | 网络运营商       | 用户设备的网络运营商，如中国移动，中国电信等                 |
| #zone_offset     | 时区偏移         | 数据时间相对 UTC 时间的偏移小时数                            |
| #install_time    | 程序安装时间     | 用户安装应用的时间，值来源于系统                             |
| #simulator       | 是/否为模拟器    | 设备是否是模拟器 true/false                                  |
| #ram             | 设备运行内存状态 | 用户设备的当前剩余内存和总内存，单位GB，如 1.4/2.4           |
| #disk            | 设备存储空间状态 | 用户设备的当前剩余存储空间和总存储空间，单位GB，如 30/200    |
| #fps             | 设备FPS          | 用户设备的当前图像每秒传输帧率，如 60                        |
| #system_language | 系统语言         | 用户设备的系统语言(ISO 639-1，即两位小写英文字母)，如 zh, en 等 |

### 7.2 自动采集事件的预置属性

以下预置属性，是各个自动采集事件中所特有的预置属性

- APP 启动事件（ta_app_start）的预置属性

| **属性名**              | **中文名**     | **说明**                                                     |
| ----------------------- | -------------- | ------------------------------------------------------------ |
| #resume_from_background | 是否从后台唤醒 | 表示 APP 是被开启还是从后台唤醒，取值为 true 表示从后台唤醒，false 为直接开启 |
| #start_reason           | 应用启动来源   | 内容为JSON字符串；应用使用url或者intent方式打开APP时，自动记录url内容以及intent中的data数据，数据样例参考{url:"thinkingdata://","data":{}} |
| #backgroud_duration     | 后台停留时长   | 记录两次start事件发生区间内，应用在后台的停留时长，单位是秒  |

- APP 关闭事件（ta_app_end）的预置属性

| **属性名** | **中文名** | **说明**                                          |
| ---------- | ---------- | ------------------------------------------------- |
| #duration  | 事件时长   | 表示该次 APP 访问（自启动至结束）的时长，单位是秒 |

- APP 浏览页面事件（ta_app_view）的预置属性

| **属性名**   | **中文名** | **说明**                                                     |
| ------------ | ---------- | ------------------------------------------------------------ |
| #title       | 页面标题   | 为 View Controller 的标题，取值为`controller.navigationItem.title`属性的值 |
| #screen_name | 页面名称   | 为 View Controller 的类名                                    |
| #url         | 页面地址   | 当前页面的地址，需要调用`getScreenUrl`进行 url 的设置        |
| #referrer    | 前向地址   | 跳转前页面的地址，跳转前页面需要调用`getScreenUrl`进行 url 的设置 |

- APP 控件点击事件（ta_app_click）的预置属性

| **属性名**        | **中文名** | **说明**                                                     |
| ----------------- | ---------- | ------------------------------------------------------------ |
| #title            | 页面标题   | 为 View Controller 的标题，取值为`controller.navigationItem.title`属性的值 |
| #screen_name      | 页面名称   | 为 View Controller 的类名                                    |
| #element_id       | 元素 ID    | 控件的 ID，需要`thinkingAnalyticsViewID`进行设置             |
| #element_type     | 元素类型   | 控件的类型                                                   |
| #element_selector | 元素选择器 | 为控件的`viewPath`的拼接                                     |
| #element_position | 元素位置   | 控件的位置信息，只有当控件类型为`UITableView`或`UICollectionView`才会存在，表示控件被点击的位置，取值为`组号(Section):行号(Row)` |
| #element_content  | 元素内容   | 控件上的内容                                                 |

- APP 崩溃事件（ta_app_crash）的预置属性

| **属性名**          | **中文名** | **说明**                     |
| ------------------- | ---------- | ---------------------------- |
| #app_crashed_reason | 异常信息   | 字符型，记录崩溃时的堆栈轨迹 |

### 7.3 其他预置属性

除了上述提到预置属性，还有部分预置属性需要调用对应接口才会被记录：

| **属性名**           | **中文名**   | **说明**                                                     |
| -------------------- | ------------ | ------------------------------------------------------------ |
| #duration            | 事件时长     | 需要调用计时功能接口`timeEvent:`，记录事件发生时长，单位是秒 |
| #background_duration | 后台停留时长 | 需要调用计时功能接口`timeEvent`，记录事件发生区间内，应用在后台的停留时长，单位是秒 |

### 7.4 获取预置属性

v2.7.0 及以后的版本可以调用 `getPresetProperties` 方法获取预置属性。

服务端埋点需要 App 端的一些预置属性时，可以通过此方法获取 App 端的预置属性，再传给服务端。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
//获取属性对象

TDPresetProperties *presetProperties = [instance getPresetProperties];



//生成事件预置属性

NSDictionary *properties = [presetProperties toEventPresetProperties];

/*

   {

	"#carrier": "中国电信",

	"#os": "iOS",

	"#device_id": "A8B1C00B-A6AC-4856-8538-0FBC642C1BAD",

	"#screen_height": 2264,

	"#bundle_id": "com.sw.thinkingdatademo",

	"#manufacturer": "Apple",

	"#device_model": "iPhone7",

	"#screen_width": 1080,

	"#system_language": "zh",

	"#os_version": "10",

	"#network_type": "WIFI",

	"#zone_offset": 8,

        "#app_version":"1.0.0"

    }

*/



//获取某个预置属性

NSString *bundle_id = presetProperties.bundle_id;//包名

NSString *os = presetProperties.os;//os类型，如iOS

NSString *system_language = presetProperties.system_language;//手机系统语言类型

NSNumber *screen_width = presetProperties.screen_width;//屏幕宽度

NSNumber *screen_height = presetProperties.screen_height;//屏幕高度

NSString *device_model = presetProperties.device_model;//设备型号

NSString *device_id = presetProperties.device_id;//设备唯一标识

NSString *carrier = presetProperties.carrier;//手机SIM卡运营商信息，双卡双待时，取主卡的运营商信息

NSString *manufacture = presetProperties.manufacturer;//手机制造商 如Apple

NSString *network_type = presetProperties.network_type;//网络类型

NSString *os_version = presetProperties.os_version;//系统版本号

NSNumber *zone_offset = presetProperties.zone_offset;//时区偏移

NSString *app_version = presetProperties.app_version;//app版本号
```

:::

::: el-tab-pane label=Swift

```Swift
let presetProperties = instance.getPresetProperties();



//生成事件预置属性

let properties = presetProperties.toEventPresetProperties();



//获取某个预置属性

let bundle_id = presetProperties.bundle_id;//包名

let os = presetProperties.os;//os类型，如iOS

let system_language = presetProperties.system_language;//手机系统语言类型

let screen_width = presetProperties.screen_width;//屏幕宽度

let screen_height = presetProperties.screen_height;//屏幕高度

let device_model = presetProperties.device_model;//设备型号

let device_id = presetProperties.device_id;//设备唯一标识

let carrier = presetProperties.carrier;//手机SIM卡运营商信息，双卡双待时，取主卡的运营商信息

let manufacture = presetProperties.manufacturer;//手机制造商 如Apple

let network_type = presetProperties.network_type;//网络类型

let os_version = presetProperties.os_version;//系统版本号

let zone_offset = presetProperties.zone_offset;//时区偏移值

let app_version = presetProperties.app_version;//app版本号
```

:::

::::

> IP，国家城市信息由服务端解析生成，客户端不提供接口获取这些属性

### 7.6 预制属性开关

从 v2.7.4 开始， SDK 支持屏蔽指定预制属性的上报。

在工程的info.plist文件中添加**TDDisPresetProperties**字段，类型是Array，添加的字段对应的预置属性将不会上传。

如屏蔽"#fps", @"#ram", @"#disk", @"#start_reason", @"#simulator"等预制属性，配置如下图：

![img](https://thinkingdata.feishu.cn/space/api/box/stream/download/asynccode/?code=NzI2MDQ1OTVmNzY5YzA1NjM4N2JkMDgxYmMwYjVlMjRfSlBjZDNjM2h2YWR6c0d1OEpwMWtoR0NWeDdCYzNJZzhfVG9rZW46Ym94Y25hUlhkbndxQUlLRFV2cUF6aW9PeldUXzE2NTUxNzE0OTM6MTY1NTE3NTA5M19WNA)

## 八、进阶功能

从 v2.6.0 开始，SDK 支持上报三种特殊类型事件: 首次事件、可更新事件、可重写事件。这三种事件需要配合 TA 系统 2.8 及之后的版本使用。由于特殊事件只在某些特定场景下适用，所以请在数数科技的客户成功和分析师的帮助下使用特殊事件上报数据。

### 8.1 首次事件

首次事件是指针对某个设备或者其他维度的 ID，只会记录一次的事件。例如在一些场景下，您可能希望记录在某个设备上第一次发生的事件，则可以用首次事件来上报数据。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 示例：上报设备首次事件, 假设事件名为 DEVICE_FIRST

TDFirstEventModel *firstModel = [[TDFirstEventModel alloc] initWithEventName:@"DEVICE_FIRST"];



// 可选参数

firstModel.properties = @{};

[firstModel configTime:[NSDate date] timeZone:[NSTimeZone localTimeZone]];



// 上报事件API

[[ThinkingAnalyticsSDK sharedInstance] trackWithEventModel:firstModel];
```

:::

::: el-tab-pane label=Swift

```Swift
// 示例：上报设备首次事件, 假设事件名为 DEVICE_FIRST

let firstModel = TDFirstEventModel(eventName:"DEVICE_FIRST")

// 可选参数

firstModel.properties = ["KEY": "VALUE"]

firstModel.configTime(Date(), timeZone: NSTimeZone.local)

// 上报事件API

ThinkingAnalyticsSDK.sharedInstance()?.track(with: firstModel)
```

:::

::::

如果您希望以设备以外的其他维度来判断是否首次，则可以为首次事件设置 FIRST_CHECK_ID. 例如您需要记录某个账号的首次事件，可以将账号 ID 设置为首次事件的 FIRST_CHECK_ID:

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 自定义#first_check_id的构造方法

TDFirstEventModel *firstModel = [[TDFirstEventModel alloc] initWithEventName:@"DEVICE_FIRST" firstCheckID:@"YOUR_ACCOUNT_ID"];



// 可选参数

firstModel.properties = @{};

[firstModel configTime:[NSDate date] timeZone:[NSTimeZone localTimeZone]];



// 上报事件API

[[ThinkingAnalyticsSDK sharedInstance] trackWithEventModel:firstModel];
```

:::

::: el-tab-pane label=Swift

```Swift
// 示例：上报设备首次事件, 假设事件名为 DEVICE_FIRST

let firstModel = TDFirstEventModel(eventName:"DEVICE_FIRST", firstCheckID:"YOUR_ACCOUNT_ID")

// 可选参数

firstModel.properties = ["KEY": "VALUE"]

firstModel.configTime(Date(), timeZone: NSTimeZone.local)

// 上报事件API

ThinkingAnalyticsSDK.sharedInstance()?.track(with: firstModel)
```

:::

::::

> 注意：由于在服务端完成对是否首次的校验，首次事件会延时 1 小时入库。

### 8.2 可更新事件

您可以通过可更新事件实现特定场景下需要修改事件数据的需求。可更新事件需要指定标识该事件的 ID，并在创建可更新事件对象时传入。TA 后台将根据事件名和事件 ID 来确定需要更新的数据。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 示例： 上报可被更新的事件，假设事件名为 UPDATABLE_EVENT

TDUpdateEventModel *updateModel = [[TDUpdateEventModel alloc] initWithEventName:@"UPDATABLE_EVENT" eventID:@"test_event_id"];

updateModel.properties = @{@"status": @3, @"price": @100};

// 上报后事件属性 status 为 3, price 为 100

[[ThinkingAnalyticsSDK sharedInstance] trackWithEventModel:updateModel];



TDUpdateEventModel *updateModel_new = [[TDUpdateEventModel alloc] initWithEventName:@"UPDATABLE_EVENT" eventID:@"test_event_id"];

updateModel_new.properties = @{@"status": @5};

// 上报后事件属性 status 被更新为 5, price 不变

[[ThinkingAnalyticsSDK sharedInstance] trackWithEventModel:updateModel_new];
```

:::

::: el-tab-pane label=Swift

```Swift
// 示例： 上报可被更新的事件，假设事件名为 UPDATABLE_EVENT

let updateModel = TDUpdateEventModel(eventName: "UPDATABLE_EVENT", eventID: "test_event_id")

updateModel.properties = ["status": 3, "price": 100]



// 可选参数

updateModel.configTime(<#T##time: Date##Date#>, timeZone: <#T##TimeZone?#>)



// 上报后事件属性 status 为 3, price 为 100

ThinkingAnalyticsSDK.sharedInstance()?.track(with: updateModel)





let updateModel_new =TDUpdateEventModel(eventName: "UPDATABLE_EVENT", eventID: "test_event_id")

updateModel_new.properties = ["status": 5]

// 上报后事件属性 status 为 5, price 不变

ThinkingAnalyticsSDK.sharedInstance()?.track(with: updateModel_new)
```

:::

::::

### 8.3 可重写事件

可重写事件与可更新事件类似，区别在于可重写事件会用最新的数据完全覆盖历史数据，从效果上看相当于删除前一条数据，并入库最新的数据。TA 后台将根据事件名和事件 ID 来确定需要更新的数据。

:::: el-tabs

::: el-tab-pane label=Objective-C

```Objective-C
// 示例： 上报可被重写的事件，假设事件名为 OVERWRITE_EVENT

TDOverwriteEventModel *overwriteModel = [[TDOverwriteEventModel alloc] initWithEventName:@"OVERWRITE_EVENT" eventID:@"test_event_id"];

overwriteModel.properties = @{@"status": @3, @"price": @100};

// 上报后事件属性 status 为 3, price 为 100

[[ThinkingAnalyticsSDK sharedInstance] trackWithEventModel:overwriteModel];



TDOverwriteEventModel *overwriteModel_new = [[TDOverwriteEventModel alloc] initWithEventName:@"OVERWRITE_EVENT" eventID:@"test_event_id"];

overwriteModel_new.properties = @{@"status": @5};

// 上报后事件属性 status 为 5, price属性被删除

[[ThinkingAnalyticsSDK sharedInstance] trackWithEventModel:overwriteModel_new];
```

:::

::: el-tab-pane label=Swift

```Swift
// 示例： 上报可被重写的事件，假设事件名为 OVERWRITE_EVENT

let overwriteModel = TDOverwriteEventModel(eventName: "OVERWRITE_EVENT", eventID: "test_event_id")

overwriteModel.properties = ["status": 3, "price": 100]



// 可选参数

overwriteModel.configTime(<#T##time: Date##Date#>, timeZone: <#T##TimeZone?#>)



// 上报后事件属性 status 为 3, price 为 100

ThinkingAnalyticsSDK.sharedInstance()?.track(with: overwriteModel)





let overwriteModel_new = TDOverwriteEventModel(eventName: "UPDATABLE_EVENT", eventID: "test_event_id")

overwriteModel_new.properties = ["status": 5]

// 上报后事件属性 status 为 5, price 被删除

ThinkingAnalyticsSDK.sharedInstance()?.track(with: overwriteModel_new)
```

:::

::::

## 九、加密功能

从 v2.8.0 版本开始，SDK 支持加密功能，客户端支持AES+RSA对数据进行加密，再由服务端对数据进行解密，加解密能力需要客户端和服务端配合完成，具体请咨询客户成功人员。

分别设置`TDConfig`对象的`enableEncrypt`属性为`YES`，设置`secretKey`属性为`TDSecretKey`自定义对象。

> `TDSecretKey` 配置了版本号、公钥等密钥信息

```Objective-C
[ThinkingAnalyticsSDK setLogLevel:TDLoggingLevelDebug];

NSString *appid = @"APPIDXXX";

NSString *url = @"https://XXXX";

TDConfig *config = [TDConfig new];

config.appid = appid;

config.configureURL = url;

// 开启加密功能

config.enableEncrypt = YES; 

// 配置版本号、公钥等密钥信息

config.secretKey = [[TDSecretKey alloc] initWithVersion:1 publicKey:@"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCzAKEGsq67Yd03/RF77VKJ/cQ3\nzfSboK1wzlQfH2E1fr504WCJHHL/UVgjfUGUjMLIN15FNEelp7TXLToqtYlqqMbE\nXCfSc14ulRatKQioYnJ8EzgUhG0HcRlulni6vxGJHR9iq4weDNyJFRaZuwIQSrUz\nIaiVq/3hYijxxhhFqQIDAQAB"];

[ThinkingAnalyticsSDK startWithConfig:config];

[[ThinkingAnalyticsSDK sharedInstance] login:@"login1"];

[[ThinkingAnalyticsSDK sharedInstance] track:@"secret_event" properties:@{@"a":@"asadas",@"b":@"djGNVWOzMC/4D2v/JGN.EsH3uP2stjoZ=+/", @"wangdaji":@"王大吉"}];

[[ThinkingAnalyticsSDK sharedInstance] user_uniqAppend:@{@"abc":@[@"aaa",@"bbb",@"ccc"]}];

[[ThinkingAnalyticsSDK sharedInstance] flush];
```
