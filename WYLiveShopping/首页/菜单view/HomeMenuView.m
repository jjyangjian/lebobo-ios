//
//  HomeMenuView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/13.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "HomeMenuView.h"
#import "GoodsDetailsViewController.h"

@implementation HomeMenuView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)setMsgDic:(NSDictionary *)msgDic{
    _msgDic = msgDic;
    _titleLabel.text = minstr([_msgDic valueForKey:@"name"]);
    _titleLabel.textColor = RGB_COLOR(minstr([_msgDic valueForKey:@"color"]), 1);
    _tipsLabel.text = minstr([_msgDic valueForKey:@"des"]);
    if (minstr([_msgDic valueForKey:@"tag"]).length > 0) {
        _classLabel.text = minstr([_msgDic valueForKey:@"tag"]);
        _classView.hidden = NO;
    }else{
        _classLabel.text = @"";
        _classView.hidden = YES;
    }
    NSArray *list = [_msgDic valueForKey:@"list"];
//    MASViewAttribute *lffff = self.mas_left;
    CGFloat btnWidth = 70.0f;
    if (IS_IPHONE_5) {
        btnWidth = 60.0f;
    }
    for (int i = 0; i < list.count; i ++) {
        NSDictionary *dic = list[i];
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(13 + i * (btnWidth + 13), 60, btnWidth, btnWidth);
        [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"image"])] forState:0];
        [btn setCornerRadius:3.0f];
        btn.tag = 300+i;
        btn.clipsToBounds = YES;
        [btn addTarget:self action:@selector(shopCLick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
//        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(lffff).offset(13);
//            make.bottom.equalTo(self).offset(-15);
//            make.top.equalTo(self).offset(60);
//            make.width.equalTo(btn.mas_height);
//        }];
//        lffff = btn.mas_right;
    }
}
- (void)shopCLick:(UIButton *)sender{
    NSArray *list = [_msgDic valueForKey:@"list"];
    NSDictionary *dic = list[sender.tag-300];
    GoodsDetailsViewController *vc = [[GoodsDetailsViewController alloc]init];
    vc.goodsID = minstr([dic valueForKey:@"id"]);
    vc.liveUid = @"";
    [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

}
@end
