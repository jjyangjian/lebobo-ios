
#import "SWAdminCell.h"
#import "SWManagerModel.h"

#import "SDWebImage/UIButton+WebCache.h"


@implementation SWAdminCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

-(void)setModel:(SWManagerModel *)model{
    
    _model = model;
    _nameL.text = _model.name;
    //头像
    [self.iconBTN sd_setBackgroundImageWithURL:[NSURL URLWithString:_model.icon] forState:UIControlStateNormal];
    
    self.iconBTN.layer.cornerRadius = 20;
    self.iconBTN.layer.masksToBounds = YES;
}
 
+(SWAdminCell *)cellWithTableView:(UITableView *)tableView{
    
    SWAdminCell *cell = [tableView dequeueReusableCellWithIdentifier:@"a"];
    
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"SWAdminCell" owner:self options:nil].lastObject;
    }
    return cell;
    
}
- (IBAction)delateBtnClick:(id)sender {
    [self.delegate delateAdminUser:_model];
}

@end
