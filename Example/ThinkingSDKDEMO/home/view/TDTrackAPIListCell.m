
#import "TDTrackAPIListCell.h"
#import "APIEntry.h"

@interface TDTrackAPIListCell ()

@property (nonatomic, weak) UIView *bgView;
@property (nonatomic, weak) UILabel *nameLabel;

@end

@implementation TDTrackAPIListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self prepareUI];
    }
    return self;
}

- (void)prepareUI {
    self.contentView.backgroundColor = UIColor.clearColor;
    self.backgroundColor = UIColor.clearColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView *bgView = [UIView new];
    bgView.layer.masksToBounds = YES;
    bgView.layer.cornerRadius = 6.;
    bgView.frame = (CGRect){ 12., 3., kTDScreenWidth - 24., 54. };
    bgView.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:bgView];
    self.bgView = bgView;
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12., 12., 0., 0.)];
    nameLabel.textColor = UIColor.tc9;
    [bgView addSubview:nameLabel];
    self.nameLabel = nameLabel;
}

#pragma mark -

- (void)configCellWithModel:(APIEntry *)model {
    self.nameLabel.text = model.name;
    [self.nameLabel sizeToFit];
    self.nameLabel.center = CGPointMake(self.nameLabel.center.x, self.bgView.bounds.size.height/2.);
}

@end
