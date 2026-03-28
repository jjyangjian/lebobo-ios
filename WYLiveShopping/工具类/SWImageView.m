//
//  YBImageView.m
//  yunbaolive
//
//  Created by IOS1 on 2019/3/1.
//  Copyright © 2019 cat. All rights reserved.
//

#import "SWImageView.h"
#import "SWShowBigImageView.h"
#import "SDWebImageDownloader.h"

@interface SWImageView ()<UIScrollViewDelegate>
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UILabel *indexLabel;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIView *navigationView;
@property (nonatomic, assign) BOOL isMine;
@property (nonatomic, copy) YBImageViewBlock returnBlock;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@end

@implementation SWImageView

- (instancetype)initWithImageArray:(NSArray *)array andIndex:(NSInteger)index andMine:(BOOL)ismine andBlock:(nonnull YBImageViewBlock)block {
    self = [super init];
    self.isMine = ismine;
    self.imageArray = [array mutableCopy];
    self.currentIndex = index;
    self.returnBlock = block;
    self.frame = CGRectMake(0, 0, _window_width, _window_height);
    if (self) {
        self.userInteractionEnabled = YES;
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavi)];
        [self addGestureRecognizer:self.tapGesture];

        self.backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(_window_width / 2, _window_height / 2, 0, 0)];
        self.backScrollView.backgroundColor = [UIColor blackColor];
        self.backScrollView.contentSize = CGSizeMake(_window_width * self.imageArray.count, 0);
        self.backScrollView.contentOffset = CGPointMake(_window_width * index, 0);
        self.backScrollView.delegate = self;
        self.backScrollView.pagingEnabled = YES;
        self.backScrollView.maximumZoomScale = 1;
        self.backScrollView.minimumZoomScale = 1;
        self.backScrollView.showsHorizontalScrollIndicator = NO;
        self.backScrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.backScrollView];

        self.imageViewArray = [NSMutableArray array];
        for (int i = 0; i < self.imageArray.count; i++) {
            id imageContent = self.imageArray[i];
            SWShowBigImageView *imageView = [[SWShowBigImageView alloc] initWithFrame:CGRectMake(_window_width * i, 0, _window_width, _window_height)];
            if ([imageContent isKindOfClass:[UIImage class]]) {
                imageView.imageView.image = imageContent;
            } else if ([imageContent isKindOfClass:[NSString class]]) {
                [imageView.imageView sd_setImageWithURL:[NSURL URLWithString:imageContent]];
            } else if ([imageContent isKindOfClass:[NSDictionary class]]) {
                [imageView.imageView sd_setImageWithURL:[NSURL URLWithString:minstr([imageContent valueForKey:@"thumb"])]];
            }
            [self.backScrollView addSubview:imageView];
            [self.imageViewArray addObject:imageView];
        }
        [self showBigView];
        [self creatNavi];
    }
    return self;
}

- (void)showBigView {
    [UIView animateWithDuration:0.2 animations:^{
        self.backScrollView.frame = CGRectMake(0, 0, _window_width, _window_height);
    }];
}

- (void)doreturn {
    [UIView animateWithDuration:0.2 animations:^{
        self.backScrollView.frame = CGRectMake(_window_width / 2, _window_height / 2, 0, 0);
    } completion:^(BOOL finished) {
        if (self.returnBlock) {
            self.returnBlock(self.imageArray);
        }
        [self.backScrollView removeFromSuperview];
        self.backScrollView = nil;
        [self removeFromSuperview];
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentIndex = scrollView.contentOffset.x / _window_width;
    self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.currentIndex + 1, self.imageArray.count];
}

- (void)creatNavi {
    self.navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, 64 + statusbarHeight)];
    self.navigationView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self addSubview:self.navigationView];

    UIButton *returnButton = [UIButton buttonWithType:0];
    returnButton.frame = CGRectMake(10, 25 + statusbarHeight, 30, 30);
    [returnButton setImage:[UIImage imageNamed:@"navi_backImg"] forState:0];
    [returnButton addTarget:self action:@selector(doreturn) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationView addSubview:returnButton];

    self.indexLabel = [[UILabel alloc] init];
    self.indexLabel.frame = CGRectMake(_window_width / 2 - 40, 22 + statusbarHeight, 80, 30);
    self.indexLabel.textColor = [UIColor whiteColor];
    self.indexLabel.font = [UIFont systemFontOfSize:15];
    self.indexLabel.textAlignment = NSTextAlignmentCenter;
    self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.currentIndex + 1, self.imageArray.count];
    [self.navigationView addSubview:self.indexLabel];

//    id imageContent = [self.imageArray firstObject];
//    if ([imageContent isKindOfClass:[UIImage class]] || self.isMine) {
//        self.deleteButton = [UIButton buttonWithType:0];
//        self.deleteButton.frame = CGRectMake(0, _window_height - 40, _window_width, 40);
//        self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:14];
//        [self.deleteButton addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
//        [self.deleteButton setTitle:@"删除" forState:0];
//        [self.deleteButton setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
//        [self addSubview:self.deleteButton];
//    }
}

- (void)deleteBtnClick {
    if (self.isMine) {
        [MBProgressHUD showMessage:@""];
        NSString *thumbID = minstr([self.imageArray[self.currentIndex] valueForKey:@"id"]);
        NSMutableDictionary *mutableDictionary = @{
            @"uid": [SWConfig getOwnID],
            @"token": [SWConfig getOwnToken],
            @"id": thumbID,
        }.mutableCopy;
        NSString *sign = [SWToolClass sortString:mutableDictionary];
        [mutableDictionary setObject:sign forKey:@"sign"];

        [SWToolClass postNetworkWithUrl:@"Photo.DelPhoto" andParameter:mutableDictionary success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:msg];
            if (code == 0) {
                [self deleteSucess];
            }
        } fail:^{
            [MBProgressHUD hideHUD];
        }];
    } else {
        [self deleteSucess];
    }
}

- (void)deleteSucess {
    [self.imageArray removeObjectAtIndex:self.currentIndex];
    if (self.imageArray.count == 0) {
        [self doreturn];
    } else {
        UIImageView *imageView = self.imageViewArray[self.currentIndex];
        [imageView removeFromSuperview];
        [self.imageViewArray removeObjectAtIndex:self.currentIndex];
        if (self.currentIndex == 0) {
            self.currentIndex = 0;
        } else {
            self.currentIndex -= 1;
        }
        self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.currentIndex + 1, self.imageArray.count];
        self.backScrollView.contentSize = CGSizeMake(_window_width * self.imageArray.count, 0);
        [self.backScrollView setContentOffset:CGPointMake(_window_width * self.currentIndex, 0)];
        for (int i = 0; i < self.imageViewArray.count; i++) {
            SWShowBigImageView *imageView = self.imageViewArray[i];
            imageView.x = _window_width * i;
        }
    }
}

- (void)showHideNavi {
    self.navigationView.hidden = !self.navigationView.hidden;
    if (self.deleteButton) {
        self.deleteButton.hidden = self.navigationView.hidden;
    }
}

@end
