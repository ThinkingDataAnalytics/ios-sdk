//
//  TrackAPIViewController.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import "TrackAPIViewController.h"
#import "APIEntry.h"
#import "TDTrackAPIListCell.h"

static NSString *const kTrackAPIListCellID = @"kTrackAPIListCellID";

@interface TrackAPIViewController ()

@property (nonatomic, strong) NSMutableArray *apis;

@end

@implementation TrackAPIViewController


- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        self.apis = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)prepareUI {
    
    self.view.backgroundColor = UIColor.mainColor;
    [self prepareHeaderView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TDTrackAPIListCell class] forCellReuseIdentifier:kTrackAPIListCellID];
}

- (void)prepareHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0., 0., kTDScreenWidth, 200.}];
    
    UIImageView *logoImageView = [UIImageView new];
    logoImageView.frame = (CGRect){
        (kTDScreenWidth-414*(30./114.))/2,
        70.,
        414*(30./114.),
        30.
    };
    logoImageView.image = [UIImage imageNamed:@"logo"];
    [headerView addSubview:logoImageView];
    
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:(CGRect){0., 110., kTDScreenWidth, 40.}];
    headerLabel.text = @"ThinkingSDK DEMO";
    headerLabel.textColor = UIColor.whiteColor;
    headerLabel.font = [UIFont fontWithName:@"SpaceMono-Bold" size:30.];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:headerLabel];
    
    self.tableView.tableHeaderView = headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(__unused UITableView *)tableView {
    return self.apis.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.apis[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TDTrackAPIListCell *cell = [tableView dequeueReusableCellWithIdentifier:kTrackAPIListCellID];
    [cell configCellWithModel:self.apis[indexPath.section][indexPath.row]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.apis[indexPath.section][indexPath.row] executeWithViewController:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
