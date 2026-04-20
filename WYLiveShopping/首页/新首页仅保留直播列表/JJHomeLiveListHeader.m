//
//  JJHomeLiveListHeader.m
//  WYLiveShopping
//
//  Created by 牛环环 on 2026/3/25.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import "JJHomeLiveListHeader.h"
#import <Masonry.h>
@implementation JJHomeLiveListHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithReuseIdentifier:reuseIdentifier]){
        [self configUI];
    }
    return self;
}


- (void)configUI{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    view.clipsToBounds = YES;
    [self.contentView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
//    if (i == 0) {
//        view.frame = CGRectMake(10, 8, SWRecommendView.width/2-15, SWRecommendView.height-16);
//        liveView = view;
//    }else if(i == 1){
//        view.frame = CGRectMake(SWRecommendView.width/2+5, 8, SWRecommendView.width/2-15, (SWRecommendView.height-26)/2);
//        videoView = view;
//    }else{
//        view.frame = CGRectMake(SWRecommendView.width/2+5, 18+(SWRecommendView.height-26)/2, SWRecommendView.width/2-15, (SWRecommendView.height-26)/2);
//        courseView = view;
//
//    }
    UILabel *liveLabel = [[UILabel alloc]init];
    liveLabel.font = [UIFont boldSystemFontOfSize:15];
    liveLabel.textColor = color32;
    [view addSubview:liveLabel];
    [liveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@12);
        make.centerY.equalTo(@0);
    }];
    [liveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(8);
        make.centerY.equalTo(view.mas_top).offset(18);
    }];
    NSMutableAttributedString *muAttStr = [[NSMutableAttributedString alloc]initWithString:@"推荐直播"];
    [muAttStr addAttribute:NSForegroundColorAttributeName value:normalColors range:NSMakeRange(2, 2)];
    [muAttStr addAttribute:NSObliquenessAttributeName value:@0.2 range:NSMakeRange(0, 4)];
    liveLabel.attributedText = muAttStr;
    UIButton *moreBtn = [UIButton buttonWithType:0];
    [moreBtn setImage:[UIImage imageNamed:@"wy-more"] forState:0];
    [moreBtn addTarget:self action:@selector(doMore:) forControlEvents:UIControlEventTouchUpInside];
//        moreBtn.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
//        moreBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    moreBtn.tag = 2000 + i;
    [view addSubview:moreBtn];
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).offset(-8);
        make.centerY.equalTo(@0);
        make.width.height.mas_equalTo(30);
    }];

}

- (void)doMore:(UIButton *)sender{
    if (self.doMoreAction){
        self.doMoreAction();
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
