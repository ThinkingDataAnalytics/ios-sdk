
#import "UIColor+TDUtil.h"

@implementation UIColor (TDUtil)

+ (UIColor *)mainColor {
    return [UIColor colorWithRed:84./255. green:116./255. blue:241./255. alpha:1.];;
}

+ (UIColor *)tc9 {
    return [UIColor colorWithHex:@"999999"];
}

#pragma mark - Private

+ (UIColor *)colorWithHex:(NSString*)hexStr {
    return [self colorWithHex:hexStr alpha:1.];
}

+ (UIColor *)colorWithHex:(NSString *)hexStr alpha:(CGFloat)alpha {
    NSInteger hex = hexStr.floatValue;
    CGFloat r = (CGFloat)((hex & 0xFF0000) >> 16) / 255.;
    CGFloat g = (CGFloat)((hex & 0xFF00) >> 8) / 255.0;
    CGFloat b = (CGFloat)((hex & 0xFF) ) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

@end
