#import "TDSwiftUIVerifyViewController.h"

#import "TDSwiftUIScreenFactory.h"
#import <ThinkingSDK/UIViewController+TDScreenName.h>

@interface TDSwiftUIVerifyViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong, nullable) UIViewController *hostingController;

@end

@implementation TDSwiftUIVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"SwiftUI Screen Verify";

    [self setupDebugPanel];
    [self embedSwiftUIHostingController];
}

- (void)setupDebugPanel {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];

    self.stackView = [[UIStackView alloc] init];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.spacing = 12;
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.stackView];

    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:guide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.heightAnchor constraintEqualToConstant:220],

        [self.stackView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:16],
        [self.stackView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:16],
        [self.stackView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-16],
        [self.stackView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-16],
        [self.stackView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-32],
    ]];
}

- (void)embedSwiftUIHostingController {
    UIViewController *hostingController = [TDSwiftUIScreenFactory makeVastRendererHostingController];
    self.hostingController = hostingController;

    NSString *rawClassName = NSStringFromClass([hostingController class]);
    NSString *resolvedScreenName = [UIViewController td_screenNameForViewController:hostingController];
    NSString *swiftViewName = [TDSwiftUIScreenFactory swiftRootViewName];

    [self addInfoLabelWithTitle:@"Raw NSStringFromClass"
                           value:rawClassName];
    [self addInfoLabelWithTitle:@"SDK td_screenName"
                           value:resolvedScreenName];
    [self addInfoLabelWithTitle:@"Swift root view"
                           value:swiftViewName];
    [self addInfoLabelWithTitle:@"Expected #screen_name"
                           value:@"TDDemoVastRendererView"];
    [self addInfoLabelWithTitle:@"Verify result"
                           value:[resolvedScreenName isEqualToString:@"TDDemoVastRendererView"] ? @"PASS" : @"FAIL"];

    NSLog(@"[SwiftUI Verify] raw=%@", rawClassName);
    NSLog(@"[SwiftUI Verify] resolved=%@", resolvedScreenName);
    NSLog(@"[SwiftUI Verify] swiftView=%@", swiftViewName);

    [self addChildViewController:hostingController];
    hostingController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hostingController.view];

    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [hostingController.view.topAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:8],
        [hostingController.view.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
        [hostingController.view.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
        [hostingController.view.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor],
    ]];
    [hostingController didMoveToParentViewController:self];
}

- (void)addInfoLabelWithTitle:(NSString *)title value:(NSString *)value {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:13];
    titleLabel.textColor = UIColor.darkGrayColor;
    titleLabel.text = title;

    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.font = [UIFont systemFontOfSize:12];
    valueLabel.textColor = UIColor.blackColor;
    valueLabel.numberOfLines = 0;
    valueLabel.text = value;

    [self.stackView addArrangedSubview:titleLabel];
    [self.stackView addArrangedSubview:valueLabel];
}

@end
