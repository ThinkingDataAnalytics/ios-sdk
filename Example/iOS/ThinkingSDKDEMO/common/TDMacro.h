//
//  TDMacro.h
//  ThinkingSDKDEMO
//
//  Created by LiHuanan on 2020/7/22.
//  Copyright © 2020 thinking. All rights reserved.
//
#import "TDUtil.h"
#ifndef TDMacro_h
#define TDMacro_h
#define kTDScreenWidth [UIScreen mainScreen].bounds.size.width
#define kTDScreenHeight [UIScreen mainScreen].bounds.size.height
#define kTDPositionX(w) ((kTDScreenWidth-w)/2.0)
#define kTDPositionY(h) ((kTDScreenHeight-h)/2.0)
#define kTDSize(size)   (TDUtil.screenPer*size)
#define kTDColor    ([UIColor whiteColor])
#define kTDColor1   ([UIColor blackColor])
#define kTDColor2   ([UIColor grayColor])
#define kTDColor3   ([UIColor colorWithRed:120./255. green:120./255. blue:120./255. alpha:1.])
#define kTDFontSize 15
#define kTDCornor   5
#define kTDBorder   1
#define kTDCommonH  (TDUtil.screenPer*45)
#define kTDCommonW  (TDUtil.screenPer*250)
#define kTDIsiPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kTDIsiPhoneX kTDScreenWidth >=375.0f && kTDScreenHeight >=812.0f&& kTDIsiPhone
#define kTDLeftPadding 20
#define kTDCommonPadding 15
#define kTDCommonMargin  35
#define kTDY(y)  (y+kTDNavBarAndStatusBarHeight)

 

#define kTDStatusBarHeight (CGFloat)(kTDIsiPhoneX?(44.0):(20.0))

#define kTDNavBarHeight (44)

#define kTDNavBarAndStatusBarHeight (CGFloat)(kTDIsiPhoneX?(88.0):(64.0))

#define kTDTabBarHeight (CGFloat)(kTDIsiPhoneX?(49.0 + 34.0):(49.0))

#define kTDTopBarSafeHeight (CGFloat)(kTDIsiPhoneX?(44.0):(0))

#define kTDBottomSafeHeight (CGFloat)(kTDIsiPhoneX?(34.0):(0))

#define kTDTopBarDifHeight (CGFloat)(kTDIsiPhoneX?(24.0):(0))

#define kTDNavAndTabHeight (kNavBarAndStatusBarHeight + kTabBarHeight)




typedef void (^TDCallBack)(void);



#endif /* TDMacro_h */
