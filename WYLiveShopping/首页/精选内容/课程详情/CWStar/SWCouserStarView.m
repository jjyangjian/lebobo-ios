//
//  YBStarView.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/19.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWCouserStarView.h"

@implementation SWCouserStarView{
    NSMutableArray *starArray;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        starArray = [NSMutableArray array];
        [self creatUI];
    }
    return self;
}

-(instancetype)init{
    if (self = [super init]) {
        starArray = [NSMutableArray array];
        [self creatUI];
    }
    return self;
}
- (void)creatUI{
    MASViewAttribute *left = self.mas_left;
    for (int i = 0; i< 5; i ++) {
        UIImageView *imgV = [[UIImageView alloc]init];
        imgV.image = [UIImage imageNamed:@"b27_icon_star_yellow"];
        imgV.hidden = YES;
        [self addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.height.equalTo(self);
            make.width.equalTo(imgV.mas_height);
            make.left.equalTo(left).offset(3);
        }];
        left = imgV.mas_right;
        [starArray addObject:imgV];
    }
}
- (void)setCurIndex:(int)index andStartingDirectionLeft:(BOOL)isLeft{
    for (UIImageView *imgV in starArray) {
        imgV.hidden = YES;
    }
    if (isLeft) {
        for (int i = 0; i < index; i ++) {
            UIImageView *imgV = starArray[i];
            imgV.hidden = NO;
        }
    }else{
        for (int i = 5; i > (5-index); i --) {
            UIImageView *imgV = starArray[i-1];
            imgV.hidden = NO;
        }

    }
}
@end
