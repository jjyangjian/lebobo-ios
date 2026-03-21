//
//  audioPlayView.m
//  YBEducation
//
//  Created by IOS1 on 2020/3/17.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "audioPlayView.h"

@implementation audioPlayView{
    BOOL isTry;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)dealloc{
    [self resetPlayer];
}
- (void)resetPlayer{
    if (_voicePlayer) {
        [_voicePlayer resetWMPlayer];
    }

}

- (IBAction)playBtnClick:(id)sender {
    _playBtn.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _playBtn.userInteractionEnabled = YES;
    });
    if (_playBtn.selected == NO) {
        [_voicePlayer play];
        _playBtn.selected = YES;
    }else{
        if (_voicePlayer) {
            [_voicePlayer pause];
        }
        _playBtn.selected = NO;

    }


}
- (IBAction)sliderValueChange:(UISlider *)sender {
}
- (IBAction)UIControlEventTouchUpOutside:(id)sender {

}
- (IBAction)touchupinside:(id)sender {
    CGFloat currentTime = _slider.value * _allCount;
//    [_voicePlayer seekToTime:CMTimeMakeWithSeconds(currentTime,_currentItem.currentTime.timescale)];
    [_voicePlayer seekToTimeToPlay:currentTime];
    _timeL.text =[NSString stringWithFormat:@"%.2d:%.2d",(int)currentTime/60,(int)currentTime%60];
    [_voicePlayer play];
}

- (IBAction)sliderTouchDown:(id)sender {
//    CGFloat currentTime = _slider.value * _allCount;
////    [_voicePlayer seekToTime:CMTimeMakeWithSeconds(currentTime,_currentItem.currentTime.timescale)];
//    [_voicePlayer seekToTimeToPlay:currentTime];
//    _timeL.text =[NSString stringWithFormat:@"%.2d:%.2d",(int)currentTime/60,(int)currentTime%60];

}
- (IBAction)sliderTouchUpInSide:(id)sender {
    [_voicePlayer pause];
}
-(void)setAllCount:(int)allCount{

}

- (void)playerReadyToPlay:(NSString *)url{
    WMPlayerModel *model = [[WMPlayerModel alloc]init];
    model.videoURL = [NSURL URLWithString:url];
    model.title = @"";
    if(self.voicePlayer==nil){
        self.voicePlayer = [[WMPlayer alloc] initPlayerModel:model];
    }
    self.voicePlayer.frame = CGRectZero;
    self.voicePlayer.backBtnStyle = BackBtnStylePop;
    self.voicePlayer.loopPlay = NO;//设置是否循环播放
    self.voicePlayer.tintColor = normalColors;//改变播放器着色
    self.voicePlayer.enableBackgroundMode = YES;//开启后台播放模式
    self.voicePlayer.delegate = self;
//    self.voicePlayer.topView.hidden = YES;
    [self.voicePlayer setPlayerLayerGravity:WMPlayerLayerGravityResizeAspect];
    self.voicePlayer.hidden = YES;
    [self addSubview:self.voicePlayer];
    [self.voicePlayer creatWMPlayerAndReadyToPlay];

}
//准备播放的代理方法
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    _allCount = (int)_voicePlayer.totalTime;
    _allTimeL.text =[NSString stringWithFormat:@"%.2d:%.2d",(int)_allCount/60,(int)_allCount%60];
    _playBtn.selected = YES;
}
//播放进度的代理方法
-(void)wmplayerPlayTime:(WMPlayer *)wmplayer currentTime:(CGFloat)time{
    _timeL.text =[NSString stringWithFormat:@"%.2d:%.2d",(int)time/60,(int)time%60];
    _slider.value = time/wmplayer.totalTime;
    if (isTry) {
        if (time >= [minstr([_courseDic valueForKey:@"trialval"]) intValue]) {
            [wmplayer seekToTimeToPlay:[minstr([_courseDic valueForKey:@"trialval"]) intValue]];
            [wmplayer pause];
            self.userInteractionEnabled = NO;
            if (self.delegate) {
                [self.delegate tryPlayOver];
            }
        }
    }

}
//播放完毕的代理方法
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    _playBtn.selected = NO;
}

- (void)setCourseDic:(NSDictionary *)courseDic{
    _courseDic = courseDic;
    if ([minstr([_courseDic valueForKey:@"trialtype"]) isEqual:@"2"]) {
        isTry = YES;

    }else{
        isTry = NO;
    }


}
@end
