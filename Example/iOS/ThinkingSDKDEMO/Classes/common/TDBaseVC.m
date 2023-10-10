//
//  TDSDKDemoBaseVC.m
//  ThinkingSDKDEMO
//
//  Created by LiHuanan on 2020/9/7.
//  Copyright © 2020 thinking. All rights reserved.
//

#import "TDBaseVC.h"
#import "UIColor+TDUtil.h"

@interface TDBaseVC ()

@end

@implementation TDBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.mainColor;
    // Do any additional setup after loading the view.
    [self setData];
    [self setView];
}
- (void)setData
{
    
}
- (void)setView
{
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0., 0., 200, 60.}];
    UIImageView *logoImageView = [UIImageView new];
    logoImageView.frame = (CGRect){
        (200-414*(30./114.))/2,
        0.,
        414*(30./114.),
        30.
    };
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.image = [UIImage imageNamed:@"logo"];
    [headerView addSubview:logoImageView];
    self.navigationItem.titleView = headerView;
    
    UILabel *rightLabel = [UILabel new];
    rightLabel.text = [self rightTitle];
    rightLabel.textColor = [UIColor whiteColor];
//    rightLabel.frame = CGRectMake(0, 0, 100, 40);
    rightLabel.textAlignment = NSTextAlignmentRight;
    rightLabel.font = [UIFont systemFontOfSize:15];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightLabel];
}
- (NSString*)rightTitle
{
    if(_rightTitle != nil)
    {
        return _rightTitle;
    }
    return @"";
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:true];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)dealloc
{
    NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}
@end
