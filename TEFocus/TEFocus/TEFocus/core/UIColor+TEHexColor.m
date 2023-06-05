//
//  UIColor+TEHexColor.m
//  teviewtemplate
//
//  Created by Charles on 29.11.22.
//

#import "UIColor+TEHexColor.h"

@implementation UIColor (TEHexColor)

+ (UIColor *)te_colorWithHexString:(nullable NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self  te_colorComponentFrom: colorString start: 0 length: 1];
            green = [self  te_colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self  te_colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self  te_colorComponentFrom: colorString start: 0 length: 1];
            red   = [self  te_colorComponentFrom: colorString start: 1 length: 1];
            green = [self  te_colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self  te_colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self  te_colorComponentFrom: colorString start: 0 length: 2];
            green = [self  te_colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self  te_colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self  te_colorComponentFrom: colorString start: 0 length: 2];
            red   = [self  te_colorComponentFrom: colorString start: 2 length: 2];
            green = [self  te_colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self  te_colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            blue=0;
            green=0;
            red=0;
            alpha=0;
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

+(CGFloat) te_colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length
{
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}


@end
