//
//  SWHomeVideoView.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/31.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWHomeVideoView.h"
#import "SWYBLookVideoVC.h"
#import "SWCourseDetaileVC.h"
@implementation SWHomeVideoView{
    UIImageView *_backImgV;
    UILabel *_looksL;
    UIButton *_likeBtn;
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
//    backImgV.backgroundColor = YBRandomColor;
    [self addSubview:backImgV];
    _backImgV = backImgV;
    UILabel *likesL = [[UILabel alloc]init];
    likesL.text = @"1.8W";
    likesL.font = SYS_Font(10);
    likesL.textColor = [UIColor whiteColor];
    [self addSubview:likesL];
    [likesL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-5);
        make.right.equalTo(self).offset(-3);
    }];
    _looksL = likesL;
    UIButton *likeBtn = [UIButton buttonWithType:0];
    [likeBtn setImage:[UIImage imageNamed:@"home-video-palys"] forState:0];
    likeBtn.userInteractionEnabled = NO;
    [self addSubview:likeBtn];
    [likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(likesL);
        make.right.equalTo(likesL.mas_left).offset(-3);
        make.width.height.mas_equalTo(10);
    }];
    _likeBtn = likeBtn;
    
    UIButton *clickBtn = [UIButton buttonWithType:0];
    [clickBtn addTarget:self action:@selector(doCLick) forControlEvents:UIControlEventTouchUpInside];
    clickBtn.frame = CGRectMake(0, 0, self.width, self.height);
    [self addSubview:clickBtn];
}
- (void)setMsgDic:(NSDictionary *)msgDic{
    _msgDic = msgDic;
    _looksL.text = minstr([_msgDic valueForKey:@"plays"]);
    [_backImgV sd_setImageWithURL:[NSURL URLWithString:minstr([_msgDic valueForKey:@"thumb"])]];

}
- (void)setIsVideo:(BOOL)isVideo{
    _isVideo = isVideo;
    _likeBtn.hidden = !_isVideo;
    _looksL.hidden = !_isVideo;
}
- (void)doCLick{
    NSLog(@"%@",_isVideo?@"video":@"course");
    if (_isVideo) {
        SWYBLookVideoVC *video = [[SWYBLookVideoVC alloc]init];
        
        video.fromWhere = @"myVideoV";
        video.pushPlayIndex = 0;
        video.videoList = @[_msgDic].mutableCopy;
        video.pages = 1;
        video.sourceBaseUrl = @"";
        [[SWMXBADelegate sharedAppDelegate] pushViewController:video animated:YES];

    }else{
        SWCourseModel *model = [[SWCourseModel alloc]initWithDic:_msgDic];;
        SWCourseDetaileVC *vc = [[SWCourseDetaileVC alloc]init];
        vc.model = model;
        [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];

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
