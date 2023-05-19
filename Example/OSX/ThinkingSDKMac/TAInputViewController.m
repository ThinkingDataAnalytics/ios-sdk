//
//  TAInputViewController.m
//  ThinkingSDKMac
//
//  Created by Charles on 23.2.23.
//

#import "TAInputViewController.h"

@interface TAInputViewController ()

@end

@implementation TAInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)sure:(id)sender {
    
    NSString *txt = _txtView.string;
    NSLog(@"_backText: %@", txt);
    if (_backText) {
        _backText(txt);
    }
    [self dismissViewController:self];
}

@end
