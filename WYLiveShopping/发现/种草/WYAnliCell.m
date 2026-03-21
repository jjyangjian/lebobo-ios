//
//  WYAnliCell.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/30.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYAnliCell.h"
#import "relationGoodsView.h"
#import "WYImageView.h"
@implementation WYAnliCell{
    WYImageView *wyShowImgView;

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)doFollow:(id)sender {
    _followBtn.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _followBtn.userInteractionEnabled = YES;
    });
    if (_model) {
        [WYToolClass postNetworkWithUrl:@"shopsetattent" andParameter:@{@"type":_followBtn.selected ? @"0" : @"1",@"shopid":_model.mer_id} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 200) {
                
                _followBtn.selected = !_followBtn.selected;
                _model.isattent = [NSString stringWithFormat:@"%d",_followBtn.selected];
                [MBProgressHUD showError:_followBtn.selected ? @"关注成功" : @"取消关注成功"];

            }
        } fail:^{
            
        }];
    }else{
        if ([_livemodel.isattent isEqual:@"1"]) {
            [WYToolClass postNetworkWithUrl:@"attent/del" andParameter:@{@"touid":_livemodel.uid} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                _followBtn.userInteractionEnabled = YES;
                if (code == 200) {
                    [MBProgressHUD showError:msg];
                    _followBtn.selected = NO;
                    _livemodel.isattent = @"0";
                }
            } fail:^{
            }];

        }else{
            [WYToolClass postNetworkWithUrl:@"attent/add" andParameter:@{@"touid":_livemodel.uid} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
                if (code == 200) {
                    [MBProgressHUD showError:@"关注成功"];
                    _followBtn.selected = YES;
                    _livemodel.isattent = @"1";
                }
            } fail:^{
                
            }];
        }

    }


}
- (IBAction)doLike:(id)sender {
    _likeBtn.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _likeBtn.userInteractionEnabled = YES;
    });
    [WYToolClass postNetworkWithUrl:@"kollike" andParameter:@{@"kolid":_model.kolid,@"type":_likeBtn.selected ? @"0" : @"1"} success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            
            _likeBtn.selected = !_likeBtn.selected;
            _model.likes = minstr([info valueForKey:@"likes"]);
            [_likeBtn setTitle:[NSString stringWithFormat:@" %@",_model.likes] forState:0];

        }
    } fail:^{
        
    }];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setModel:(WYAnliModel *)model{
    _model = model;
    _nameL.text = _model.nickname;
    if ([_model.shoptype isEqual:@"2"]) {
        _typeView.hidden = NO;
    }else{
        _typeView.hidden = YES;
    }
    [_iconImgVie sd_setImageWithURL:[NSURL URLWithString:_model.avatar]];
    _timeL.text = _model.add_time;
    _followBtn.selected = [_model.isattent intValue];
    _viewsNumL.text = [NSString stringWithFormat:@"%@人阅读",_model.views];
    [_likeBtn setTitle:[NSString stringWithFormat:@" %@",_model.likes] forState:0];
    _likeBtn.selected = [_model.islike intValue];
    _contentL.attributedText = _model.contentAttStr;
    _showImgViewHeight.constant = _model.imageH;
    [self changeImageView];
    _scrollHeight.constant = 0;
    if (_model.isLive) {
        _scrollHeight.constant = _model.scrollH;
    }else{
        _scrollHeight.constant = 50;
    }
    if (_model.goods.count == 0) {
        _shopScrollView.hidden = YES;
    }else{
        _shopScrollView.hidden = NO;
        [self changeGoodsView];
    }
}
- (void)setLivemodel:(HomeLiveModel *)livemodel{
    _livemodel = livemodel;
    _contentL.attributedText = _livemodel.contentAttStr;
    _showImgViewHeight.constant = _livemodel.imageH;
    _nameL.text = _livemodel.nickname;
    [_iconImgVie sd_setImageWithURL:[NSURL URLWithString:_livemodel.avatar]];
    _timeL.text = _livemodel.add_time;
    _followBtn.selected = [_livemodel.isattent intValue];
    _viewsNumL.text = [NSString stringWithFormat:@"%@人观看",_livemodel.nums];

    [self changeLiveImageView];
    _scrollHeight.constant = _livemodel.scrollH;
    if (_livemodel.goods.count == 0) {
        _shopScrollView.hidden = YES;
    }else{
        _shopScrollView.hidden = NO;
        [self changeGoodsView];
    }

//    _timeL.text = _livemodel.t
}
- (void)changeLiveImageView{
    [_showImgView removeAllSubviews];
    [_showImgView layoutIfNeeded];
    if (_livemodel.thumbs.count == 1) {
        UIImageView *imgV = [[UIImageView alloc]init];
        [imgV sd_setImageWithURL:[NSURL URLWithString:_livemodel.thumbs[0]]];
        imgV.tag = 30000;
        imgV.userInteractionEnabled = YES;
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.clipsToBounds = YES;
        [_showImgView addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.width.height.equalTo(_showImgView);
        }];
//        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doBigImage:)];
//        [imgV addGestureRecognizer:tap];
    }else{
        for (int i = 0; i < (_livemodel.thumbs.count > 3 ? 3 : _livemodel.thumbs.count); i ++) {
            UIImageView *imgV = [[UIImageView alloc]init];
            [imgV sd_setImageWithURL:[NSURL URLWithString:_livemodel.thumbs[i]]];
            imgV.tag = 30000 + i;
            imgV.userInteractionEnabled = YES;
            imgV.contentMode = UIViewContentModeScaleAspectFill;
            imgV.clipsToBounds = YES;
            [_showImgView addSubview:imgV];
//            UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doBigImage:)];
//            [imgV addGestureRecognizer:tap];
            if (i == 0) {
                
                imgV.frame = CGRectMake(0, 0, (_window_width-50)-1-_livemodel.imageH/2, _livemodel.imageH);
            }else if (i == 1){
                imgV.frame = CGRectMake((_window_width-50)-_livemodel.imageH/2+1, 0, _livemodel.imageH/2-1, _livemodel.imageH/2-1);

            }else if (i == 2){
                imgV.frame = CGRectMake((_window_width-50)-_livemodel.imageH/2+1, _livemodel.imageH/2+1, _livemodel.imageH/2-1, _livemodel.imageH/2-1);
            }
        }

    }

}
- (void)changeImageView{
    [_showImgView removeAllSubviews];
    [_showImgView layoutIfNeeded];
    for (int i = 0; i < _model.image.count; i ++) {
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake((i%3)*((_window_width-50-4)/3 + 2), i/3 * (((_window_width-50-4)/3 * 0.75) + 2), (_window_width-50-4)/3, ((_window_width-50-4)/3 * 0.75))];
        [imgV sd_setImageWithURL:[NSURL URLWithString:_model.image[i]]];
        imgV.tag = 30000 + i;
        imgV.userInteractionEnabled = YES;
        imgV.contentMode = UIViewContentModeScaleAspectFill;
        imgV.clipsToBounds = YES;
        [_showImgView addSubview:imgV];
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doBigImage:)];
        [imgV addGestureRecognizer:tap];
    }
}
- (void)changeGoodsView{
    [_shopScrollView removeAllSubviews];
    int count = _model ? (int)_model.goods.count : (int)_livemodel.goods.count;
    CGFloat goodsWidth = 0.0;
    if (count == 1) {
        goodsWidth = (_window_width-50);
        _shopScrollView.contentSize = CGSizeMake(0, 0);
    }else{
        goodsWidth = (_window_width-50)*0.615;
        _shopScrollView.contentSize = CGSizeMake((goodsWidth + 5)*count, 0);
    }
    for (int i = 0; i < count; i ++) {
        relationGoodsView *goodsView = [[[NSBundle mainBundle] loadNibNamed:@"relationGoodsView" owner:nil options:nil] lastObject];
        if (_model) {
            goodsView.subDic = _model.goods[i];
        }else{
            goodsView.subDic = _livemodel.goods[i];
            goodsView.isLive = YES;
        }
        [_shopScrollView addSubview:goodsView];
        [goodsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.height.equalTo(_shopScrollView);
            make.width.mas_equalTo(goodsWidth);
            make.left.equalTo(_shopScrollView).offset(i * (goodsWidth + 5));
        }];
    }
}

- (void)doBigImage:(UITapGestureRecognizer *)tap{
    if (wyShowImgView) {
        [wyShowImgView removeFromSuperview];
        wyShowImgView = nil;
    }
    UIImageView *imageview = (UIImageView *)tap.view;
    NSInteger index = imageview.tag - 30000;
    wyShowImgView = [[WYImageView alloc] initWithImageArray:_model?_model.image:_livemodel.thumbs andIndex:index andMine:NO andBlock:^(NSArray * _Nonnull array) {
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:wyShowImgView];

}
-(void)dealloc{
    if (wyShowImgView) {
        [wyShowImgView removeFromSuperview];
        wyShowImgView = nil;
    }

}
@end
