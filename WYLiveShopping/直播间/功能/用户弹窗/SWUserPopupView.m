//
//  SWUserPopupView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWUserPopupView.h"
#import "SWChatWarningList.h"
@interface SWUserPopupView()<WYChatWarningListDelegate>
@end
@implementation SWUserPopupView{
    UIImageView *showImageView;
    SWChatModel *userModel;
    UIButton *shutUpBtn;
    UIButton *kickBtn;
    NSDictionary *userMsg;
    UIButton *adminBtn;
    SWChatWarningList *list;
    NSString *anchorID;
}

-(instancetype)initWithFrame:(CGRect)frame andModel:(SWChatModel *)model liveUid:(nonnull NSString *)uid{
    if (self = [super initWithFrame:frame]) {
        anchorID = uid;
        userModel = model;
        [self creatUI:model];
        [self requestData];
    }
    return self;
}
- (void)creatUI:(SWChatModel *)model{
    showImageView = [[UIImageView alloc]initWithFrame:CGRectMake((_window_width-240)/2, _window_height, 240, 180)];
    showImageView.image = [UIImage imageNamed:@"popupBack"];
    showImageView.userInteractionEnabled = YES;
    [self addSubview:showImageView];
    
    UIImageView *iconImgView = [[UIImageView alloc]init];
    [iconImgView sd_setImageWithURL:[NSURL URLWithString:model.icon]];
    iconImgView.contentMode = UIViewContentModeScaleAspectFill;
    iconImgView.clipsToBounds = YES;
    iconImgView.layer.cornerRadius = 30;
    iconImgView.layer.masksToBounds = YES;
    [showImageView addSubview:iconImgView];
    [iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(showImageView).offset(20);
        make.width.height.mas_equalTo(60);
        make.centerX.equalTo(showImageView);
    }];
    UIButton *closeBtn = [UIButton buttonWithType:0];
    [closeBtn setImage:[UIImage imageNamed:@"userMsg_close"] forState:0];
    [closeBtn addTarget:self action:@selector(doHide) forControlEvents:UIControlEventTouchUpInside];
    [showImageView addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(50);
        //make.height.mas_equalTo(20);
        make.centerY.equalTo(iconImgView.mas_top).offset(0);
        make.right.equalTo(showImageView).offset(0);
    }];
    
    adminBtn = [UIButton buttonWithType:0];
    [adminBtn setTitle:@"设为管理" forState:0];
    adminBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [adminBtn setTitleColor:color64 forState:0];
    [adminBtn addTarget:self action:@selector(doAdmin) forControlEvents:UIControlEventTouchUpInside];
    [showImageView addSubview:adminBtn];
    adminBtn.hidden = YES;
    [adminBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(20);
        make.left.equalTo(showImageView).offset(0);
        make.centerY.equalTo(iconImgView.mas_top).offset(4);
    }];
    
    UILabel *nameL = [[UILabel alloc]init];
    nameL.font = [UIFont boldSystemFontOfSize:14];
    nameL.text = model.userName;
    [showImageView addSubview:nameL];
    [nameL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(showImageView);
        make.centerY.equalTo(showImageView).offset(12);
    }];
    
    NSArray *array = @[@"禁言",@"踢出"];
    for (int i = 0; i < array.count; i++) {
        UIButton *btn = [UIButton buttonWithType:0];
        [btn setTitle:array[i] forState:0];
        btn.titleLabel.font = SYS_Font(10);
        [btn setTitleColor:color64 forState:0];
        btn.layer.cornerRadius = 11;
        btn.layer.masksToBounds = YES;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = RGB_COLOR(@"#E6E6E6", 1).CGColor;
        [btn addTarget:self action:@selector(bottomBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1000 + i;
        btn.hidden = YES;
        [showImageView addSubview:btn];
        if (i == 0) {
            [btn setTitle:@"解除禁言" forState:UIControlStateSelected];
            shutUpBtn = btn;
            shutUpBtn.userInteractionEnabled = NO;
        }else{
            kickBtn = btn;
        }

        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(showImageView).offset(-22);
            make.left.equalTo(showImageView).offset(50+i*80);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(22);
        }];
    }
    [showImageView layoutIfNeeded];
    [UIView animateWithDuration:0.1 animations:^{
        showImageView.centerY = self.centerY;
    }];
}
- (void)doHide{
    WeakSelf;
    if (weakSelf.delegate) {
        [weakSelf.delegate removeUserPopupView];
    }
//    [UIView animateWithDuration:0.1 animations:^{
//        showImageView.y = _window_height;
//    } completion:^(BOOL finished) {
//        if (weakSelf.delegate) {
//            [weakSelf.delegate removeUserPopupView];
//        }
//    }];

}
- (void)requestData{
    [SWToolClass getQCloudWithUrl:[NSString stringWithFormat:@"pop?touid=%@&liveuid=%@",userModel.userID,anchorID] Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            userMsg = info;
            shutUpBtn.selected = [minstr([userMsg valueForKey:@"isshut"]) intValue];
            shutUpBtn.userInteractionEnabled = YES;
            [self resetUI];
        }
    } Fail:^{
        
    }];
}
- (void)resetUI{
    NSString *action = minstr(userMsg[@"action"]);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (action.integerValue == 40) {
            kickBtn.hidden = NO;
            shutUpBtn.hidden = NO;
            adminBtn.hidden = YES;
        }else if (action.integerValue == 501){
            kickBtn.hidden = NO;
            shutUpBtn.hidden = NO;
            adminBtn.hidden = NO;
        }else if (action.integerValue == 502){
            kickBtn.hidden = NO;
            shutUpBtn.hidden = NO;
            adminBtn.hidden = NO;
            [adminBtn setTitle:@"取消管理员" forState:0];
        }else{
            kickBtn.hidden = YES;
            shutUpBtn.hidden = YES;
            adminBtn.hidden = YES;
        }
    });
}
- (void)bottomBtnClick:(UIButton *)sender{
    if (sender.tag == 1000) {
        if (shutUpBtn.selected) {
            //解除禁言
            [self doCancleShutUP];
        }else{
            //禁言
            [self doShutUP];
        }
    }else{
        //踢出
        [self doKick];
    }
}

//禁言
- (void)doShutUP{
    
    
    NSDictionary *params = @{
        @"liveuid":anchorID,
        @"touid":userModel.userID,
    };
    [MBProgressHUD showMessage:@""];
    [SWToolClass postJsonNetworkWithUrl:@"liveshut" andParameter:params success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];

        if (code == 200) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showSuccess:@"禁言成功"];
                self->shutUpBtn.selected = true;
//                SWChatWarningList *list = [[SWChatWarningList alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height) data:info];
//                list.delegate = self;
//                [self addSubview:list];
            });
        }else{
            [MBProgressHUD showError:@"禁言失败"];

        }
    } fail:^{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:@"网络错误"];

    }];
//    [MBProgressHUD showMessage:@""];
//    [SWToolClass getQCloudWithUrl:@"/live/liveshut" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
//        [MBProgressHUD hideHUD];
//
//       if (code == 200) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                SWChatWarningList *list = [[SWChatWarningList alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height) data:info];
//                list.delegate = self;
//                [self addSubview:list];
//            });
//           
//       }else{
//           [MBProgressHUD showError:@"禁言失败"];
//       }
//    } Fail:^{
//        [MBProgressHUD hideHUD];
//        [MBProgressHUD showError:@"网络错误"];
//
//    }];
    
}


//解除禁言
- (void)doCancleShutUP{
    NSDictionary *actionMap = @{
        @"touid":userModel.userID,
        @"liveuid":anchorID
    };
    [SWToolClass postNetworkWithUrl:@"liveunshut" andParameter:actionMap success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self->shutUpBtn.selected = false;
            if (self.delegate) {
                [self.delegate doCancleShutupUser:userModel.userID andUserName:userModel.userName];
            }
            [MBProgressHUD showError:msg];
            [self doHide];
        }
    } fail:^{
        
    }];
}
- (void)doKick{
    NSDictionary *actionMap = @{
        @"touid":userModel.userID,
        @"liveuid":anchorID
    };
    [SWToolClass postNetworkWithUrl:@"livekick" andParameter:actionMap success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            if (self.delegate) {
                [self.delegate doKickUser:userModel.userID andUserName:userModel.userName];
            }
            [MBProgressHUD showError:msg];
            [self doHide];
        }
    } fail:^{
        
    }];
}
#pragma mark -  设置管理
- (void)doAdmin{
    NSDictionary *actionMap = @{
        @"touid":userModel.userID,
        @"liveuid":anchorID
    };
    NSString *action = minstr([userMsg valueForKey:@"action"]);
    if ([action isEqualToString:@"501"]) {
        [SWToolClass postNetworkWithUrl:@"setmanager" andParameter:actionMap success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 200) {
                if (self.delegate) {
                    [self.delegate setAdminUser:userModel.userID andUserName:userModel.userName];
                }
//                [MBProgressHUD showError:msg];
                [self doHide];
            }
        } fail:^{
            
        }];
    }else{
        [self cancelAdmin];
    }
    
}
- (void)cancelAdmin{
    NSDictionary *actionMap = @{
        @"touid":userModel.userID,
        @"liveuid":anchorID
    };
    [SWToolClass postNetworkWithUrl:@"delmanager" andParameter:actionMap success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            if (self.delegate) {
                [self.delegate cancelAdminUser:userModel.userID andUserName:userModel.userName];
            }
//            [MBProgressHUD showError:msg];
            [self doHide];
        }
    } fail:^{
        
    }];
}
- (void)setIsOnlineUser:(BOOL)isOnlineUser{
    _isOnlineUser = isOnlineUser;
    adminBtn.hidden = !isOnlineUser;
}
#pragma mark - Jinyan delegate
- (void)jinyanUser:(nonnull NSString *)time name:(nonnull NSString *)content jinyanID:(nonnull NSString *)ID {
    NSDictionary *actionMap = @{
        @"touid":userModel.userID,
        @"liveuid":anchorID,
        @"shutid":ID
    };
    NSString *jinyanContent = [NSString stringWithFormat:@"%@被%@",userModel.userName,content];
    [SWToolClass postNetworkWithUrl:@"liveshut" andParameter:actionMap success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            if (self.delegate) {
                [self.delegate doShutupUser:userModel.userID andUserName:userModel.userName content:jinyanContent];
            }
            [MBProgressHUD showError:msg];
            [self doHide];
        }
    } fail:^{
        
    }];
}



@end
