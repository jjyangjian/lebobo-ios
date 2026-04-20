//
//  SWYBVideoControlView.m
//  yunbaolive
//
//  Created by ybRRR on 2020/9/18.
//  Copyright © 2020 cat. All rights reserved.
//

#import "SWYBVideoControlView.h"

@implementation SWYBVideoControlView
@synthesize player = _player;
- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.playButton];
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 100;
    CGFloat min_h = 100;
    self.playButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.playButton.center = self.center;
}

#pragma mark - eeee

-(void)controlSingleTapped {
    if (self.player.currentPlayerManager.isPlaying) {
        [self.player.currentPlayerManager pause];
        NSLog(@"22222===:%lu",self.player.currentPlayerManager.playState);
        self.playButton.hidden = NO;
        self.playButton.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        [UIView animateWithDuration:0.2f delay:0
                            options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.playButton.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
        }];
    } else {
        [self.player.currentPlayerManager play];
        self.playButton.hidden = YES;
    }
}
-(void)pauseVideo{
    [self.player.currentPlayerManager pause];
    NSLog(@"22222===:%lu",self.player.currentPlayerManager.playState);
    self.playButton.hidden = NO;
    self.playButton.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    [UIView animateWithDuration:0.2f delay:0
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.playButton.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];

}

- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
    
    if (self.ybContorEvent) {
        self.ybContorEvent(@"控制-单击",gestureControl);
    }
}

#pragma mark - sss
- (void)gestureDoubleTapped:(ZFPlayerGestureControl *)gestureControl {
    if (self.ybContorEvent) {
        self.ybContorEvent(@"控制-双击",gestureControl);
    }
}

- (void)gestureEndedPan:(ZFPlayerGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location;{
    if (direction == 2 && location == 2) {
        //侧滑进入个人主页
        if (self.ybContorEvent) {
            self.ybContorEvent(@"控制-主页",gestureControl);
        }
    }
    NSLog(@"rk_____end--dir:%lu==loc:%lu",(unsigned long)direction,(unsigned long)location);
}
- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.userInteractionEnabled = NO;
        [_playButton setImage:[UIImage imageNamed:@"ask_play"] forState:UIControlStateNormal];
        _playButton.hidden = YES;
    }
    return _playButton;
}

@end
