#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJHomeShopRevenueModuleCell : UITableViewCell

@property (nonatomic, copy, nullable) void (^revenueActionBlock)(void);

- (void)updateWithTodayRevenue:(NSString *)todayRevenue
                  totalRevenue:(NSString *)totalRevenue
               settledRevenue:(NSString *)settledRevenue
             unsettledRevenue:(NSString *)unsettledRevenue;

@end

NS_ASSUME_NONNULL_END
