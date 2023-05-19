//
//  ViewController.m
//  random_app
//
//  Created by Charles on 6.3.23.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor  whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setBackgroundColor:[UIColor redColor]];
    [button setFrame:CGRectMake(0, 50, 200, 50)];
    [button setTitle:@"点击我" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonTapped {
    NSLog(@"按钮被点击了");
}


@end
