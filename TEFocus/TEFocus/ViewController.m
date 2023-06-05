//
//  ViewController.m
//  teviewtemplate
//
//  Created by Charles on 25.11.22.
//

#import "ViewController.h"
//#import "TEFocus/core/TADisplayConfig.h"
//#import "TEFocus/core/ThinkingAnalyticsDisplayAPI.h"
#import <TEFocusSDK/TADisplayConfig.h>
#import <TEFocusSDK/ThinkingAnalyticsDisplayAPI.h>
//#import "ThinkingAnalyticsDisplayAPI.h"

@interface ViewController ()

@property(nonatomic, strong)ThinkingAnalyticsDisplayAPI *instance;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    TADisplayConfig *config = [[TADisplayConfig alloc] init];
    [config popupListener:^{
        NSLog(@"弹窗展示");
    } loadFailed:^(int code , NSString * errorMessage) {
        
    } click:^(ThinkingActionModel * model) {
        NSLog(@"%ld",model.type);
        NSLog(@"%@",model.value);
    } close:^{
        NSLog(@"弹窗消失");
    }];
    self.instance =  [ThinkingAnalyticsDisplayAPI startWithConfigOptions:config];
//    NSLog(@"%f",[UIScreen mainScreen].bounds.size.width);
//    NSLog(@"%f",[UIScreen mainScreen].bounds.size.height);
}

- (IBAction)showTemplate:(UIButton *)sender {
    if (sender.tag == 1) {
//        [self.instance showTemplateDialogWithFileName:@"ta_template_view_1"];
        [self.instance showTemplateDialogWithFileName:@"test1"];
    } else if (sender.tag == 2) {
        [self.instance showTemplateDialogWithFileName:@"ta_template_view_2"];
    } else if (sender.tag == 3) {
        [self.instance showTemplateDialogWithFileName:@"ta_template_view_3"];
    } else if (sender.tag == 4) {
        [self.instance showTemplateDialogWithFileName:@"ta_template_view_4"];
    }
}


@end
