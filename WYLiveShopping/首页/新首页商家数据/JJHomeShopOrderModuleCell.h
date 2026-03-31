#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJHomeShopOrderModuleCell : UITableViewCell

@property (nonatomic, copy, nullable) void (^orderActionBlock)(void);

- (void)updateWithUnshippedCount:(NSString *)unshippedCount
                   receivedCount:(NSString *)receivedCount
                  evaluatedCount:(NSString *)evaluatedCount;

@end

NS_ASSUME_NONNULL_END
