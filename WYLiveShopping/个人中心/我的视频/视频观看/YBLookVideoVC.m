//
//  YBLookVideoVC.m
//  yunbaolive
//
//  Created by ybRRR on 2020/9/17.
//  Copyright © 2020 cat. All rights reserved.
//

#import "YBLookVideoVC.h"
#import "YBLookVideoCell.h"
#import <HPGrowingTextView/HPGrowingTextView.h>
#import "twEmojiView.h"
#import "commentview.h"
#import "videoMoreView.h"
#import "jubaoVC.h"
#import "YBVideoControlView.h"
#import "lookVGoodsDView.h"

static NSString * const reuseIdentifier = @"collectionViewCell";

@interface YBLookVideoVC ()<UICollectionViewDelegate,UICollectionViewDataSource,HPGrowingTextViewDelegate,twEmojiViewDelegate>
{
    int _lastPlayCellIndex;
    NSIndexPath *_lastPlayIndexPath;
    NSDictionary *_currentVideoDic;
    CGFloat lastContenOffset;
    BOOL _isFirstPlay;
    BOOL _isLoadingMore;                //列表是否正在加载总

    UIView *_toolBar;
    twEmojiView *_emojiV;
    lookVGoodsDView *goodsDView;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) NSMutableArray *videoUrls;
@property(nonatomic,strong)NSString *hostID;    //视频主人ID
@property(nonatomic,copy)NSString *videoID;     //视频id
@property(nonatomic,strong)UIButton *goBackBtn;
@property(nonatomic,strong)UIButton *goBackShadow;
@property(nonatomic,strong)commentview *comment;                     //评论
@property(nonatomic,strong)HPGrowingTextView *textField;
@property(nonatomic,strong)UIButton *finishbtn;
@property(nonatomic,strong)videoMoreView *videomore;                 //分享view
@property (nonatomic, strong) YBVideoControlView *controlView;
@property(nonatomic,strong)YBLookVideoCell *playingCell;

@end

@implementation YBLookVideoVC

-(void)initData{
    _lastPlayCellIndex = -1;
    _currentVideoDic = @{};
    lastContenOffset = 0;
    _isFirstPlay = NO;
    _isLoadingMore = NO;

    self.videoUrls = [NSMutableArray array];
    for (NSDictionary *subDic in _videoList) {
        NSString * videoUrl = minstr([subDic valueForKey:@"url"]);
        [_videoUrls addObject:[NSURL URLWithString:videoUrl]];
    }

}
-(void)viewWillAppear:(BOOL)animated{
    [[WYToolClass sharedInstance] removeSusPlayer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"=====home:%lu",(unsigned long)self.player.currentPlayerManager.playState);
//    [self.player stopCurrentPlayingCell];
//    [_controlView controlSingleTapped];
    [_controlView pauseVideo];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (_controlView.playBtn.hidden == NO) {
        return;
    }
//    [_controlView controlSingleTapped];
    [self startPlayerVideo];

}
-(void)startPlayerVideo {
    @weakify(self)
    [self.collectionView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
        @strongify(self)
        [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
    }];
}
-(void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification object:nil];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviView.hidden = YES;

    [self initData];
    [self addNotifications];
    [self.view addSubview:self.collectionView];

    /// playerManager
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    playerManager.requestHeader = @{@"Referer":h5url};
    playerManager.scalingMode = ZFPlayerScalingModeAspectFill;
    playerManager.view.backgroundColor = [UIColor clearColor];
//KSMediaPlayer 设置referer需要在 KSMediaPlayerManager 的初始化里边
//KSMediaPlayerManager *playerManager = [[KSMediaPlayerManager alloc]init];
// player的tag值必须在cell里设置
    self.player = [ZFPlayerController playerWithScrollView:self.collectionView playerManager:playerManager containerViewTag:191107];
    self.player.controlView = self.controlView;
    self.player.assetURLs = self.videoUrls;
    self.player.shouldAutoPlay = YES;
    self.player.allowOrentitaionRotation = NO;
    self.player.WWANAutoPlay = YES;
    //不支持的方向
    self.player.disablePanMovingDirection = ZFPlayerDisablePanMovingDirectionVertical;
    //不支持的手势类型
    self.player.disableGestureTypes =  ZFPlayerDisableGestureTypesPinch;
    /// 1.0是消失100%时候
    self.player.playerDisapperaPercent = 1.0;
    
    @weakify(self)
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        [self setNeedsStatusBarAppearanceUpdate];
        self.collectionView.scrollsToTop = !isFullScreen;
    };
    self.player.presentationSizeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, CGSize size) {
        NSLog(@"size:\n%.f %f",size.width,size.height);
        @strongify(self)
        if (size.width >= size.height) {
            self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFit;
        } else {
            self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFill;
        }
    };
    //功能
    self.player.playerPrepareToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        NSLog(@"准备");
        @strongify(self)
        self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFill;
        _isFirstPlay = YES;
        [self startWatchVideo];
        [self videoStart];
    };
    self.player.playerReadyToPlay = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
//        @strongify(self)
//        self.playingCell.bgImgView.image = nil;
    };
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        NSLog(@"结束");
        @strongify(self)
        [self.player.currentPlayerManager replay];
//        if (_isFirstPlay == YES) {
//            _isFirstPlay = NO;
//            [self videoEnd];
//
////            [self addLookTimeForToday:[NSString stringWithFormat:@"%.0f",self.player.totalTime]];
//        }
    };
    self.player.zf_playerDisappearingInScrollView = ^(NSIndexPath * _Nonnull indexPath, CGFloat playerDisapperaPercent) {
        @strongify(self);
        //这里代表将要切换视频
        if (playerDisapperaPercent == 1) {
            NSLog(@"100%%消失:%f",self.player.currentTime);
            _controlView.playBtn.hidden = YES;
//            YBLookVideoCell *disCell = (YBLookVideoCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
//            [disCell releaseObj:self.videoList[indexPath.row] isBackGround:NO];
//            //上一个结束动画
//            [disCell stopMusicAnimation:self.videoList[indexPath.row]];
        }
    };
    [self.player stopCurrentPlayingCell];
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_pushPlayIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];

    [self.view addSubview:self.goBackBtn];
    [self showtextfield];


}
- (YBVideoControlView *)controlView {
    if (!_controlView) {
        _controlView = [YBVideoControlView new];
        @weakify(self);
        _controlView.ybContorEvent = ^(NSString *eventStr, ZFPlayerGestureControl *gesControl) {
            @strongify(self);
            [self contorEvent:eventStr andGes:gesControl];
        };
    }
    return _controlView;
}
- (YBLookVideoCell *)playingCell {
    _playingCell = (YBLookVideoCell*)[_collectionView cellForItemAtIndexPath:self.player.playingIndexPath];
    return _playingCell;
}

-(void)contorEvent:(NSString *)eventStr andGes:(ZFPlayerGestureControl*)gesControl{
    if ([eventStr isEqual:@"控制-单击"]) {
        if (_videomore && _videomore.y < _window_height) {
            [self hideMoreView];

        }else if (_textField.isFirstResponder ){
            [_textField resignFirstResponder];

        }else if (_emojiV.y == _window_height - (EmojiHeight+ShowDiff))
        {
            [UIView animateWithDuration:0.1 animations:^{
                _toolBar.frame = CGRectMake(0, _window_height - 50-statusbarHeight, _window_width, 50+statusbarHeight);
                //_toolBar.frame = CGRectMake(0, _window_height + 10, _window_width, 50);
                _emojiV.frame = CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff);
                _toolBar.backgroundColor = [RGB(32, 28, 54) colorWithAlphaComponent:0.2];//RGB(27, 25, 41);;//RGB(248, 248, 248);
                _textField.backgroundColor = [UIColor clearColor];
            }];

        } else {
            [_controlView controlSingleTapped];
        }
    }
    if ([eventStr isEqual:@"控制-双击"]) {
    }
    if ([eventStr isEqual:@"控制-主页"]) {
        [self.playingCell zhuboMessage];
    }
}

#pragma mark - 输入框
-(void)showtextfield{
    if (!_toolBar) {
        _toolBar = [[UIView alloc]initWithFrame:CGRectMake(0,_window_height - 50-ShowDiff, _window_width, 50+ShowDiff)];
        _toolBar.backgroundColor = RGB_COLOR(@"#000000", 0.2);//RGB(27, 25, 41);;//RGB(248, 248, 248);
        [self.view addSubview:_toolBar];
        
        //设置输入框
        UIView *vc  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        vc.backgroundColor = [UIColor clearColor];
        _textField = [[HPGrowingTextView alloc]initWithFrame:CGRectMake(10,8, _window_width - 68, 34)];
        _textField.layer.masksToBounds = YES;
        _textField.layer.cornerRadius = 17;
        _textField.font = SYS_Font(16);
        _textField.placeholder = @"说点什么...";
        _textField.textColor = [UIColor blackColor];
        _textField.placeholderColor = color96;
        _textField.delegate = self;
        _textField.returnKeyType = UIReturnKeySend;
        _textField.enablesReturnKeyAutomatically = YES;
        
        _textField.internalTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingHead;
        _textField.internalTextView.textContainer.maximumNumberOfLines = 1;
        
        /**
         * 由于 _textField 设置了contentInset 后有色差，在_textField后添
         * 加一个背景view并把_textField设置clearColor
         */
        _textField.contentInset = UIEdgeInsetsMake(2, 10, 2, 10);
        _textField.backgroundColor = [UIColor clearColor];
        UIView *tv_bg = [[UIView alloc]initWithFrame:_textField.frame];
        tv_bg.backgroundColor = RGB_COLOR(@"#ffffff", 0.1);
        tv_bg.layer.masksToBounds = YES;
        tv_bg.layer.cornerRadius = _textField.layer.cornerRadius;
        [_toolBar addSubview:tv_bg];
        [_toolBar addSubview:_textField];
        
        _finishbtn = [UIButton buttonWithType:0];
        _finishbtn.frame = CGRectMake(_window_width - 44,8,34,34);
        [_finishbtn setImage:[UIImage imageNamed:@"chat_face.png"] forState:0];
        [_finishbtn setImage:[UIImage imageNamed:@"chat_keyboard"] forState:UIControlStateSelected];
        [_finishbtn addTarget:self action:@selector(atFrends) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:_finishbtn];
    }
    if (!_emojiV) {
        _emojiV = [[twEmojiView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff)];
        _emojiV.delegate = self;
        [self.view addSubview:_emojiV];
    }

}
#pragma mark - 召唤好友
-(void)atFrends {

    _finishbtn.selected = !_finishbtn.selected;
    if (!_finishbtn.selected) {
        [_textField becomeFirstResponder];
    }else{
        [_textField resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            _emojiV.frame = CGRectMake(0, _window_height - (EmojiHeight+ShowDiff), _window_width, EmojiHeight+ShowDiff);
            _toolBar.frame = CGRectMake(0, _emojiV.y - 50, _window_width, 50);
            _toolBar.backgroundColor = RGB_COLOR(@"#f4f5f6", 1);
            _textField.backgroundColor = [UIColor whiteColor];
        }];
    }
}

#pragma mark - Emoji 代理
-(void)sendimage:(NSString *)str {
    if ([str isEqual:@"msg_del"]) {
        [_textField.internalTextView deleteBackward];
    }else {
        [_textField.internalTextView insertText:str];
    }
}
-(void)clickSendEmojiBtn {
    [self pushmessage];
}


#pragma mark - set/get
- (UIButton *)goBackBtn{
    if (!_goBackBtn) {
        //左
        _goBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goBackBtn.frame = CGRectMake(10, 22+statusbarHeight, 40, 40);
        _goBackBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [_goBackBtn setImage:[UIImage imageNamed:@"navi_backImg_white"] forState:0];
        [_goBackBtn addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
        
        //左shadow
        _goBackShadow = [UIButton buttonWithType:UIButtonTypeCustom];
        _goBackShadow.frame = CGRectMake(0, 0, 64, 64+statusbarHeight);
        [_goBackShadow addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
        _goBackShadow.backgroundColor = [UIColor clearColor];
    }
    return _goBackBtn;
}

#pragma mark - 点击事件
-(void)clickLeftBtn {
    [self endWatchVideo];
    [self.player stopCurrentPlayingCell];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - set/get
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemWidth = self.view.frame.size.width;
        CGFloat itemHeight = self.view.frame.size.height;
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        layout.sectionInset = UIEdgeInsetsZero;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        if (self.scrollViewDirection == ZFPlayerScrollViewDirectionVertical) {
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        } else if (self.scrollViewDirection == ZFPlayerScrollViewDirectionHorizontal) {
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor blackColor];
        /// 横向滚动 这行代码必须写
        _collectionView.zf_scrollViewDirection = self.scrollViewDirection;
        [_collectionView registerClass:[YBLookVideoCell class] forCellWithReuseIdentifier:reuseIdentifier];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.scrollsToTop = NO;
        _collectionView.bounces = NO;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        /// 停止的时候找出最合适的播放
        @weakify(self)
        _collectionView.zf_scrollViewDidStopScrollCallback = ^(NSIndexPath * _Nonnull indexPath) {
            @strongify(self)
            if (self.player.playingIndexPath) return;
            if (indexPath.row + 1 >= _videoList.count) {
                /// 加载下一页数据
                _pages += 1;
                [MBProgressHUD showMessage:@""];
                [self pullData];
            }else {
                [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
            }
        };
    }
    return _collectionView;
}

#pragma mark - UIScrollViewDelegate  列表播放必须实现
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidEndDecelerating];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView zf_scrollViewDidEndDraggingWillDecelerate:decelerate];
    if (!decelerate) {
        if (self.player.currentPlayIndex == 0 ) {
            [MBProgressHUD showError:(@"已经到顶了哦")];
        }
        if (self.player.currentPlayIndex+1 == _videoList.count) {
            [MBProgressHUD showError:(@"没有更多视频")];
        }
    }
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScrollToTop];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScroll];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewWillBeginDragging];
    lastContenOffset = scrollView.contentOffset.y;
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _videoList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WeakSelf;
    YBLookVideoCell *cell = (YBLookVideoCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.player = self.player;
//    cell.fromWhere = _fromWhere;
    cell.dataDic = _videoList[indexPath.row];
    cell.videoCellEvent = ^(NSString *eventType, NSDictionary *eventDic) {
        [weakSelf cellBlockBack:eventType andInfo:eventDic andIndex:indexPath];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [_textField resignFirstResponder];

    if (self.player.currentPlayIndex == indexPath.row) {
        return;
    }
    
    [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
}
#pragma mark - 功能
#pragma mark - cell block回调
-(void)cellBlockBack:(NSString *)eventType andInfo:(NSDictionary *)eventDic andIndex:(NSIndexPath *)indexPath{
    if ([eventType isEqual:@"评论"]) {
        //视频打赏处理
        [self messgaebtnWithIndex:indexPath];
        
    }else if([eventType isEqual:@"视频-删除"]){
        //删除事件特殊处理
        if (!_fromWhere) {
            //推荐删除
            [_videoList removeObjectAtIndex:indexPath.row];
            /* //如果个人主页也要求删除后显示下一个(向上、向下滑),将if条件去掉else语句去掉执行下列if
             if (_fromWhere) {
                [Config saveSignOfDelVideo:@"1"];
                if (_videoList.count==0) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
             }
             */
            [_videoUrls removeAllObjects];
            for (NSDictionary *subDic in _videoList) {
                NSString *videoUrl = minstr([subDic valueForKey:@"href"]);
                [_videoUrls addObject:[NSURL URLWithString:videoUrl]];
            }
            [self.player stopCurrentPlayingCell];
            if (indexPath.row == _videoList.count) {
                //说明删除的是最后一个
                int toIndex = ((int)indexPath.row-1) < 0 ? 0 : ((int)indexPath.row-1);
                indexPath = [NSIndexPath indexPathForRow:toIndex inSection:0];
            }
            [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
            self.player.assetURLs = _videoUrls;
            [self.collectionView reloadData];
            //准备播放
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startPlayerVideo];
            });
        }else {
            //push页面删除
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }else if ([eventType isEqual:@"分享"]) {
        [self doenjoy];
    }else if ([eventType isEqual:@"商品"]) {
        [self showGoodsDeatile];
    }else {
        //默默更新数据
        //视频-关注、视频-点赞、视频-评论
        NSMutableDictionary *m_dic = [NSMutableDictionary dictionaryWithDictionary:_videoList[indexPath.row]];
        [m_dic addEntriesFromDictionary:eventDic];
        [_videoList replaceObjectAtIndex:indexPath.row withObject:m_dic];
        _currentVideoDic = [NSDictionary dictionaryWithDictionary:m_dic];
    }
}

#pragma mark - 播放
/// play the video
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    _lastPlayCellIndex = (int)indexPath.row;
    _lastPlayIndexPath = indexPath;
    _currentVideoDic = _videoList[indexPath.row];
    _videoID = minstr([_currentVideoDic valueForKey:@"id"]);
    _hostID = minstr([_currentVideoDic valueForKey:@"uid"]);
    
    [self.player playTheIndexPath:indexPath scrollToTop:scrollToTop];
}
#pragma mark - private method
-(void)pullData{
    NSString *url = [NSString stringWithFormat:@"%@&page=%@",_sourceBaseUrl,@(_pages)];
    WeakSelf;
    _isLoadingMore = YES;
    [WYToolClass getQCloudWithUrl:url Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [MBProgressHUD hideHUD];
            _isLoadingMore = NO;
        });
        if (code == 200) {
            NSArray *infoA = info;
//            if (infoA.count == 0) {
//                _pages --;
//            }
            if (_pages==1) {
                [_videoList removeAllObjects];
            }
            [_videoList addObjectsFromArray:infoA];
            if (_videoList.count<=0) {
                [MBProgressHUD showError:(@"暂无更多视频哦~")];
            }
        
            [_videoUrls removeAllObjects];
            for (NSDictionary *subDic in _videoList) {
                NSString *videoUrl = minstr([subDic valueForKey:@"url"]);
                [_videoUrls addObject:[NSURL URLWithString:videoUrl]];
            }
            weakSelf.player.assetURLs = _videoUrls;
            [weakSelf.collectionView reloadData];
            //准备播放
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf startPlayerVideo];
            });

        }else{
            [MBProgressHUD showError:msg];
        }
    } Fail:^{
        [MBProgressHUD hideHUD];
        _isLoadingMore = NO;
    }];
    
}

#pragma mark-------每日任务开始观看视频------------------
-(void)startWatchVideo{
    NSDictionary *dic = @{
        @"vid":_videoID,
        @"sign":[WYToolClass sortString:@{@"vid":_videoID}]
    };
    [WYToolClass postNetworkWithUrl:@"setPlays" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            
        } fail:^{
            
        }];
}
#pragma mark-------每日任务结束观看视频------------------
-(void)endWatchVideo{
//    if ([[Config getOwnID] intValue] <= 0) {
//        return;
//    }
//    NSString *url = [purl stringByAppendingFormat:@"?service=Video.endWatchVideo"];
//
//    NSDictionary *dic = @{
//                          @"uid":[Config getOwnID],
//                          @"token":[Config getOwnToken]
//    };
//    [YBNetworking postWithUrl:url Dic:dic Suc:^(NSDictionary *data, NSString *code, NSString *msg) {
//        if ([code isEqual:@"0"]) {
//
//        }else{
//            [MBProgressHUD showError:msg];
//        }
//    } Fail:^(id fail) {
//
//    }];

}
#pragma mark - 视频开始观看-结束观看
-(void)videoStart {
//    if ([[Config getOwnID] intValue] <= 0) {
//        return;
//    }
//
//    if ([_hostID isEqual:[Config getOwnID]]) {
//        return;
//    }
//    NSString *random_str = [PublicObj stringToMD5:[NSString stringWithFormat:@"%@-%@-#2hgfk85cm23mk58vncsark",[Config getOwnID],_videoID]];
//    NSString *url = [purl stringByAppendingFormat:@"?service=Video.addView&uid=%@&token=%@&videoid=%@&random_str=%@",[Config getOwnID],[Config getOwnToken],_videoID,random_str];
//    [YBNetworking postWithUrl:url Dic:nil Suc:^(NSDictionary *data, NSString *code, NSString *msg) {
//        NSLog(@"addview-%@-%@-%@",code,data,msg);
//    } Fail:nil];
}

-(void)videoEnd {
//    if ([[Config getOwnID] intValue] <= 0) {
//        return;
//    }
//
//    if ([_hostID isEqual:[Config getOwnID]]) {
//        return;
//    }
//    NSString *random_str = [PublicObj stringToMD5:[NSString stringWithFormat:@"%@-%@-#2hgfk85cm23mk58vncsark",[Config getOwnID],_videoID]];
//    NSString *url = [purl stringByAppendingFormat:@"?service=Video.setConversion&uid=%@&token=%@&videoid=%@&random_str=%@",[Config getOwnID],[Config getOwnToken],_videoID,random_str];
//    [YBNetworking postWithUrl:url Dic:nil Suc:^(NSDictionary *data, NSString *code, NSString *msg) {
//        NSLog(@"setConversion-%@-%@-%@",code,data,msg);
//    } Fail:nil];
}
#pragma mark - 输入框代理事件
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView;
{
    return YES;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    _textField.height = height;
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView {
    [_textField resignFirstResponder];
    _finishbtn.selected = NO;
    [self pushmessage];
    return YES;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    _finishbtn.selected = NO;
    if ([text isEqualToString:@""]) {
        NSRange selectRange = growingTextView.selectedRange;
        if (selectRange.length > 0) {
            //用户长按选择文本时不处理
            return YES;
        }
        
        // 判断删除的是一个@中间的字符就整体删除
//        NSMutableString *string = [NSMutableString stringWithString:growingTextView.text];
//        NSArray *matches = [self findAllAt];
//
//        BOOL inAt = NO;
//        NSInteger index = range.location;
//        for (NSTextCheckingResult *match in matches) {
//            NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
//            if (NSLocationInRange(range.location, newRange)) {
//                inAt = YES;
//                index = match.range.location;
//                [string replaceCharactersInRange:match.range withString:@""];
//                break;
//            }
//        }
//
//        if (inAt) {
//            growingTextView.text = string;
//            growingTextView.selectedRange = NSMakeRange(index, 0);
//            return NO;
//        }
    }
    
    //判断是回车键就发送出去
    if ([text isEqualToString:@"\n"]) {
        [self pushmessage];
        return NO;
    }
    
    return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    UITextRange *selectedRange = growingTextView.internalTextView.markedTextRange;
    NSString *newText = [growingTextView.internalTextView textInRange:selectedRange];
    
//    if (newText.length < 1) {
//        // 高亮输入框中的@
//        UITextView *textView = _textField.internalTextView;
//        NSRange range = textView.selectedRange;
//
//        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:textView.text              attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
//
//        NSArray *matches = [self findAllAt];
//
//        for (NSTextCheckingResult *match in matches) {
//            [string addAttribute:NSForegroundColorAttributeName value:AtCol range:NSMakeRange(match.range.location, match.range.length - 1)];
//        }
//
//        textView.attributedText = string;
//        textView.selectedRange = range;
//    }
//
//    if (growingTextView.text.length >0) {
//        NSString *theLast = [growingTextView.text substringFromIndex:[growingTextView.text length]-1];
//        if ([theLast isEqual:@"@"]) {
//            //去掉手动输入的  @
//            NSString *end_str = [growingTextView.text substringToIndex:growingTextView.text.length-1];
//            _textField.text = end_str;
//            [self atFrends];
//        }
//    }
    
}

- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView {
    // 光标不能点落在@词中间
    NSRange range = growingTextView.selectedRange;
    if (range.length > 0) {
        // 选择文本时可以
        return;
    }
    
//    NSArray *matches = [self findAllAt];
//
//    for (NSTextCheckingResult *match in matches) {
//        NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
//        if (NSLocationInRange(range.location, newRange)) {
//            growingTextView.internalTextView.selectedRange = NSMakeRange(match.range.location + match.range.length, 0);
//            break;
//        }
//    }
}
#pragma mark - Private
//- (NSArray<NSTextCheckingResult *> *)findAllAt {
//    // 找到文本中所有的@
//    NSString *string = _textField.text;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kATRegular options:NSRegularExpressionCaseInsensitive error:nil];
//    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length])];
//    return matches;
//}
#pragma mark -- 获取键盘高度
- (void)keyboardWillShow:(NSNotification *)aNotification {
//    if ([[Config getOwnID] intValue] <= 0) {
//        [[YBToolClass sharedInstance]waringLogin];
//        [_textField resignFirstResponder];
//        return;
//    }

    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.origin.y;
    _toolBar.frame = CGRectMake(0, height - 50, _window_width, 50);
    _emojiV.frame = CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff);
    _toolBar.backgroundColor = RGB_COLOR(@"#f4f5f6", 1);
    _textField.backgroundColor = [UIColor whiteColor];

}
- (void)keyboardWillHide:(NSNotification *)aNotification {
    [UIView animateWithDuration:0.1 animations:^{
        _toolBar.frame = CGRectMake(0, _window_height - 50-statusbarHeight, _window_width, 50+statusbarHeight);
        //_toolBar.frame = CGRectMake(0, _window_height + 10, _window_width, 50);
        _emojiV.frame = CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff);
        _toolBar.backgroundColor = [RGB(32, 28, 54) colorWithAlphaComponent:0.2];//RGB(27, 25, 41);;//RGB(248, 248, 248);
        _textField.backgroundColor = [UIColor clearColor];
    }];
}

-(void)pushmessage{
    /*
     parentid  回复的评论ID
     commentid 回复的评论commentid
     touid     回复的评论UID
     如果只是评论 这三个传0
     */
    if (_textField.text.length == 0 || _textField.text == NULL || _textField.text == nil || [_textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [MBProgressHUD showError:(@"请添加内容后再尝试")];
        return;
    }
    NSString *path = _textField.text;
    NSString *at_json = @"";
    //转json、去除空格、回车
//    if (_atArray.count>0) {
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_atArray options:NSJSONWritingPrettyPrinted error:nil];
//        at_json = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
//        at_json = [at_json stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        at_json = [at_json stringByReplacingOccurrencesOfString:@" " withString:@""];
//        at_json = [at_json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    }
    WeakSelf;
    [WYToolClass postNetworkWithUrl:@"videosetcommnet" andParameter:@{
            @"vid":_videoID,
            @"cid":@"0",
            @"pid":@"0",
            @"touid":@"0",
            @"content":path
    } success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if(code == 200){
            //更新评论数量
            NSString *newComments = [NSString stringWithFormat:@"%@",[info valueForKey:@"comments"]];
            
            NSDictionary *newDic = @{@"comments":newComments};
            NSMutableDictionary *m_dic = [NSMutableDictionary dictionaryWithDictionary:_videoList[_lastPlayCellIndex]];
            [m_dic addEntriesFromDictionary:newDic];
            [_videoList replaceObjectAtIndex:_lastPlayIndexPath.row withObject:m_dic];
            YBLookVideoCell *disCell = (YBLookVideoCell*)[self.collectionView cellForItemAtIndexPath:_lastPlayIndexPath];
            [disCell.commentBtn setTitle:[NSString stringWithFormat:@"%@",newComments] forState:0];
            _currentVideoDic = [NSDictionary dictionaryWithDictionary:m_dic];

            [MBProgressHUD showError:msg];
            weakSelf.textField.text = @"";
            weakSelf.textField.placeholder = (@"说点什么...");
            [self.view endEditing:YES];
            
        }else{
            [MBProgressHUD showError:msg];
            weakSelf.textField.text = @"";
            weakSelf.textField.placeholder = (@"说点什么...");
            [self.view endEditing:YES];
        }

    } fail:^{
        
    }];
    
}
//评论列表
- (void)messgaebtnWithIndex:(NSIndexPath *)indexPath {
    
    if (_comment) {
        [_comment removeFromSuperview];
        _comment = nil;
    }
    NSString *commentStr = minstr([_currentVideoDic valueForKey:@"comments"]);

    WeakSelf;
    if (!_comment) {
        _comment = [[commentview alloc]initWithFrame:CGRectMake(0,_window_height, _window_width, _window_height) hide:^(NSString *type) {
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.comment.frame = CGRectMake(0, _window_height, _window_width, _window_height);
            } ];
        } andvideoid:_videoID andhostid:_hostID count:[commentStr intValue] talkCount:^(id type) {
            NSLog(@"yblookviedeoVC-----count:%@",type);
            //默默更新数据
            //视频-关注、视频-点赞、视频-评论
            NSDictionary *newDic = @{@"comments":type};
            NSMutableDictionary *m_dic = [NSMutableDictionary dictionaryWithDictionary:_videoList[indexPath.row]];
            [m_dic addEntriesFromDictionary:newDic];
            [_videoList replaceObjectAtIndex:indexPath.row withObject:m_dic];
            YBLookVideoCell *disCell = (YBLookVideoCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
            [disCell.commentBtn setTitle:[NSString stringWithFormat:@"%@",type] forState:0];

            _currentVideoDic = [NSDictionary dictionaryWithDictionary:m_dic];

        } detail:^(id type) {
//            [weakSelf pushdetails:type];
        } youke:^(id type) {
        } andFrom:_fromWhere];
        
        [self.view addSubview:_comment];
    }
    
    _comment.fromWhere = _fromWhere;
//    [_comment getNewCount:[_comments intValue]];
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.comment.frame = CGRectMake(0,0,_window_width, _window_height);
    }];
}

//分享
-(void)doenjoy{
    [self morebtn:nil];
}
-(void)morebtn:(id)sender {
    if (!_videomore) {
        WeakSelf;
        NSArray *array = [common share_type];
        CGFloat hh = _window_height/3+30+ShowDiff;
        if (array.count == 0) {
            hh = _window_height/3/2+30+ShowDiff;
        }
        _videomore = [[videoMoreView alloc]initWithFrame:CGRectMake(0, _window_height+20, _window_width, hh) andHostDic:_currentVideoDic cancleblock:^(id array) {
            [weakSelf hideMoreView];
        } delete:^(id array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf clickLeftBtn];
            });
        } share:^(id array) {
            [weakSelf doAddShre:array];
//            [self getVideoWithFollowAnmation:NO];
//            weakSelf.shares = array;
//            [weakSelf.controlView.share setTitle:[NSString stringWithFormat:@"%@",weakSelf.shares] forState:0];
        }];
        _videomore.fromWhere = _fromWhere;
        _videomore.jubaoBlock = ^(id array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                jubaoVC *jubao = [[jubaoVC alloc]init];
    //            jubao.dongtaiId = array;
    //            jubao.fromWhere = weakSelf.fromWhere ? weakSelf.fromWhere:@"LookVideo";
                [[MXBADelegate sharedAppDelegate] pushViewController:jubao animated:YES];
            });
        };
        
        [self.view addSubview:_videomore];
        
        _videomore.hidden = YES;
    }
    _videomore.fromWhere = _fromWhere;
    
    if (_videomore.hidden == YES) {
        [self showMoreView];
    }else{
        [self hideMoreView];
    }
}
-(void)showMoreView{
    
    WeakSelf;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.videomore.frame = CGRectMake(0, _window_height - _window_height/3-50-ShowDiff, _window_width, _window_height/3+50+ShowDiff);
        NSArray *array = @[@"wx"];
        //如果没有分享
        if (array.count == 0) {
            weakSelf.videomore.frame = CGRectMake(0, _window_height - _window_height/3/2-50-ShowDiff, _window_width, _window_height/3/2+50+ShowDiff);
        }
        weakSelf.videomore.hidden = NO;
    }];
}

-(void)hideMoreView{
    
    WeakSelf;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.videomore.frame = CGRectMake(0, _window_height +20, _window_width, _window_height/2.2);
        NSArray *array = @[@"wx"];
        if (array.count == 0) {
            weakSelf.videomore.frame = CGRectMake(0, _window_height +20, _window_width, _window_height/2.2/2);
        }
        weakSelf.videomore.hidden = YES;
    }];
}
- (void)doAddShre:(NSString *)shares{
    NSMutableDictionary *muDic = [_videoList[_lastPlayCellIndex] mutableCopy];
    [muDic setObject:shares forKey:@"shares"];
    [_videoList replaceObjectAtIndex:_lastPlayCellIndex withObject:muDic];
    dispatch_async(dispatch_get_main_queue(), ^{
        YBLookVideoCell *cell = (YBLookVideoCell *)[_collectionView cellForItemAtIndexPath:_lastPlayIndexPath];
        cell.dataDic = muDic;
    });
}
- (void)showGoodsDeatile{
    NSDictionary *dic = _videoList[_lastPlayCellIndex];
    NSString *goodsid = minstr([dic valueForKey:@"goodsid"]);
    NSLog(@"yyyyyyyyyyyyy----isgoods:%@ \n  dic:%@",goodsid, _videoList[_lastPlayCellIndex]);
    if (goodsDView) {
        [goodsDView removeFromSuperview];
        goodsDView = nil;
    }
    goodsDView = [[lookVGoodsDView alloc]initWithGoodsMsg:[[dic valueForKey:@"goods"] firstObject]];
    goodsDView.videoid = goodsid;
    goodsDView.videoUserid = minstr([dic valueForKey:@"uid"]);
    [self.view addSubview:goodsDView];
}

@end
