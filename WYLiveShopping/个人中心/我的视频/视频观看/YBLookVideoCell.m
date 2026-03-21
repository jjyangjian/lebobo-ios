//
//  YBLookVideoCell.m
//  yunbaolive
//
//  Created by ybRRR on 2020/9/17.
//  Copyright © 2020 cat. All rights reserved.
//

#import "YBLookVideoCell.h"
#import "PublicObj.h"
#import "GoodsDetailsViewController.h"
@interface YBLookVideoCell()

/** 头像 点赞 评论 分享集合 */
@property(nonatomic,strong)UIView *rightView;
@property(nonatomic,strong) UIButton *iconBtn;
@property(nonatomic,strong) UIButton *followBtn;                    //关注
@property(nonatomic,strong) UIButton *likebtn;                      //点赞
@property(nonatomic,strong) UIButton *enjoyBtn;
/** 名字 标题 (音乐)集合 */
@property(nonatomic,strong)UIView *botView;
@property(nonatomic,strong)UILabel *titleL;                         //视频标题
@property(nonatomic,strong)UILabel *nameL;

@property(nonatomic,strong) UIButton *shopButton;                 //商品按钮
@end

@implementation YBLookVideoCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.bgImgView];
        [_bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerX.centerY.equalTo(self.contentView);
        }];
        [self setUp];
    }
    return self;
}

-(void)setUp {
    [self.contentView addSubview:self.botView];
    [_botView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-50-ShowDiff);
    }];
    [self.contentView addSubview:self.rightView];
}

- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] init];
        _bgImgView.userInteractionEnabled = YES;
        _bgImgView.backgroundColor = [UIColor blackColor];
        _bgImgView.tag =191107;
    }
    return _bgImgView;
}


#pragma mark - set/get
- (UIView *)rightView{
    if (!_rightView) {
        CGFloat rv_w = 85;
        CGFloat rv_h = 300;//头像+点赞+评论+分享
        CGFloat rv_all_h = 300;//头像+点赞+评论+分享 +唱片
        _rightView = [[UIView alloc]initWithFrame:CGRectMake(_window_width-rv_w, _window_height-rv_all_h-49-ShowDiff, rv_w, rv_all_h)];
        _rightView.backgroundColor = [UIColor clearColor];
        
        CGFloat btnW = 70;
        CGFloat btnH = 70;
        CGFloat spaceW = 15;
        CGFloat specialH = 10;//给头像和点赞之间特意多留
        CGFloat spaceH = (rv_h-specialH-btnH*4)/3;
        
        //主播头像
        _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _iconBtn.frame = CGRectMake(10+spaceW, 0, 50, 50);
        _iconBtn.layer.masksToBounds = YES;
        _iconBtn.layer.borderWidth = 1;
        _iconBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _iconBtn.layer.cornerRadius = 25;
        _iconBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconBtn.imageView.clipsToBounds = YES;
        [_iconBtn addTarget:self action:@selector(zhuboMessage) forControlEvents:UIControlEventTouchUpInside];
        [_iconBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:@""] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_head.png"]];
        
        //关注按钮
        _followBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _followBtn.frame = CGRectMake(_iconBtn.left+12, _iconBtn.bottom-13, 26, 26);
        [_followBtn setImage:[UIImage imageNamed:@"home_follow"] forState:0];
        [_followBtn addTarget:self action:@selector(guanzhuzhubo) forControlEvents:UIControlEventTouchUpInside];
        
        //点赞
        _likebtn = [UIButton buttonWithType:0];
        _likebtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _likebtn.frame = CGRectMake(spaceW, _iconBtn.bottom+spaceH+specialH, btnW, btnH);
        [_likebtn addTarget:self action:@selector(dolike) forControlEvents:UIControlEventTouchUpInside];
        [_likebtn setImage:[UIImage imageNamed:@"home_zan"] forState:0];
        [_likebtn setTitle:@" 0 " forState:0];//空格占位符不要去除
        _likebtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _likebtn = [PublicObj setUpImgDownText:_likebtn];
        
        //评论列表
        _commentBtn = [UIButton buttonWithType:0];
        [_commentBtn setImage:[UIImage imageNamed:@"home_comment"] forState:0];
        [_commentBtn setTitle:@" 0 " forState:0];//空格占位符不要去除
        _commentBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _commentBtn.frame = CGRectMake(spaceW, _likebtn.bottom+spaceH, btnW,btnH);
        [_commentBtn addTarget:self action:@selector(messgaebtn) forControlEvents:UIControlEventTouchUpInside];
        _commentBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _commentBtn = [PublicObj setUpImgDownText:_commentBtn];
        
        //分享
        _enjoyBtn = [UIButton buttonWithType:0];
        [_enjoyBtn setImage:[UIImage imageNamed:@"home_share"] forState:0];
        [_enjoyBtn setTitle:@" 0 " forState:0];//空格占位符不要去除
        _enjoyBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _enjoyBtn.frame = CGRectMake(spaceW, _commentBtn.bottom+spaceH, btnW,btnH);
        [_enjoyBtn addTarget:self action:@selector(doenjoy) forControlEvents:UIControlEventTouchUpInside];
        _enjoyBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        _enjoyBtn = [PublicObj setUpImgDownText:_enjoyBtn];
                
        [_rightView addSubview:_iconBtn];
        [_rightView addSubview:_followBtn];
        [_rightView addSubview:_likebtn];
        [_rightView addSubview:_commentBtn];
        [_rightView addSubview:_enjoyBtn];
    }
    return _rightView;
}
- (UIView *)botView {
    if (!_botView) {
        _botView = [[UIView alloc]init];
        _botView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        _shopButton = [UIButton buttonWithType:0];
        _shopButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _shopButton.layer.cornerRadius = 3;
        _shopButton.layer.masksToBounds = YES;
        [_shopButton addTarget:self action:@selector(shopButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_shopButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.4]];
        [_shopButton setTitleColor:[UIColor whiteColor] forState:0];
        [_shopButton setImage:[UIImage imageNamed:@"视频购物"] forState:0];
        _shopButton.imageEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
        [_shopButton setTitle:@"" forState:0];
        _shopButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_botView addSubview:_shopButton];
        _shopButton.hidden = YES;
        [_shopButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_botView).offset(5);
            make.left.equalTo(_botView).offset(5);
            make.width.lessThanOrEqualTo(_botView).multipliedBy(0.7);
            make.height.mas_equalTo(24);
        }];
        //视频作者名称
        _nameL = [[UILabel alloc]init];
        _nameL.textAlignment = NSTextAlignmentLeft;
        _nameL.textColor = [UIColor whiteColor];
        _nameL.shadowOffset = CGSizeMake(1,1);//设置阴影
//        _nameL.font = [UIFont boldSystemFontOfSize:16];
//        UITapGestureRecognizer *nametap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zhuboMessage)];
//        //nametap.numberOfTouchesRequired = 1;
//        _nameL.userInteractionEnabled = YES;
//        [_nameL addGestureRecognizer:nametap];
        [_botView addSubview:_nameL];
        [_nameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_botView).offset(5);
            make.width.equalTo(_botView).multipliedBy(0.7);
            make.top.equalTo(_shopButton.mas_bottom).offset(5);
        }];

        //视频标题
        _titleL = [[UILabel alloc]init];
        _titleL.textAlignment = NSTextAlignmentLeft;
        _titleL.textColor = [UIColor whiteColor];
        _titleL.shadowOffset = CGSizeMake(1,1);//设置阴影
        _titleL.numberOfLines = 0;
        _titleL.font = SYS_Font(14);
        [_botView addSubview:_titleL];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_botView).offset(5);
            make.width.equalTo(_botView).multipliedBy(0.7);
            make.top.equalTo(_nameL.mas_bottom).offset(5);
            make.bottom.equalTo(_botView).offset(-25);
        }];

        
    }
    return _botView;
}
- (void)setDataDic:(NSDictionary *)dataDic {
    _dataDic = dataDic;

    CGFloat coverRatio = 1.78;
    if (![PublicObj checkNull:minstr([_dataDic valueForKey:@"anyway"])]) {
        coverRatio = [minstr([_dataDic valueForKey:@"anyway"]) floatValue];
    }
    if (coverRatio > 1) {
        _bgImgView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImgView.clipsToBounds = YES;
    }else {
        _bgImgView.contentMode = UIViewContentModeScaleAspectFit;

        _bgImgView.clipsToBounds = NO;
    }
    [_bgImgView sd_setImageWithURL:[NSURL URLWithString:minstr([_dataDic valueForKey:@"thumb"])] placeholderImage:[UIImage imageNamed:@"loading_bgView"]];
    NSString *dataUid = minstr([dataDic valueForKey:@"uid"]);
    NSString *dataIcon = minstr([dataDic valueForKey:@"avatar"]);
    NSString *dataUname = minstr([dataDic valueForKey:@"nickname"]);
    [_iconBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:dataIcon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_head.png"]];

    NSString * _shares =[NSString stringWithFormat:@"%@",[dataDic valueForKey:@"shares"]];
    NSString * _likes = [NSString stringWithFormat:@"%@",[dataDic valueForKey:@"likes"]];
    NSString * _islike = [NSString stringWithFormat:@"%@",[dataDic valueForKey:@"islike"]];
    NSString * _comments = [NSString stringWithFormat:@"%@",[dataDic valueForKey:@"comments"]];
    NSString *isattent = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",[dataDic valueForKey:@"isattent"]]];
    //点赞数 评论数 分享数
    if ([_islike isEqual:@"1"]) {
        [_likebtn setImage:[UIImage imageNamed:@"home_zan_sel"] forState:0];
        //weakSelf.likebtn.userInteractionEnabled = NO;
    } else{
        [_likebtn setImage:[UIImage imageNamed:@"home_zan"] forState:0];
        //weakSelf.likebtn.userInteractionEnabled = YES;
    }
    [_likebtn setTitle:[NSString stringWithFormat:@"%@",_likes] forState:0];
    _likebtn = [PublicObj setUpImgDownText:_likebtn];
    [_enjoyBtn setTitle:[NSString stringWithFormat:@"%@",_shares] forState:0];
    _enjoyBtn = [PublicObj setUpImgDownText:_enjoyBtn];
    [_commentBtn setTitle:[NSString stringWithFormat:@"%@",_comments] forState:0];
    _commentBtn = [PublicObj setUpImgDownText:_commentBtn];
    
    if ( [isattent isEqual:@"1"]) {
        [_followBtn setImage:[UIImage imageNamed:@"home_follow_sel"] forState:0];
        //_followBtn.hidden = YES;
    }else{
        [_followBtn setImage:[UIImage imageNamed:@"home_follow"] forState:0];
    }
    _followBtn.hidden = NO;
    [_followBtn.layer addAnimation:[PublicObj followShowTransition] forKey:nil];

    _titleL.text = [NSString stringWithFormat:@"%@",[dataDic valueForKey:@"name"]];
    _nameL.text = dataUname;
    //计算名称长度
    CGSize titleSize = [_titleL.text boundingRectWithSize:CGSizeMake(_window_width*0.7, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYS_Font(14)} context:nil].size;
//    [_titleL mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(titleSize.height);
//    }];
//    _titleL.frame = CGRectMake(0, _botView.height-titleSize.height, titleSize.width, titleSize.height);
//    _nameL.frame = CGRectMake(0, _titleL.top-25, _botView.width, 25);
//    _nameL.frame = CGRectMake(0, _titleL.top-25, _botView.width, 25);
    _followBtn.frame = CGRectMake(_iconBtn.left+12, _iconBtn.bottom-13, 26, 26);
    
    NSString *isgoods = minstr([dataDic valueForKey:@"goodsid"]);
    NSArray *goods = [dataDic valueForKey:@"goods"];
    if ([isgoods integerValue] > 0 && goods.count > 0) {
        NSDictionary *dic = [goods firstObject];
        _shopButton.hidden = NO;
        [_shopButton setTitle:[NSString stringWithFormat:@"  购物 | %@  ",minstr([dic valueForKey:@"store_name"])] forState:0];
        [_shopButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(24);
        }];
    }else{
        _shopButton.hidden = YES;
        [_shopButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}
-(void)guanzhuzhubo
{
    
    WeakSelf;
    NSString *videoUserID = minstr([_dataDic valueForKey:@"uid"]);

    _followBtn.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _followBtn.userInteractionEnabled = YES;
    });
    if ([minstr([_dataDic valueForKey:@"isattent"]) isEqual:@"1"]) {
        [WYToolClass postNetworkWithUrl:@"attent/del" andParameter:@{@"touid":videoUserID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            _followBtn.userInteractionEnabled = YES;
            if (code == 200) {
                [MBProgressHUD showError:msg];
                NSDictionary *newDic = @{@"isattent":@"0"};
                [weakSelf updateDataDic:newDic];
                if (weakSelf.videoCellEvent) {
                    weakSelf.videoCellEvent(@"视频-关注", newDic);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                     [_followBtn setImage:[UIImage imageNamed:@"home_follow"] forState:0];
                });
            }
        } fail:^{
        }];

    }else{
        [WYToolClass postNetworkWithUrl:@"attent/add" andParameter:@{@"touid":videoUserID} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 200) {
                [MBProgressHUD showError:@"关注成功"];
                NSDictionary *newDic = @{@"isattent":@"1"};
                [weakSelf updateDataDic:newDic];
                if (weakSelf.videoCellEvent) {
                    weakSelf.videoCellEvent(@"视频-关注", newDic);
                }

                dispatch_async(dispatch_get_main_queue(), ^{
                    [_followBtn.imageView.layer addAnimation:[PublicObj smallToBigToSmall] forKey:nil];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [_followBtn setImage:[UIImage imageNamed:@"home_follow_sel"] forState:0];
                    });
                });

            }
        } fail:^{
            
        }];


    }


}
 //点赞
 -(void)dolike{
     WeakSelf;
     NSDictionary *subdic = @{
                              @"vid":minstr([_dataDic valueForKey:@"id"]),
                              @"type":[minstr([_dataDic valueForKey:@"islike"]) isEqual:@"1"] ? @"0" : @"1"
     };

     [WYToolClass postNetworkWithUrl:@"videolike" andParameter:subdic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
         if(code == 200) {
             NSString *islike = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"type"]];
             NSString *likes  = [NSString stringWithFormat:@"%@",[info valueForKey:@"likes"]];
             [_likebtn setTitle:[NSString stringWithFormat:@"%@",likes] forState:0];
             NSDictionary *newDic = @{@"islike":islike,@"likes":likes};
             [weakSelf updateDataDic:newDic];
             
             if (weakSelf.videoCellEvent) {
                 weakSelf.videoCellEvent(@"视频-点赞", newDic);
             }

             if ([islike isEqual:@"1"]) {
                 NSMutableArray *m_sel_arr = [NSMutableArray array];
                 for (int i=1; i<=15; i++) {
                     UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"icon_video_zan_%02d",i]];
                     [m_sel_arr addObject:img];
                 }
                 [UIView animateWithDuration:0.8 animations:^{
                     _likebtn.imageView.animationImages = m_sel_arr;
                     _likebtn.imageView.animationDuration = 0.8;
                     _likebtn.imageView.animationRepeatCount = 1;
                     [_likebtn.imageView startAnimating];
                 } completion:^(BOOL finished) {
                     [_likebtn setImage:[UIImage imageNamed:@"icon_video_zan_15"] forState:0];
                 }];
             }else{
                     [_likebtn setImage:[UIImage imageNamed:@"icon_video_zan_01"] forState:0];
             }
         }else{
             [MBProgressHUD showError:msg];
         }

      } fail:^{
          
      }];

 }

-(void)zhuboMessage{
//    NSString *_hostid = [[_dataDic valueForKey:@"userinfo"] valueForKey:@"id"];
//    otherUserMsgVC *center = [[otherUserMsgVC alloc]init];
//    if ([_hostid isEqual:[Config getOwnID]]) {
//        center.userID =[Config getOwnID];
//    }else{
//        center.userID =_hostid;
//    }
//    center.hidesBottomBarWhenPushed = YES;
//    [[MXBADelegate sharedAppDelegate] pushViewController:center animated:YES];
    
}
-(void)messgaebtn{

    if (self.videoCellEvent) {
        self.videoCellEvent(@"评论",_dataDic);
    }

}
-(void)doenjoy{

    if (self.videoCellEvent) {
        self.videoCellEvent(@"分享",_dataDic);
    }

}
-(void)shopButtonClick{
    if (self.videoCellEvent) {
        self.videoCellEvent(@"商品",_dataDic);
    }

//    NSString *goodsid = minstr([_dataDic valueForKey:@"goodsid"]);
//    NSLog(@"yyyyyyyyyyyyy----isgoods:%@ \n  dic:%@",goodsid, _dataDic);
//    GoodsDetailsViewController *vc = [[GoodsDetailsViewController alloc]init];
//    vc.goodsID = goodsid;
//    vc.liveUid = minstr([_dataDic valueForKey:@"uid"]);
//    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

    //0 没有。1商品。2.付费内容
}
///点赞、评论、关注后这里也更新一下
-(void)updateDataDic:(NSDictionary *)dic {
 NSMutableDictionary *m_dic = [NSMutableDictionary dictionaryWithDictionary:_dataDic];
 [m_dic addEntriesFromDictionary:dic];
 _dataDic = [NSDictionary dictionaryWithDictionary:m_dic];
}
@end
