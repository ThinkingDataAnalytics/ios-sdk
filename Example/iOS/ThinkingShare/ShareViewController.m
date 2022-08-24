//
//  ShareViewController.m
//  ThinkingShare
//
//  Created by 杨雄 on 2022/5/26.
//  Copyright © 2022 thinking. All rights reserved.
//

#import "ShareViewController.h"
#import <ThinkingSDK/TAAppExtensionAnalytic.h>

@interface ShareViewController ()
@property (nonatomic, strong) TAAppExtensionAnalytic *analytic;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [TAAppExtensionAnalytic calibrateTimeWithNtp:@"time.apple.com"];
    
    self.analytic = [TAAppExtensionAnalytic analyticWithInstanceName:@"123" appGroupId:@"group.cn.thinking.thinkingdata"];
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectCancel {
    NSLog(@"didSelectCancel");
    
    // [Example: thinking data]
    [self.analytic writeEvent:@"didSelectCancel" properties:nil];
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    NSLog(@"didSelectPost");
    
    // [Example: thinking data]
    [self.analytic writeEvent:@"didSelectPost" properties:nil];
    
    // [Example: thinking data]
    NSString *inputContent = self.contentText;
    if (inputContent.length) {
        [self.analytic writeEvent:@"didSelectPost_content" properties:@{@"share_name": inputContent}];
    }

    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    
    // [Example: thinking data]
    NSArray<NSString *> *titles = @[@"food", @"movie", @"sport"];
    NSMutableArray<SLComposeSheetConfigurationItem *> *items = [NSMutableArray array];
    for (NSString *title in titles) {
        SLComposeSheetConfigurationItem *item = [self generateItemWithTitle:title tapAction:^{
            NSLog(@"%@", title);
            [self.analytic writeEvent:title properties:@{}];
        }];
        [items addObject:item];
    }
    
    return items;
}

- (SLComposeSheetConfigurationItem *)generateItemWithTitle:(NSString *)title tapAction:(void(^)(void))tapAction {
    SLComposeSheetConfigurationItem *item = [[SLComposeSheetConfigurationItem alloc] init];
    item.title = title;
    item.tapHandler = tapAction;
    return item;
}

@end
