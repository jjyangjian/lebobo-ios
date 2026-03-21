//
//  WYHomeLiveView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/31.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYHomeLiveView.h"
#import "LivePlayerViewController.h"
#import "HomeLiveModel.h"
@implementation WYHomeLiveView{
    UIImageView *_backImgV;
    UILabel *_numsL;
    UIImageView *_iconImgV;
    UILabel *_nameL;
    UILabel *_likesL;
    UIButton *_likeBtn;
    UILabel *_titleLabel;

}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self creatUI];
    }
    return self;
}
- (void)creatUI{
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    UIImageView *backImgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    backImgV.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:backImgV];
    _backImgV = backImgV;
    
    UIImageView *bbotImgV = [[UIImageView alloc]init];
    bbotImgV.image = [UIImage imageNamed:@"video-yinying"];
    bbotImgV.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:bbotImgV];
    [bbotImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.bottom.equalTo(self);
    }];
    UIView *topBackView = [[UIView alloc]init];
    topBackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    topBackView.layer.cornerRadius = 10;
    [self addSubview:topBackView];
    [topBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self).offset(5);
        make.height.mas_equalTo(20);
    }];
    UIImageView *livingImgV = [[UIImageView alloc]init];
    livingImgV.image = [UIImage imageNamed:@"home-living"];
    [topBackView addSubview:livingImgV];
    [livingImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topBackView).offset(1);
        make.centerY.equalTo(topBackView);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(17);
    }];
    UILabel *numsL = [[UILabel alloc]init];
    numsL.text = @"1.8万人观看";
    numsL.font = SYS_Font(9);
    numsL.textColor = [UIColor whiteColor];
    [topBackView addSubview:numsL];
    [numsL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(livingImgV.mas_right).offset(3);
        make.centerY.equalTo(topBackView);
        make.right.equalTo(topBackView).offset(-10);
    }];
    _numsL = numsL;
    UIImageView *iconImgV = [[UIImageView alloc]init];
    iconImgV.layer.cornerRadius = 10;
    iconImgV.layer.masksToBounds = YES;
    iconImgV.contentMode = UIViewContentModeScaleAspectFill;
    iconImgV.backgroundColor = YBRandomColor;
    [self addSubview:iconImgV];
    [iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(5);
        make.bottom.equalTo(self).offset(-5);
        make.width.height.mas_equalTo(20);
    }];
    _iconImgV = iconImgV;
    UILabel *nameL = [[UILabel alloc]init];
    nameL.text = @"啦啦嘞";
    nameL.font = SYS_Font(12);
    nameL.textColor = [UIColor whiteColor];
    [self addSubview:nameL];
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconImgV.mas_right).offset(3);
        make.centerY.equalTo(iconImgV);
        make.width.equalTo(self).multipliedBy(0.5);
    }];
    _nameL = nameL;
    UILabel *likesL = [[UILabel alloc]init];
    likesL.text = @"1.8W";
    likesL.font = SYS_Font(10);
    likesL.textColor = [UIColor whiteColor];
    [self addSubview:likesL];
    [likesL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(iconImgV);
        make.right.equalTo(self).offset(-8);
    }];
    _likesL = likesL;
    UIButton *likeBtn = [UIButton buttonWithType:0];
    [likeBtn setImage:[UIImage imageNamed:@"likeImage"] forState:0];
    likeBtn.userInteractionEnabled = NO;
    [self addSubview:likeBtn];
    [likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(iconImgV);
        make.right.equalTo(likesL.mas_left).offset(-5);
        make.width.height.mas_equalTo(10);
    }];
    _likeBtn = likeBtn;
    
    UILabel *titleL = [[UILabel alloc]init];
    titleL.numberOfLines = 2;
    titleL.font = SYS_Font(12);
    titleL.textColor = [UIColor whiteColor];
    [self addSubview:titleL];
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconImgV);
        make.right.equalTo(likesL);
        make.bottom.equalTo(iconImgV.mas_top).offset(-5);
    }];
    _titleLabel = titleL;

    [bbotImgV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLabel).offset(-10);
    }];
    UIButton *clickBtn = [UIButton buttonWithType:0];
    [clickBtn addTarget:self action:@selector(doCLick) forControlEvents:UIControlEventTouchUpInside];
    clickBtn.frame = CGRectMake(0, 0, self.width, self.height);
    [self addSubview:clickBtn];
}
- (void)setMsgDic:(NSDictionary *)msgDic{
    _msgDic = msgDic;
    _numsL.text = [NSString stringWithFormat:@"%@人观看",minstr([_msgDic valueForKey:@"nums"])];
    [_iconImgV sd_setImageWithURL:[NSURL URLWithString:minstr([_msgDic valueForKey:@"avatar"])]];
    _nameL.text = minstr([_msgDic valueForKey:@"nickname"]);
    _likesL.text = minstr([_msgDic valueForKey:@"likes"]);
    _titleLabel.text = minstr([_msgDic valueForKey:@"title"]);
    CGFloat tH = [[WYToolClass sharedInstance] heightOfString:minstr([_msgDic valueForKey:@"title"]) andFont:SYS_Font(12) andWidth:self.width-13];
    [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tH+2);
    }];

    [_backImgV sd_setImageWithURL:[NSURL URLWithString:minstr([_msgDic valueForKey:@"thumb"])]];
}
- (void)doCLick{
    NSLog(@"live");
    HomeLiveModel *model = [[HomeLiveModel alloc]initWithDic:_msgDic];
    [MBProgressHUD showMessage:@""];
    [self checkLive:model];
}
- (void)checkLive:(HomeLiveModel *)model{
    [WYToolClass postNetworkWithUrl:@"live/check" andParameter:@{@"stream":model.stream} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            LivePlayerViewController *player = [[LivePlayerViewController alloc]init];
            player.roomDic = [model.originDic mutableCopy];
            [[MXBADelegate sharedAppDelegate] pushViewController:player animated:YES];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
}

@end
