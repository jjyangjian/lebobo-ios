//
//  YBScorllTextLable.m
//  YBPlaying
//
//  Created by IOS1 on 2019/12/17.
//  Copyright © 2019 IOS1. All rights reserved.
//

#import "SWScorllTextLable.h"

@interface SWScorllTextLable ()
@property (nonatomic, assign) CGFloat widthValue;
@property (nonatomic, assign) CGFloat heightValue;
@property (nonatomic, assign) CGFloat textWidth;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat distance;
@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;
@end

@implementation SWScorllTextLable

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.widthValue = frame.size.width;
        self.heightValue = frame.size.height;
        [self initUSerInterface];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 100, 30)];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.widthValue = self.frame.size.width;
    self.heightValue = self.frame.size.height;
    [self initUSerInterface];
    [self start];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.widthValue = self.frame.size.width;
    self.heightValue = self.frame.size.height;
    [self labelAttrbuits];
    [self start];
}

#pragma mark -- private

- (void)initUSerInterface {
    self.clipsToBounds = YES;
    self.distance = self.rate > 0 ? self.rate * 10 : 5;
    self.interval = self.interval > 0 ? self.interval : 70;
    self.style = YBTextCycleStyleDefault;
    [self creatLabel];
}

- (void)creatLabel {
    self.label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.widthValue, self.heightValue)];
    self.label2 = [[UILabel alloc] initWithFrame:CGRectMake(self.widthValue, 0, self.widthValue, self.heightValue)];
    if (self.textColor) {
        self.label1.textColor = self.label2.textColor = self.textColor;
    }
    if (self.text && self.text.length > 0) {
        self.label1.text = self.label2.text = self.text;
    }
    [self addSubview:self.label1];
    [self addSubview:self.label2];
}

- (void)labelAttrbuits {
    [self.label1 sizeToFit];
    [self.label2 sizeToFit];
    self.textWidth = CGRectGetWidth(self.label1.frame);
    self.label1.center = CGPointMake(self.textWidth / 2, self.heightValue / 2.0);
    self.label2.center = CGPointMake(self.textWidth / 2 + self.widthValue, self.heightValue / 2.0);
}

- (void)labelChange {
    if (self.style == YBTextCycleStyleDefault && self.textWidth < self.widthValue) {
        [self stop];
        return;
    }

    CGRect frame1 = self.label1.frame;
    CGFloat maxX1 = CGRectGetMaxX(self.label1.frame);
    CGRect frame2 = self.label2.frame;
    CGFloat maxX2 = CGRectGetMaxX(self.label2.frame);

    if (self.widthValue - maxX1 >= self.interval || (frame2.origin.x > -self.textWidth && maxX2 < self.widthValue + self.textWidth)) {
        frame2.origin.x -= self.distance;
    }

    if (self.widthValue - maxX2 >= self.interval || (frame1.origin.x > -self.textWidth && maxX1 < self.widthValue + self.textWidth)) {
        frame1.origin.x -= self.distance;
    }

    if (maxX1 < -3) {
        frame1.origin.x = self.widthValue;
    }

    if (maxX2 < -3) {
        frame2.origin.x = self.widthValue;
    }

    self.label1.frame = frame1;
    self.label2.frame = frame2;
}

#pragma mark -- timer

- (void)start {
    if (!self.timer) {
        __weak typeof(self) weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf labelChange];
        }];
        return;
    }
    self.timer.fireDate = [NSDate date];
}

- (void)pause {
    self.timer.fireDate = [NSDate distantFuture];
}

- (void)stop {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark -- setter

- (void)setText:(NSString *)text {
    _text = text;
    self.label1.text = self.label2.text = text;
    self.clipsToBounds = YES;
    [self labelAttrbuits];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.label1.font = self.label2.font = font;
    [self labelAttrbuits];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.label1.textColor = self.label2.textColor = textColor;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    self.label1.textAlignment = self.label2.textAlignment = textAlignment;
}

- (void)setStyle:(YBTextCycleStyle)style {
    _style = style;
    [self start];
}

- (void)setRate:(CGFloat)rate {
    _rate = rate > 1 ? 1 : rate;
    _rate = _rate < 0 ? 0 : _rate;
    self.distance = _rate * 10;
}

- (void)setInterval:(CGFloat)interval {
    _interval = interval;
}

@end
