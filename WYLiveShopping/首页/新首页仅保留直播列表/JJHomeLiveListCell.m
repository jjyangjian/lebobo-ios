//
//  JJHomeLiveListCell.m
//  testaaa
//
//  Created by 牛环环 on 2026/3/25.
//

#import "JJHomeLiveListCell.h"
#import <Masonry.h>
#import <SDWebImage.h>
@interface JJHomeLiveListCell()



@end
@implementation JJHomeLiveListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self configUI];
    }
    return self;
}

- (void)configUI{
    
    {
        UIImageView *imageView = UIImageView.new;
        [self.contentView addSubview:imageView];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(8);
                    make.left.mas_equalTo(16);
                    make.bottom.mas_equalTo(-8);
                    make.right.mas_equalTo(-16);
        }];
        
        imageView.layer.cornerRadius = 10;
        imageView.layer.masksToBounds = true;
        self.largeImageView = imageView;
//        imageView.backgroundColor = UIColor.yellowColor;
    }
    
    
    {
        UIImageView *imageView = UIImageView.new;
        [self.largeImageView addSubview:imageView];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(8);
                    make.bottom.mas_equalTo(-8);
            make.width.height.mas_equalTo(32);
        }];
        
        imageView.layer.cornerRadius = 16;
        imageView.layer.masksToBounds = true;
        self.avatarImageView = imageView;
        imageView.backgroundColor = UIColor.yellowColor;
    }

    
    {
        UILabel *label = UILabel.new;
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        label.text = @"标题";
        [self.largeImageView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(8);
                    make.bottom.equalTo(self.avatarImageView.mas_top).offset(-8);
        }];
        self.titleLabel = label;
        
    }
    
    
    {
        UILabel *label = UILabel.new;
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        label.text = @"昵称";
        [self.largeImageView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.avatarImageView.mas_right).offset(4);
                    make.centerY.equalTo(self.avatarImageView.mas_centerY);
        }];
        self.nicknameLabel = label;
        
    }
    {
        UILabel *label = UILabel.new;
        label.textColor = UIColor.whiteColor;
        label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        label.text = @"999";
        [self.largeImageView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.bottom.mas_equalTo(-12);
        }];
        self.likeCountLabel = label;
    }
    {
        UIImageView *imageView = UIImageView.new;
        [self.largeImageView addSubview:imageView];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.likeCountLabel.mas_left).offset(-4);
            make.centerY.mas_equalTo(self.likeCountLabel.mas_centerY);
        }];
        imageView.image = [UIImage imageNamed:@"likeImage"];
        
//        imageView.layer.cornerRadius = 16;
//        imageView.layer.masksToBounds = true;
//        self.avatarImageView = imageView;
//        imageView.backgroundColor = UIColor.yellowColor;
    }
    
    {
        UIImageView *imageView = UIImageView.new;
        [self.largeImageView addSubview:imageView];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(8);
            make.top.mas_equalTo(8);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(54);
        }];
        imageView.image = [UIImage imageNamed:@"home-living"];
        {
            UIView *view = UIView.new;
            view.backgroundColor = UIColor.grayColor;
            view.alpha = 0.5;
            [self.largeImageView addSubview:view];
            [self.largeImageView insertSubview:view belowSubview:imageView];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(imageView.mas_right).offset(-20);
                make.centerY.equalTo(imageView.mas_centerY);
                make.height.mas_equalTo(20);
//                make.width.mas_equalTo(80);
            }];
            view.layer.masksToBounds = true;
            view.layer.cornerRadius = 10;
            UILabel *label = UILabel.new;
            label.textColor = UIColor.whiteColor;
            label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
            label.text = @"999";
            [view addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(0);
                make.centerX.mas_equalTo(20);
                make.left.mas_equalTo(30);
                make.right.mas_equalTo(-10);
            }];
            self.watchCountLabel = label;
        }

    }

    
//    UIImageView *livingImgV = [[UIImageView alloc]init];
//    livingImgV.image = [UIImage imageNamed:@"home-living"];
//    [topBackView addSubview:livingImgV];
//    [livingImgV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(topBackView).offset(5);
//        make.centerY.equalTo(topBackView);
//        make.width.mas_equalTo(50);
//        make.height.mas_equalTo(17);
//    }];
    
//    UILabel *numsL = [[UILabel alloc]init];
//    numsL.text = [NSString stringWithFormat:@"%@人观看", model.nums];
//    numsL.font = [UIFont systemFontOfSize:10];
//    numsL.textColor = [UIColor whiteColor];
//    [topBackView addSubview:numsL];
//    [numsL mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(livingImgV.mas_right).offset(5);
//        make.centerY.equalTo(topBackView);
//        make.right.equalTo(topBackView).offset(-10);
//    }];

    

}





- (void)bindFromModel:(NSDictionary *)model{
    [self.largeImageView sd_cancelCurrentImageLoad];
    [self.avatarImageView sd_cancelCurrentImageLoad];
    [self.largeImageView sd_setImageWithURL:[NSURL URLWithString:model[@"thumb"]]];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model[@"avatar"]]];
    self.nicknameLabel.text = model[@"nickname"];
    self.titleLabel.text = model[@"title"];
    self.likeCountLabel.text = model[@"likes"];
    self.watchCountLabel.text = [NSString stringWithFormat:@"%@人观看",model[@"nums"]];
}



@end
