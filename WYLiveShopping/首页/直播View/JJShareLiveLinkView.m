//
//  JJShareLiveLinkView.m
//  testaaa
//
//  Created by 牛环环 on 2026/3/26.
//

#import "JJShareLiveLinkView.h"
#import <Masonry.h>

@interface JJShareLiveLinkView ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *linkLabel;
@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation JJShareLiveLinkView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    
    // 背景view（负责半透明渐变）
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:self.bgView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    // 点击透明部分收起
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.bgView addGestureRecognizer:tapGesture];
    
    // 内容视图
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    [self addSubview:self.contentView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
//        make.height.mas_equalTo(200);
    }];
    
    // 标题
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"分享直播间";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self.contentView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(20);
    }];
    
    // 链接框
    UIView *linkContainerView = [[UIView alloc] init];
    linkContainerView.backgroundColor = UIColor.whiteColor;
    [self.contentView addSubview:linkContainerView];
    
    [linkContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
    }];
    
    self.linkLabel = [[UILabel alloc] init];
    self.linkLabel.text = self.linkText;
    self.linkLabel.numberOfLines = 5;
    self.linkLabel.font = [UIFont systemFontOfSize:14];
    self.linkLabel.textColor = UIColor.blackColor;
    [linkContainerView addSubview:self.linkLabel];
    
    [self.linkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(linkContainerView).offset(15);
        make.right.equalTo(linkContainerView).offset(-15);
        make.top.equalTo(linkContainerView).offset(15);
        make.bottom.equalTo(linkContainerView).offset(-15);
    }];
    
    // 复制按钮
    self.doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.doneButton setTitle:@"复制链接" forState:UIControlStateNormal];
    [self.doneButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.doneButton.backgroundColor = UIColor.orangeColor;
    self.doneButton.layer.cornerRadius = 20;
    [self.doneButton addTarget:self action:@selector(doneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.doneButton];
    
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(linkContainerView.mas_bottom).offset(20);
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(-44);
    }];
}

- (void)setLinkText:(NSString *)linkText {
    _linkText = linkText;
    self.linkLabel.text = linkText;
}

- (void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    self.bgView.alpha = 0;
    self.contentView.transform = CGAffineTransformMakeTranslation(0, 200);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.bgView.alpha = 1;
        self.contentView.transform = CGAffineTransformIdentity;
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.bgView.alpha = 0;
        self.contentView.transform = CGAffineTransformMakeTranslation(0, 200);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.dismissBlock) {
            self.dismissBlock();
        }
    }];
}

- (void)doneButtonTapped {
    if (self.linkText) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.linkText;
        if (self.doneBlock) {
            self.doneBlock();
        }
        [self dismiss];

    }
}

@end
