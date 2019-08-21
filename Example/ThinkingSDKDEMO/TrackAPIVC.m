//
//  TrackAPIVC.m
//  ThinkingSDKDEMO
//
//  Created by syj on 2019/6/24.
//  Copyright © 2019年 thinking. All rights reserved.
//

#import "TrackAPIVC.h"
#import "APIEntry.h"

@interface TrackAPIVC ()

@property(nonatomic,readwrite,retain) NSMutableArray* apis;

@end

@implementation TrackAPIVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    if ((self = [super initWithStyle:style]))
    {
        self.apis = [NSMutableArray array];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadTitle];
}

- (void)reloadTitle
{
    if (self.getTitleBlock != nil)
    {
        self.title = self.getTitleBlock(self);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(__unused UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(__unused UITableView*)tableView numberOfRowsInSection:(__unused NSInteger)section
{
    return (NSInteger)[self.apis count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    APIEntry* command = [self.apis objectAtIndex:(NSUInteger)indexPath.row];
    cell.textLabel.text = command.name;
    cell.accessoryType = command.accessoryType;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [[self.apis objectAtIndex:(NSUInteger)indexPath.row] executeWithViewController:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
