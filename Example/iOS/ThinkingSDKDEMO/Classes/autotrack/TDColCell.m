//
//  TDColCell.m
//  ThinkingSDKDEMO
//
//  Created by LiHuanan on 2020/9/21.
//  Copyright © 2020 thinking. All rights reserved.
//

#import "TDColCell.h"
#import "TDMacro.h"
#import "UIColor+TDUtil.h"

@implementation TDColCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setUpCell];
    }
    return self;
}
- (void)setUpCell
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = UIColor.tc9;
    label.textAlignment = NSTextAlignmentCenter;
    _titleLabel = label;
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.contentView addSubview:label];
    label.backgroundColor = [UIColor whiteColor];
    label.layer.masksToBounds = true;
    label.layer.cornerRadius = kTDCornor;
    
    CGFloat itemW = 65;
    CGFloat itemH = 65;
    CGFloat itemX = (self.frame.size.width - itemW) * 0.5;
    CGFloat itemY = (self.frame.size.height - itemH) * 0.5;
    
    label.frame = CGRectMake(itemX, itemY, itemW, itemH);
    
    self.backgroundColor = UIColor.mainColor;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}
@end
