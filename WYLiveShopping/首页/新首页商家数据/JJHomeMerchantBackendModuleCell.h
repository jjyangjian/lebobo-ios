#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJHomeMerchantBackendModuleCell : UITableViewCell

@property (nonatomic, copy, nullable) void (^merchantBackendActionBlock)(void);

- (void)updateWithMerchantURL:(NSString *)merchantURL;

@end

NS_ASSUME_NONNULL_END
