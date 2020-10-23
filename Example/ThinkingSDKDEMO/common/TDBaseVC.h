//
//  TDSDKDemoBaseVC.h
//  ThinkingSDKDEMO
//
//  Created by LiHuanan on 2020/9/7.
//  Copyright © 2020 thinking. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol VCProtocol<NSObject>

@required
- (void)setView;
@optional
- (void)setData;
@end
NS_ASSUME_NONNULL_BEGIN

@interface TDBaseVC : UIViewController<VCProtocol>
@property(strong,nonatomic) NSString* rightTitle;
- (NSString*)rightTitle;
@end

NS_ASSUME_NONNULL_END
