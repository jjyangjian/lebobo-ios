

#import <UIKit/UIKit.h>
@class SWManagerModel;
@protocol SWAdminCellDelegate <NSObject>
- (void)delateAdminUser:(SWManagerModel *)model;
@end

@interface SWAdminCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIButton *iconBTN;

@property (weak, nonatomic) IBOutlet UILabel *nameL;

@property (weak, nonatomic) IBOutlet UILabel *signatureL;
@property (weak, nonatomic) IBOutlet UIImageView *sexL;

@property (weak, nonatomic) IBOutlet UIImageView *levelL;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@property(nonatomic,weak)id <SWAdminCellDelegate> delegate;


@property(nonatomic,strong)SWManagerModel *model;

+(SWAdminCell *)cellWithTableView:(UITableView *)tableView;

@end
