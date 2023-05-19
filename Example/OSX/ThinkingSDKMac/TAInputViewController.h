//
//  TAInputViewController.h
//  ThinkingSDKMac
//
//  Created by Charles on 23.2.23.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAInputViewController : NSViewController

@property (unsafe_unretained) IBOutlet NSTextView *txtView;

@property (copy, nonatomic) void(^backText)(NSString *string);

@end

NS_ASSUME_NONNULL_END
