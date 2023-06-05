//
//  UIColor+TEHexColor.h
//  teviewtemplate
//
//  Created by Charles on 29.11.22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (TEHexColor)

+ (UIColor *)te_colorWithHexString:(nullable NSString *)hexString;

@end

NS_ASSUME_NONNULL_END
