//
//  AutoTableViewController.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/28.
//  Copyright © 2019 thinking. All rights reserved.
//

#import "AutoTableViewController.h"
#import <ThinkingSDK/ThinkingAnalyticsSDK.h>
#import "ActionModel.h"
@interface AutoTableViewController () <TDScreenAutoTracker>

//@property (nonatomic, strong) UITableView *table1;
//@property (nonatomic, strong) NSArray *data;

@end

@implementation AutoTableViewController

- (NSDictionary *)getTrackProperties {
    return @{@"auto_pageView_key1": @"name1"};;
}

//- (void)setView
//{
//    [super setView];
////    self.data = @[@"cell 1", @"cell 2"];
////    self.view.backgroundColor = [UIColor whiteColor];
////    self.table1 = [[UITableView alloc] initWithFrame:self.view.bounds];
////    self.table1.delegate = self;
////    self.table1.dataSource = self;
////    self.table1.thinkingAnalyticsViewID = @"testtableID1";
////    [self.view addSubview:self.table1];
////    self.table1.thinkingAnalyticsDelegate = self;
//}
- (void)setData
{
    self.commands = [NSMutableArray array];
    ActionModel *cell1Model =[[ActionModel alloc] initWithName:@"cell1" action:^{
   
    }];
    ActionModel *cell2Model = [[ActionModel alloc] initWithName:@"cell2" action:^{
        
    }];
    [self.commands addObject:cell1Model];
    [self.commands addObject:cell2Model];
}
- (NSString*)rightTitle
{
    return @"UITableView";
}
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.data.count;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
//    }
//
//    cell.textLabel.text = self.data[indexPath.row];
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"didSelectRowAtIndexPath:%@", indexPath);
//}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    self.table1.thinkingAnalyticsDelegate = nil;
}

@end
