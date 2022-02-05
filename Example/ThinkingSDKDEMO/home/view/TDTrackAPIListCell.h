
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class APIEntry;

@interface TDTrackAPIListCell : UITableViewCell

- (void)configCellWithModel:(APIEntry *)model;

@end
 
NS_ASSUME_NONNULL_END
