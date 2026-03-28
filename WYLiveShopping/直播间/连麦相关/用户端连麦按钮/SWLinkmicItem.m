//
//  SWLinkmicItem.m
//  WYLiveShopping
//
//  Created by iyz on 2026/1/23.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import "SWLinkmicItem.h"

@interface SWLinkmicItem()

@property(nonatomic,strong)UIImageView *leftIV;
@property(nonatomic,strong)UILabel *titL;

@end

@implementation SWLinkmicItem

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createUI];
    }
    return self;
}

-(void)createUI {
    _leftIV = [[UIImageView alloc]init];
    _leftIV.image = [UIImage imageNamed:@"link_add"];
    [self addSubview:_leftIV];
    [_leftIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(10);
        make.left.equalTo(self.mas_left).offset(10);
        make.centerY.equalTo(self);
    }];
    _titL = [[UILabel alloc]init];
    _titL.text = @"申请连麦";
    _titL.textColor = RGB_COLOR(@"#ffffff", 1);
    _titL.font = SYS_Font(10);
    [self addSubview:_titL];
    [_titL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftIV.mas_right).offset(2);
        make.centerY.equalTo(self);
        make.right.equalTo(self.mas_right).offset(-10);
    }];
}

- (void)setUserStatus:(UserLinkStatus)userStatus {
    _userStatus = userStatus;
    BOOL showImg = YES;
    if (_userStatus == UserLinkStatus_Applied) {
        _titL.text = @"取消申请";
        showImg = NO;
    }else if (_userStatus == UserLinkStatus_Onmic) {
        _titL.text = @"下麦";
        showImg = NO;
    }else {
        _titL.text = @"申请连麦";
        showImg = YES;
    }

    if (showImg) {
        [_leftIV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(10);
            make.left.equalTo(self.mas_left).offset(10);
            make.centerY.equalTo(self);
        }];
        [_titL mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_leftIV.mas_right).offset(5);
            make.centerY.equalTo(self);
            make.right.equalTo(self.mas_right).offset(-10);
        }];
    }else {
        [_leftIV mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(0);
            make.left.equalTo(self.mas_left).offset(10);
            make.centerY.equalTo(self);
        }];
        [_titL mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_leftIV.mas_right).offset(0);
            make.centerY.equalTo(self);
            make.right.equalTo(self.mas_right).offset(-10);
        }];
    }

}




@end
