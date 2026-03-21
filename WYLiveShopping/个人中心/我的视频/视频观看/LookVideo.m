//
//  LookVideo1.m
//  iphoneLive
//
//  Created by Rookie on 2018/7/9.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "LookVideo.h"

#import <CWStatusBarNotification/CWStatusBarNotification.h>
#import "videoMoreView.h"
#import <SDWebImage/UIImage+GIF.h>
#import "commentview.h"

//#import "commectDetails.h"
#import "JPVideoPlayerKit.h"
#import "UIImage+MultiFormat.h"

#import "videoPauseView.h"
#import "jubaoVC.h"

#import "JPLookProgressView.h"
#import "JPBufferView.h"

#import "FrontView.h"
#import <HPGrowingTextView/HPGrowingTextView.h>
#import <AFNetworking/AFNetworking.h>
#import "twEmojiView.h"
#import "PublicObj.h"
@interface LookVideo ()<UIActionSheetDelegate,UIScrollViewDelegate,videoPauseDelegate,JPVideoPlayerDelegate,HPGrowingTextViewDelegate,twEmojiViewDelegate>
{
    CWStatusBarNotification *_notification;
    
    videoPauseView *pasueView;
    
    UIView *_toolBar;
    
    CGFloat lastContenOffset;
    CGFloat endDraggingOffset;
    
    NSMutableArray *_atArray;                                        //@用户的uid和uname数组
    
    /**
     * 极端情况：app刚启动(默认首页，自动播放视频),疯狂点击个人中心(或者非'首页'任意按钮)，视频任然播放...
     * 产生原因：页面刚启动，播放器处于一个初始化或者视频缓冲阶段，疯狂点击响应时间小于播放器初始化时间，
     * 也就是停止播放器是在初始化完成之前。导致调用停止的播放器对象为空，就无法停止播放器了
     * 在 viewWillDisappear 设置一个变量 结合 playerStatusDidChanged 停掉播放器
     */
    BOOL _stopPlay;
    
    BOOL _firstWatch;                                                //是否首次观看（滑出再进来仍然是首次观看，循环播放不算）
    twEmojiView *_emojiV;


}

@property(nonatomic,assign)BOOL isdelete;
@property(nonatomic,copy)NSString *playUrl;                          //视频播放url
@property(nonatomic,copy)NSString *videoid;                          //视频id
@property(nonatomic,copy)NSString *hostid;                           //主播id
@property(nonatomic,copy)NSString *hosticon;                         //主播头像
@property(nonatomic,copy)NSString *hostname;
@property(nonatomic,copy)NSString *islike;                           //是否点赞
@property(nonatomic,copy)NSString *comments;                         //评论总数
@property(nonatomic,copy)NSString *likes;                            //点赞数
@property(nonatomic,copy)NSString *shares;                           //分享次数

@property(nonatomic,strong)videoMoreView *videomore;                 //分享view

@property(nonatomic,strong)UIButton *goBackBtn;
@property(nonatomic,strong)UIButton *goBackShadow;

@property(nonatomic,strong)commentview *comment;                     //评论
@property(nonatomic,strong)HPGrowingTextView *textField;
@property(nonatomic,strong)UIButton *finishbtn;
@property(nonatomic,strong)NSMutableArray *imgArr;
@property(nonatomic,assign)BOOL isHome;                             //首页-推荐

//播放器---
@property (strong, nonatomic)  UIScrollView *backScrollView;

@property (nonatomic, weak) UIImageView *currentPlayerIV;           //展现在前台的IV（first、second、thirdImageView）
@property(nonatomic,strong)FrontView *currentFront;                 //展现在前台的View（first、second、thirdFront）
@property(nonatomic,strong)UIImageView *bufferIV;                     //首次切换过度封面图（消除闪屏）
@property (nonatomic, strong) UIImageView *firstImageView;
@property(nonatomic,strong) FrontView *firstFront;
@property (nonatomic, strong) UIImageView *secondImageView;
@property(nonatomic,strong) FrontView *secondFront;
@property (nonatomic, strong) UIImageView *thirdImageView;
@property(nonatomic,strong) FrontView *thirdFront;

@property(nonatomic, assign) CGFloat scrollViewOffsetYOnStartDrag;

@end

@implementation LookVideo


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [IQKeyboardManager sharedManager].enable = YES;
    
    /** 非常重要 */
    _stopPlay = YES;
    [_currentPlayerIV jp_stopPlay];
    
    [self hideAnimation];
    
    _currentPlayerIV = nil;
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [IQKeyboardManager sharedManager].enable = NO;
//    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [self startAllAnimation];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //当从个人中心删除了视频时做个标记当返回推荐时候重新请求数据
//    NSString *sign_del = [Config getSignOfDelVideo];
//    if ([sign_del isEqual:@"1"]&&!_fromWhere) {
//        [Config saveSignOfDelVideo:@"0"];
//        [_videoList removeAllObjects];
//    }
    _stopPlay = NO;
    /**
     * 判断来源 videoList 不为空判定为其他页面跳转至此,否则即为首页初次加载(视为首页-推荐)
     */
    if (!_videoList || _videoList.count == 0) {
        _isHome = YES;
        _curentIndex = 0;
        _pages = 1;
        self.videoList = [NSMutableArray array];
        [self requestMoreVideo];
    }else{
        _scrollViewOffsetYOnStartDrag = -100;
        [self scrollViewDidEndScrolling];
    }

    if (pasueView) {
        [pasueView removeFromSuperview];
        pasueView = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _atArray = [NSMutableArray array];
    _stopPlay = NO;
    _firstWatch = YES;
    //通知
    [self addNotifications];
    lastContenOffset = 0;

    _bufferIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
    _bufferIV.contentMode = UIViewContentModeScaleAspectFit;

    _hostdic = [NSDictionary dictionary];
    _lastHostDic = [NSDictionary dictionary];
    _nextHostDic = [NSDictionary dictionary];

    //滚动视图
    [self.view addSubview:self.backScrollView];
    if (@available(iOS 11.0,*)) {
        self.backScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    //加到_pageView上效果不大好
    UIImageView *mask_top = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100+statusbarHeight)];
    [mask_top setImage:[UIImage imageNamed:@"home_mask_top"]];
    [self.view addSubview:mask_top];

    UIImageView* mask_buttom = [[UIImageView alloc] initWithFrame:CGRectMake(0,  _window_height- 100, self.view.frame.size.width, 100)];
    [mask_buttom setImage:[UIImage imageNamed:@"home_mask_bottom"]];
    [self.view addSubview:mask_buttom];

    UITapGestureRecognizer *tapone = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doPauseView)];
    tapone.numberOfTapsRequired = 1;
    [_backScrollView addGestureRecognizer:tapone];

    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(messgaebtn)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback  error:nil];

    //向左滑动进入个人主页
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(zhuboMessage)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipe];

    if (_curentIndex>=_videoList.count-3) {
        _pages += 1;
        [self requestMoreVideo];
    }

    if (_fromWhere) {
        [self.view addSubview:self.goBackBtn];
        [self showtextfield];
    }

}

#pragma mark ================ 请求分页 ===============
- (void)requestMoreVideo {
    NSString *url = [NSString stringWithFormat:@"%@&p=%@",_requestUrl,@(_pages)];
    WeakSelf;
//    [YBNetworking postWithUrl:url Dic:nil Suc:^(NSDictionary *data, NSString *code, NSString *msg) {
//        if ([code isEqual:@"0"]) {
//            NSArray *info = [data valueForKey:@"info"];
//            if (_pages==1) {
//                [_videoList removeAllObjects];
//            }
//            [_videoList addObjectsFromArray:info];
//            if (_isHome == YES) {
//                _isHome = NO;
//                _scrollViewOffsetYOnStartDrag = -100;
//                [weakSelf scrollViewDidEndScrolling];
//            }
//        }
//    } Fail:^(id fail) {
//        [self checkNetwork];
//    }];
}
#pragma  mark - 视频详情
-(void)getVideoWithFollowAnmation:(BOOL)haveAnmation{
    NSString *url = [purl stringByAppendingFormat:@"?service=Video.getVideo"];
    NSDictionary *subdic = @{
                             @"uid":[Config getOwnID],
                             @"videoid":[NSString stringWithFormat:@"%@",[_hostdic valueForKey:@"id"]]
                             };;
    WeakSelf;
//    [YBNetworking postWithUrl:url Dic:subdic Suc:^(NSDictionary *data, NSString *code, NSString *msg) {
//        if([code isEqual:@"0"]) {
//            NSDictionary *info = [[data valueForKey:@"info"] firstObject];
//            /*
//            NSDictionary *videoDic = @{@"shares":[info valueForKey:@"shares"],
//                                       @"likes":[info valueForKey:@"likes"],
//                                       @"islike":[info valueForKey:@"islike"],
//                                       @"comments":[info valueForKey:@"comments"],
//                                       @"isattent":[info valueForKey:@"isattent"]
//                                       };
//             */
//            FrontView *frontView;
//            if (_curentIndex == 0) {
//                frontView = _firstFront;
//            }else if (_curentIndex+1 == _videoList.count){
//                frontView = _thirdFront;
//            }else{
//                frontView = _secondFront;
//            }
//            /*
//            [weakSelf setVideoData:info withFront:frontView];
//             */
//            [_videoList replaceObjectAtIndex:_curentIndex withObject:info];
//            if (haveAnmation) {
//                if ([[Config getOwnID] isEqual:weakSelf.hostid] || [[info valueForKey:@"isattent"] isEqual:@"1"]) {
//                    [frontView.followBtn setImage:[UIImage imageNamed:@"home_follow_sel"] forState:0];
//                }else{
//                    [frontView.followBtn setImage:[UIImage imageNamed:@"home_follow"] forState:0];
//                }
//                frontView.followBtn.hidden = NO;
//                [frontView.followBtn.layer addAnimation:[PublicObj followShowTransition] forKey:nil];
//            }
//
//        }else if ([code isEqual:@"700"]) {
//            [PublicObj tokenExpired:[data valueForKey:@"msg"]];
//        }else{
//            [MBProgressHUD showError:[data valueForKey:@"msg"]];
//        }
//
//    } Fail:nil];
    
}
-(void)setVideoData:(NSDictionary *)videoDic withFront:(FrontView*)front{
    _shares =[NSString stringWithFormat:@"%@",[videoDic valueForKey:@"shares"]];
    _likes = [NSString stringWithFormat:@"%@",[videoDic valueForKey:@"likes"]];
    _islike = [NSString stringWithFormat:@"%@",[videoDic valueForKey:@"islike"]];
    _comments = [NSString stringWithFormat:@"%@",[videoDic valueForKey:@"comments"]];
    NSString *isattent = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@",[videoDic valueForKey:@"isattent"]]];
    //_steps = [NSString stringWithFormat:@"%@",[info valueForKey:@"steps"]];
    WeakSelf;
    //点赞数 评论数 分享数
    if ([weakSelf.islike isEqual:@"1"]) {
        [front.likebtn setImage:[UIImage imageNamed:@"home_zan_sel"] forState:0];
        //weakSelf.likebtn.userInteractionEnabled = NO;
    } else{
        [front.likebtn setImage:[UIImage imageNamed:@"home_zan"] forState:0];
        //weakSelf.likebtn.userInteractionEnabled = YES;
    }
    [front.likebtn setTitle:[NSString stringWithFormat:@"%@",weakSelf.likes] forState:0];
    front.likebtn = [WYToolClass setUpImgDownText:front.likebtn];
    [front.enjoyBtn setTitle:[NSString stringWithFormat:@"%@",weakSelf.shares] forState:0];
    front.enjoyBtn = [WYToolClass setUpImgDownText:front.enjoyBtn];
    [front.commentBtn setTitle:[NSString stringWithFormat:@"%@",weakSelf.comments] forState:0];
    front.commentBtn = [WYToolClass setUpImgDownText:front.commentBtn];
    
    if ([[Config getOwnID] isEqual:weakSelf.hostid] || [isattent isEqual:@"1"]) {
        [front.followBtn setImage:[UIImage imageNamed:@"home_follow_sel"] forState:0];
        //front.followBtn.hidden = YES;
    }else{
        [front.followBtn setImage:[UIImage imageNamed:@"home_follow"] forState:0];
    }
    front.followBtn.hidden = NO;
    [front.followBtn.layer addAnimation:[WYToolClass followShowTransition] forKey:nil];
}
-(void)setUserData:(NSDictionary *)dataDic withFront:(FrontView*)front{
    //列表上的信息会存在刷新不及时，需要请求接口刷新Video.getVideo
    //获取视频间信息
    NSDictionary *musicDic = [dataDic valueForKey:@"musicinfo"];
    id userinfo = [dataDic valueForKey:@"userinfo"];
    NSString *dataUid;
    NSString *dataIcon;
    NSString *dataUname;
    if ([userinfo isKindOfClass:[NSDictionary class]]) {
        dataUid = [NSString stringWithFormat:@"%@",[userinfo valueForKey:@"id"]];
        dataIcon = [NSString stringWithFormat:@"%@",[userinfo valueForKey:@"avatar"]];
        dataUname = [NSString stringWithFormat:@"@%@",[userinfo valueForKey:@"user_nicename"]];
    }else{
        dataUid = @"0";
        dataIcon = @"";
        dataUname = @"";
    }
    
//    NSString *musicID = [NSString stringWithFormat:@"%@",[musicDic valueForKey:@"id"]];
//    NSString *musicCover = [NSString stringWithFormat:@"%@",[musicDic valueForKey:@"img_url"]];
//    if ([musicID isEqual:@"0"]) {
//        [front.musicIV sd_setImageWithURL:[NSURL URLWithString:_hosticon]];
//    }else{
//        [front.musicIV sd_setImageWithURL:[NSURL URLWithString:musicCover]];
//    }
    [front setMusicName:[NSString stringWithFormat:@"%@",[musicDic valueForKey:@"music_format"]]];
    front.titleL.text = [NSString stringWithFormat:@"%@",[dataDic valueForKey:@"title"]];
    front.nameL.text = dataUname;
    [front.iconBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:dataIcon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_head.png"]];
    

    //计算名称长度
    CGSize titleSize = [front.titleL.text boundingRectWithSize:CGSizeMake(_window_width*0.75, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:SYS_Font(20)} context:nil].size;
    front.titleL.frame = CGRectMake(0, front.botView.height-titleSize.height, titleSize.width, titleSize.height);
    front.nameL.frame = CGRectMake(0, front.titleL.top-25, front.botView.width, 25);
    front.followBtn.frame = CGRectMake(front.iconBtn.left+12, front.iconBtn.bottom-13, 26, 26);
    front.followBtn.hidden = NO;
    NSString *isgoods = minstr([dataDic valueForKey:@"goodsid"]);
    NSString *goodsType = minstr([dataDic valueForKey:@"type"]);

//    isgoods = [NSString stringWithFormat:@"%d",arc4random()%2];
    if (![isgoods isEqual:@"0"]) {
        front.titleL.frame = CGRectMake(0, front.botView.height-titleSize.height-40, titleSize.width, titleSize.height);
    }
    front.nameL.frame = CGRectMake(0, front.titleL.top-25, front.botView.width, 25);
    front.followBtn.frame = CGRectMake(front.iconBtn.left+12, front.iconBtn.bottom-13, 26, 26);

    
    if (![goodsType isEqual:@"0"]) {
        front.shopButton.hidden = NO;
        
    }else{
        front.shopButton.hidden = YES;
    }

    //0 没有。1商品。2.付费内容
    if ([goodsType isEqual:@"1"]) {
        [front.shopButton setTitle:@"查看商品详情" forState:0];
    }else if([goodsType isEqual:@"2"]){
        [front.shopButton setTitle:@"查看付费内容" forState:0];
    }

//    if ([[Config getOwnID] isEqual:dataUid]) {
//        front.followBtn.hidden = YES;
//    }else{
//        front.followBtn.hidden = NO;
//    }
    
}
#pragma mark - 点击事件
-(void)clickLeftBtn {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)clickEvent:(NSString *)event {
    
    if ([event isEqual:@"头像"]) {
        [self zhuboMessage];
    }else if ([event isEqual:@"关注"]){
        [self guanzhuzhubo];
    }else if ([event isEqual:@"评论"]){
        [self messgaebtn];
    }else if ([event isEqual:@"点赞"]){
        [self dolike];
    }else if ([event isEqual:@"商品"]){
        [self showGoodsDeatile];
    }else{
        //分享
        [self doenjoy];
    }
}

#pragma mark - scrollView delegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    lastContenOffset = scrollView.contentOffset.y;
    NSLog(@"111=====%f",scrollView.contentOffset.y);
    _currentPlayerIV.jp_progressView.hidden = YES;
    self.scrollViewOffsetYOnStartDrag = scrollView.contentOffset.y;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    endDraggingOffset = scrollView.contentOffset.y;
    NSLog(@"222=====%f",scrollView.contentOffset.y);
    if (decelerate == NO) {
        [self scrollViewDidEndScrolling];
    }
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    scrollView.scrollEnabled = NO;
    NSLog(@"333=====%f",scrollView.contentOffset.y);
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSLog(@"currentIndex=====%.2f",scrollView.contentSize.height);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    scrollView.scrollEnabled = YES;
    NSLog(@"444=====%f",scrollView.contentOffset.y);
    
    if (lastContenOffset < scrollView.contentOffset.y && (scrollView.contentOffset.y-lastContenOffset)>=_window_height) {
        NSLog(@"=====向上滚动=====");
        
        _curentIndex++;
        if (_curentIndex>_videoList.count-1) {
            _curentIndex =_videoList.count-1;
        }
        _currentFront.followBtn.hidden = YES;
    }else if(lastContenOffset > scrollView.contentOffset.y && (lastContenOffset-scrollView.contentOffset.y)>=_window_height){
        
        NSLog(@"=====向下滚动=====");
        _curentIndex--;
        if (_curentIndex<0) {
            _curentIndex=0;
        }
        _currentFront.followBtn.hidden = YES;
    }else{
        NSLog(@"=======本页拖动未改变数据=======");
        if (scrollView.contentOffset.y == 0 && _curentIndex==0) {
            [MBProgressHUD showError:@"已经到顶了哦^_^"];
        }else if (scrollView.contentOffset.y == _window_height*2 && _curentIndex==_videoList.count-1){
            [MBProgressHUD showError:@"没有更多了哦^_^"];
        }
    }
    
    _currentPlayerIV.jp_progressView.hidden = NO;
    [self scrollViewDidEndScrolling];
    
    if (_requestUrl) {
        if (_curentIndex>=_videoList.count-3) {
            _pages += 1;
            [self requestMoreVideo];
        }
    }
    
}

#pragma mark - Private

- (void)scrollViewDidEndScrolling {
    
    if((self.scrollViewOffsetYOnStartDrag == self.backScrollView.contentOffset.y) && (endDraggingOffset!= _scrollViewOffsetYOnStartDrag)){
        
        return;
    }
    NSLog(@"7-8==%f====%f",self.scrollViewOffsetYOnStartDrag,self.backScrollView.contentOffset.y);
    [self changeRoom];
    
}
-(void)releaseIV{
//    [_bufferIV removeAllSubViews];
    [_firstImageView removeAllSubViews];
    [_secondImageView removeAllSubViews];
    [_thirdImageView removeAllSubViews];
//    [_currentPlayerIV removeAllSubViews];
}
#pragma mark - 切换房间
-(void)changeRoom{
    [self releaseIV];
    if (_videomore) {
        self.tabBarController.tabBar.hidden = NO;
        [_videomore removeFromSuperview];
        _videomore = nil;
    }
    
    if (pasueView) {
        [pasueView removeFromSuperview];
        pasueView = nil;
    }
    if (_curentIndex+1 > _videoList.count) {
        [MBProgressHUD showError:@"没有数据>_<"];
        return;
    }
    _hostdic = _videoList[_curentIndex];
    _hostid = minstr([_hostdic valueForKey:@"uid"]);
    _hosticon = minstr([_hostdic valueForKey:@"avatar"]);
    _hostname = minstr([_hostdic valueForKey:@"nickname"]);
    
    _playUrl = [NSString stringWithFormat:@"%@",[_hostdic valueForKey:@"url"]];
    _videoid = [NSString stringWithFormat:@"%@",[_hostdic valueForKey:@"id"]];
    
    //封面、音乐、标题、点赞、评论、分享、关注等赋值
    if (_curentIndex>0) {
        _lastHostDic = _videoList[_curentIndex-1];
        [_firstImageView sd_setImageWithURL:[NSURL URLWithString:minstr([_lastHostDic valueForKey:@"thumb"])]];
        [self setUserData:_lastHostDic withFront:_firstFront];
        [self setVideoData:_lastHostDic withFront:_firstFront];
    }
    if (_curentIndex < _videoList.count-1) {
        _nextHostDic = _videoList[_curentIndex+1];
        [_thirdImageView sd_setImageWithURL:[NSURL URLWithString:minstr([_nextHostDic valueForKey:@"thumb"])]];
        [self setUserData:_nextHostDic withFront:_thirdFront];
        [self setVideoData:_nextHostDic withFront:_thirdFront];
        
    }
    
    [_secondImageView sd_setImageWithURL:[NSURL URLWithString:minstr([_hostdic valueForKey:@"thumb"])]];
    [self setUserData:_hostdic withFront:_secondFront];
    [self setVideoData:_hostdic withFront:_secondFront];
    
    if (_curentIndex==0) {
        //第一个
        [self.backScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        _currentPlayerIV = _firstImageView;
        _currentFront = _firstFront;
        
        /**
         *  _curentIndex=0时，重新处理下_secondImageView的封面、
         *  不用处理_thirdImageView，因为滚到第二个的时候上面的判断自然给第三个赋值
         */
        [_firstImageView sd_setImageWithURL:[NSURL URLWithString:minstr([_hostdic valueForKey:@"thumb"])]];
        [self setUserData:_hostdic withFront:_firstFront];
        [self setVideoData:_hostdic withFront:_firstFront];
        [_secondImageView sd_setImageWithURL:[NSURL URLWithString:minstr([_nextHostDic valueForKey:@"thumb"])]];
        [self setUserData:_nextHostDic withFront:_secondFront];
         [self setVideoData:_nextHostDic withFront:_secondFront];
        _bufferIV.image = _firstImageView.image;
    }else if (_curentIndex==_videoList.count-1){
        
        //最后一个
        [self.backScrollView setContentOffset:CGPointMake(0, _window_height*2) animated:NO];
        _currentPlayerIV = _thirdImageView;
        _currentFront = _thirdFront;
        /**
         *  _curentIndex=_videoList.count-1时，重新处理下_secondImageView的封面、
         *  这个时候只能上滑 _secondImageView 给 _lastHostDic的值
         */
        [_secondImageView sd_setImageWithURL:[NSURL URLWithString:minstr([_lastHostDic valueForKey:@"thumb"])]];
        [self setUserData:_lastHostDic withFront:_secondFront];
        [self setVideoData:_lastHostDic withFront:_secondFront];
        [_thirdImageView sd_setImageWithURL:[NSURL URLWithString:minstr([_hostdic valueForKey:@"thumb"])]];
        [self setUserData:_hostdic withFront:_thirdFront];
        [self setVideoData:_hostdic withFront:_thirdFront];
        _bufferIV.image = _thirdImageView.image;
    }else{
        
        //中间的
        [self.backScrollView setContentOffset:CGPointMake(0, _window_height) animated:NO];
        _currentPlayerIV = _secondImageView;
        _currentFront = _secondFront;
        _bufferIV.image = _secondImageView.image;
    }
    
    [self getVideoWithFollowAnmation:YES];
    _firstWatch = NO;
    [_currentPlayerIV jp_stopPlay];
    
    [_currentPlayerIV jp_playVideoMuteWithURL:[NSURL URLWithString:_playUrl]
                               bufferingIndicator:[JPBufferView new]
                                     progressView:[JPLookProgressView new]
                                    configuration:^(UIView *view, JPVideoPlayerModel *playerModel) {
                                        view.jp_muted = NO;
                                        view.jp_videoPlayerView.backgroundColor = [UIColor clearColor];
                                        _firstWatch = YES;
                                        if (_currentPlayerIV.image.size.width>0 && (_currentPlayerIV.image.size.width >= _currentPlayerIV.image.size.height)) {
                                            playerModel.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                                            _currentPlayerIV.contentMode = UIViewContentModeScaleAspectFit;
                                        }else{
                                            playerModel.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                                            _currentPlayerIV.contentMode = UIViewContentModeScaleAspectFit;

                                        }
                                    }];
    [_currentPlayerIV.jp_videoPlayerView addSubview:_bufferIV];
    
//    _firstWatch = YES;
}

#pragma mark - ============== 播放器代理
#pragma mark - JPVideoPlayerDelegate

- (BOOL)shouldShowBlackBackgroundBeforePlaybackStart {
    return NO;
}
-(BOOL)shouldShowBlackBackgroundWhenPlaybackStart {
    return NO;
}

-(void)playerStatusDidChanged:(JPVideoPlayerStatus)playerStatus {
    NSLog(@"=====7-8====%lu",(unsigned long)playerStatus);
    
    if (_stopPlay == YES) {
        NSLog(@"8-4:play-停止了");
        _stopPlay = NO;
        _firstWatch = NO;
        //页面已经消失了，就不要播放了
        [_currentPlayerIV jp_stopPlay];
    }
    
    if (playerStatus == JPVideoPlayerStatusPlaying) {
        if (_bufferIV) {
           
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_bufferIV removeFromSuperview];
            });
        }
    }
    if (playerStatus == JPVideoPlayerStatusReadyToPlay && _firstWatch==YES) {
        //addview
        [self videoStart];
    }
    if (playerStatus == JPVideoPlayerStatusStop && _firstWatch == YES) {
        //finish
        _firstWatch = NO;
        [self videoEnd];
    }
    
}
#pragma mark - 视频开始观看-结束观看
-(void)videoStart {
    if ([_hostid isEqual:[Config getOwnID]]) {
        return;
    }
    NSString *random_str = [PublicObj stringToMD5:[NSString stringWithFormat:@"%@-%@-#2hgfk85cm23mk58vncsark",[Config getOwnID],_videoid]];
    NSString *url = [purl stringByAppendingFormat:@"?service=Video.addView&uid=%@&token=%@&videoid=%@&random_str=%@",[Config getOwnID],[Config getOwnToken],_videoid,random_str];
//    [YBNetworking postWithUrl:url Dic:nil Suc:^(NSDictionary *data, NSString *code, NSString *msg) {
//        NSLog(@"addview-%@-%@-%@",code,data,msg);
//    } Fail:nil];
}

-(void)videoEnd {
    if ([_hostid isEqual:[Config getOwnID]]) {
        return;
    }
//    NSString *random_str = [PublicObj stringToMD5:[NSString stringWithFormat:@"%@-%@-#2hgfk85cm23mk58vncsark",[Config getOwnID],_videoid]];
//    NSString *url = [purl stringByAppendingFormat:@"?service=Video.setConversion&uid=%@&token=%@&videoid=%@&random_str=%@",[Config getOwnID],[Config getOwnToken],_videoid,random_str];
//    [YBNetworking postWithUrl:url Dic:nil Suc:^(NSDictionary *data, NSString *code, NSString *msg) {
//        NSLog(@"setConversion-%@-%@-%@",code,data,msg);
//    } Fail:nil];
}

#pragma mark - 动画的控制
-(void)hideAnimation {
    //音乐
    [_firstFront.symbolAIV.layer removeAllAnimations];
    [_firstFront.symbolBIV.layer removeAllAnimations];
    [_secondFront.symbolAIV.layer removeAllAnimations];
    [_secondFront.symbolBIV.layer removeAllAnimations];
    [_thirdFront.symbolAIV.layer removeAllAnimations];
    [_thirdFront.symbolBIV.layer removeAllAnimations];
    
    _firstFront.symbolAIV.hidden = YES;
    _firstFront.symbolBIV.hidden = YES;
    _secondFront.symbolAIV.hidden = YES;
    _secondFront.symbolBIV.hidden = YES;
    _thirdFront.symbolAIV.hidden = YES;
    _thirdFront.symbolBIV.hidden = YES;
    
}
-(void)startAllAnimation {
    
    [self hideAnimation];
    [self pubAnimation:_firstFront];
    [self pubAnimation:_secondFront];
    [self pubAnimation:_thirdFront];
   
}
-(void)pubAnimation:(FrontView*)front{
    //音乐
    front.symbolAIV.hidden = NO;
    [front.discIV.layer addAnimation:[PublicObj rotationAnimation] forKey:@"rotation"];
    [front.symbolAIV.layer addAnimation:[PublicObj caGroup] forKey:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        front.symbolBIV.hidden = NO;
        [front.symbolBIV.layer addAnimation:[PublicObj caGroup] forKey:nil];
    });
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 前后台
-(void)onAppDidEnterBackground {
    [self hideAnimation];
}
-(void)onAppWillEnterForeground {
    [self startAllAnimation];
}

#pragma mark - 注册通知

-(void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    //在回复页面回复了之后，在本页面需要增加评论数量
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloaComments:) name:@"allComments" object:nil];
    //回复之后刷新数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getnewreload) name:@"reloadcomments" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callComming) name:UIApplicationWillResignActiveNotification object:nil];
    
}


#pragma mark - 通知

-(void)callComming {
    if (_currentPlayerIV.jp_playerStatus == JPVideoPlayerStatusPlaying) {
        [self doPauseView];
    }
}

-(void)reloaComments:(NSNotification *)ns{
    NSDictionary *subdic = [ns userInfo];
    [_currentFront.commentBtn setTitle:[NSString stringWithFormat:@"%@",[subdic valueForKey:@"allComments"]] forState:0];
    if (_comment) {
        [_comment getNewCount:[[subdic valueForKey:@"allComments"] intValue]];
    }
}
-(void)getnewreload{
    //获取视频信息
    _hostid = minstr([_hostdic valueForKey:@"uid"]);
    _hosticon = minstr([_hostdic valueForKey:@"avatar"]);
    _hostname = minstr([_hostdic valueForKey:@"nickname"]);
    _videoid = [NSString stringWithFormat:@"%@",[_hostdic valueForKey:@"id"]];
    _likes = [NSString stringWithFormat:@"%@",[_hostdic valueForKey:@"likes"]];
    _islike = [NSString stringWithFormat:@"%@",[_hostdic valueForKey:@"islike"]];
   
}

#pragma mark - 召唤好友
-(void)atFrends {
    [_textField resignFirstResponder];

//    [_textField becomeFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        _emojiV.frame = CGRectMake(0, _window_height - (EmojiHeight+ShowDiff), _window_width, EmojiHeight+ShowDiff);
        _toolBar.frame = CGRectMake(0, _emojiV.y - 50, _window_width, 50);
        _toolBar.backgroundColor = RGB_COLOR(@"#f4f5f6", 1);
        _textField.backgroundColor = [UIColor whiteColor];
    }];

}

#pragma mark - 输入框代理事件
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    _textField.height = height;
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView {
    [_textField resignFirstResponder];
    [self pushmessage];
    return YES;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""]) {
        NSRange selectRange = growingTextView.selectedRange;
        if (selectRange.length > 0) {
            //用户长按选择文本时不处理
            return YES;
        }
        
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
    
    if (newText.length < 1) {
        // 高亮输入框中的@
        UITextView *textView = _textField.internalTextView;
        NSRange range = textView.selectedRange;
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:textView.text              attributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:16]}];
        
        
        textView.attributedText = string;
        textView.selectedRange = range;
    }
    
    if (growingTextView.text.length >0) {
        NSString *theLast = [growingTextView.text substringFromIndex:[growingTextView.text length]-1];
        if ([theLast isEqual:@"@"]) {
            //去掉手动输入的  @
            NSString *end_str = [growingTextView.text substringToIndex:growingTextView.text.length-1];
            _textField.text = end_str;
            [self atFrends];
        }
    }
    
}

- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView {
    // 光标不能点落在@词中间
    NSRange range = growingTextView.selectedRange;
    if (range.length > 0) {
        // 选择文本时可以
        return;
    }
    
}




#pragma mark -- 获取键盘高度
- (void)keyboardWillShow:(NSNotification *)aNotification {
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

//点击关注主播
-(void)guanzhuzhubo{
    if ([[Config getOwnID] intValue]<0) {
        [PublicObj warnLogin];
        return;
    }
    NSString *url = [purl stringByAppendingFormat:@"?service=User.setAttent"];
    NSDictionary *subdic = @{
                             @"uid":[Config getOwnID],
                             @"touid":_hostid,
                             @"token":[Config getOwnToken],
                             };
    
//    [YBNetworking postWithUrl:url Dic:subdic Suc:^(NSDictionary *data, NSString *code, NSString *msg) {
//        if([code isEqual:@"0"]) {
//            if ([minstr([[[data valueForKey:@"info"] firstObject] valueForKey:@"isattent"]) isEqual:@"1"]) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [_currentFront.followBtn.imageView.layer addAnimation:[PublicObj smallToBigToSmall] forKey:nil];
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.9 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        [_currentFront.followBtn setImage:[UIImage imageNamed:@"home_follow_sel"] forState:0];
//                    });
//                });
//            }else{
//                 [_currentFront.followBtn setImage:[UIImage imageNamed:@"home_follow"] forState:0];
//            }
//            [self getVideoWithFollowAnmation:YES];
//
//        }else if ([code isEqual:@"700"]) {
//            [PublicObj tokenExpired:[data valueForKey:@"msg"]];
//        }else{
//            [MBProgressHUD showError:[data valueForKey:@"msg"]];
//        }
//    } Fail:nil];
    
}
-(void)zhuboMessage{
    
    
    
}
-(void)doPauseView{
    if(_videomore && _videomore.hidden == NO){
        _videomore.hidden = YES;
        return;
    }
    if (_emojiV.y < _window_height) {
        _emojiV.frame = CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff);
        _toolBar.frame = CGRectMake(0, _window_height - 50-statusbarHeight, _window_width, 50+statusbarHeight);
        _toolBar.backgroundColor = [RGB(32, 28, 54) colorWithAlphaComponent:0.2];//RGB(27, 25, 41);;//RGB(248, 248, 248);
        _textField.backgroundColor = [UIColor clearColor];

    }
    if (_toolBar && _toolBar.y<_window_height-50-ShowDiff) {
        [_textField resignFirstResponder];
        return;
    }
    
    [_textField resignFirstResponder];
    
    if (_currentPlayerIV.jp_playerStatus != JPVideoPlayerStatusPlaying &&
        _currentPlayerIV.jp_playerStatus != JPVideoPlayerStatusPause ) {
        return;
    }
    
    if (!pasueView) {
        
        CGFloat pauseVH;
        if (_curentIndex==0) {
            //第一个
            pauseVH = _window_height*1/2-40;
        }else if (_curentIndex==_videoList.count-1){
            //最后一个
            pauseVH = _window_height*5/2-40;
        }else{
            //中间的
            pauseVH = _window_height*3/2-40;
        }
        
        pasueView = [[videoPauseView alloc]initWithFrame:CGRectMake(_window_width/2-40, pauseVH, 80, 80) andVideoMsg:_hostdic];
        pasueView.delegate = self;
        [_backScrollView addSubview:pasueView];
        //暂停
        pasueView.fromWhere = _fromWhere;
        [_currentPlayerIV jp_pause];
    }else {
        //播放
        if (_currentPlayerIV.jp_playerStatus == JPVideoPlayerStatusPause) {
            [pasueView removeFromSuperview];
            pasueView = nil;
             [_currentPlayerIV jp_resume];
        }
    }
   
    
    
}
#pragma mark ================ pasueViewDelegate ===============
- (void)goPlay{
    if (pasueView) {
        [pasueView removeFromSuperview];
        pasueView = nil;
    }
    [_currentPlayerIV jp_resume];
    
}
#pragma mark - 删除自己的视频
- (void)videoDel:(id)videoIDStr {
    if (_videomore) {
        self.tabBarController.tabBar.hidden = NO;
        [_videomore removeFromSuperview];
        _videomore = nil;
    }
    if ([videoIDStr isEqual:@"取消删除"]) {
        return;
    }
    
    /*
     *  推荐 删除:列表有数据规则(删除当前视频后先向下滑动，如果当前是最后一个向上滑动，如果没有就不动)
     */
    if (!_fromWhere) {
        CGPoint currentPoint =  _backScrollView.contentOffset;
        if (_curentIndex+1>=_videoList.count) {
            //手势向下滚
            _curentIndex--;
            if (_curentIndex<0) {
                _curentIndex=0;
            }
            
            _currentFront.followBtn.hidden = YES;
            currentPoint = CGPointMake(0, currentPoint.y-_window_height);
        }else {
            //手势向上滚
            //此时不需要_curentIndex++,因为是先删除数组的元素🈶切换的房间
            _currentFront.followBtn.hidden = YES;
            currentPoint = CGPointMake(0, currentPoint.y+_window_height);
        }
        CGRect will_rect = CGRectMake(0, currentPoint.y, _window_width, _window_height);
        [_backScrollView scrollRectToVisible:will_rect animated:YES];
        
        //从 _videoList 剔除删除的视频
        NSDictionary *delDic = [NSDictionary dictionary];
        for (NSDictionary*video_Dic in _videoList) {
            NSString *dic_videoID = [NSString stringWithFormat:@"%@",[video_Dic valueForKey:@"id"]];
            if ([dic_videoID isEqual:videoIDStr]) {
                delDic = video_Dic;
                break;
            }
        }
        [_videoList removeObject:delDic];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self changeRoom];
        });
    }else {
        
//        [Config saveSignOfDelVideo:@"1"];
        if (self.block && _videoList.count > 1) {
            self.block(_videoList, _pages, _curentIndex);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
//分享
-(void)doenjoy{
    [self morebtn:nil];
}
-(void)morebtn:(id)sender {
    //    if ([[Config getOwnID] intValue]<0) {
    //        [PublicObj warnLogin];
    //        return;
    //    }
    if (!_videomore) {
        WeakSelf;
        NSArray *array = @[];//[common share_type];
        CGFloat hh = _window_height/3+30+ShowDiff;
        if (array.count == 0) {
            hh = _window_height/3/2+30+ShowDiff;
        }
        _videomore = [[videoMoreView alloc]initWithFrame:CGRectMake(0, _window_height+20, _window_width, hh) andHostDic:_hostdic cancleblock:^(id array) {
            [weakSelf hideMoreView];
        } delete:^(id array) {
            [weakSelf videoDel:array];
        } share:^(id array) {
            [self getVideoWithFollowAnmation:NO];
            weakSelf.shares = array;
            [weakSelf.currentFront.enjoyBtn setTitle:[NSString stringWithFormat:@"%@",weakSelf.shares] forState:0];
        }];
        _videomore.fromWhere = _fromWhere;
        _videomore.jubaoBlock = ^(id array) {
            jubaoVC *jubao = [[jubaoVC alloc]init];
//            jubao.dongtaiId = array;
//            jubao.fromWhere = weakSelf.fromWhere ? weakSelf.fromWhere:@"LookVideo";
            [weakSelf presentViewController:jubao animated:YES completion:nil];
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
    
    self.tabBarController.tabBar.hidden = YES;
    WeakSelf;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.videomore.frame = CGRectMake(0, _window_height - _window_height/3-50-ShowDiff, _window_width, _window_height/3+50+ShowDiff);
        NSArray *array = @[];//[common share_type];
        //如果没有分享
        if (array.count == 0) {
            weakSelf.videomore.frame = CGRectMake(0, _window_height - _window_height/3/2-50-ShowDiff, _window_width, _window_height/3/2+50+ShowDiff);
        }
        weakSelf.videomore.hidden = NO;
    }];
}
-(void)hideMoreView{
    
    if (!_fromWhere) {
        self.tabBarController.tabBar.hidden = NO;
    }
    WeakSelf;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.videomore.frame = CGRectMake(0, _window_height +20, _window_width, _window_height/2.2);
        NSArray *array = @[];//[common share_type];
        if (array.count == 0) {
            weakSelf.videomore.frame = CGRectMake(0, _window_height +20, _window_width, _window_height/2.2/2);
        }
        weakSelf.videomore.hidden = YES;
    }];
}
//点赞
-(void)dolike{
    if ([[Config getOwnID] intValue]<0) {
        [PublicObj warnLogin];
        return;
    }
    //可以取消-注释掉
    /*
     if ([_islike isEqual:@"1"]){
     return;
     }
     */
    [self checkLiveSuc:@"0"];
    
    
}
- (void)checkLiveSuc:(NSString *)isFull{

    NSString *url = [purl stringByAppendingFormat:@"?service=Video.addLike&uid=%@&videoid=%@&type=%@&token=%@",[Config getOwnID],_videoid,isFull,[Config getOwnToken]];
    
    
}
//评论列表
- (void)messgaebtn {
    
//    if ([[Config getOwnID] intValue]<=0) {
//        [PublicObj warnLogin];
//        return;
//    }
    
    if (_comment) {
        [_comment removeFromSuperview];
        _comment = nil;
    }
    
    WeakSelf;
    if (!_comment) {
        _comment = [[commentview alloc]initWithFrame:CGRectMake(0,_window_height, _window_width, _window_height) hide:^(NSString *type) {
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.comment.frame = CGRectMake(0, _window_height, _window_width, _window_height);
                //显示tabbar
                self.tabBarController.tabBar.hidden = NO;
            } ];
        } andvideoid:_videoid andhostid:_hostid count:[_comments intValue] talkCount:^(id type) {
            [self getVideoWithFollowAnmation:NO];
            //刷新评论数显示
            [weakSelf.currentFront.commentBtn setTitle:[NSString stringWithFormat:@"%@",type] forState:0];
            weakSelf.comments = type;
        } detail:^(id type) {
            [weakSelf pushdetails:type];
        } youke:^(id type) {
            [PublicObj warnLogin];
        } andFrom:_fromWhere];
        
        //[self.view addSubview:comment];
        
        if (_fromWhere) {
            //从其他页面push过来 没self.tabBarController
            [self.view addSubview:_comment];
        }else{
            //一定加在self.tabBarController.view或者  window上
            [self.tabBarController.view addSubview:_comment];
        }
    }
    
    _comment.fromWhere = _fromWhere;
    [_comment getNewCount:[_comments intValue]];
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.comment.frame = CGRectMake(0,0,_window_width, _window_height);
        //隐藏tabbar
        self.tabBarController.tabBar.hidden = YES;
    }];
}
-(void)pushdetails:(NSDictionary *)type{
    /* 废弃
    YBWeakSelf;
    [_comment endEditing:YES];
    _comment.hidden = YES;
    commectDetails *detail = [[commectDetails alloc]init];
    detail.hostDic = type;
    detail.event = ^{
        weakSelf.comment.hidden = NO;
    };

    [self.navigationController pushViewController:detail animated:YES];
     */
}
-(void)pushmessage{
    
    if ([[Config getOwnID] intValue] < 0) {
        [_textField resignFirstResponder];
        [PublicObj warnLogin];
        return;
    }
    /*
     parentid  回复的评论ID
     commentid 回复的评论commentid
     touid     回复的评论UID
     如果只是评论 这三个传0
     */
    if (_textField.text.length == 0 || _textField.text == NULL || _textField.text == nil || [_textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        [MBProgressHUD showError:@"请添加内容后再尝试"];
        return;
    }
    NSString *path = _textField.text;
    NSString *at_json = @"";
    //转json、去除空格、回车
    if (_atArray.count>0) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_atArray options:NSJSONWritingPrettyPrinted error:nil];
        at_json = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        at_json = [at_json stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        at_json = [at_json stringByReplacingOccurrencesOfString:@" " withString:@""];
        at_json = [at_json stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    NSString *url = [purl stringByAppendingFormat:@"/?service=Video.setComment&videoid=%@&content=%@&uid=%@&token=%@&touid=%@&commentid=%@&parentid=%@&at_info=%@",_videoid,path,[Config getOwnID],[Config getOwnToken],_hostid,@"0",@"0",at_json];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    WeakSelf;
//    [YBNetworking postWithUrl:url Dic:nil Suc:^(NSDictionary *data, NSString *code, NSString *msg) {
//        if([code isEqual:@"0"]){
//            //更新评论数量
//            NSDictionary *info = [[data valueForKey:@"info"] firstObject];
//            NSString *newComments = [NSString stringWithFormat:@"%@",[info valueForKey:@"comments"]];
//            weakSelf.comments = newComments;
//            [weakSelf.currentFront.commentBtn setTitle:[NSString stringWithFormat:@"%@",newComments] forState:0];
//            if (weakSelf.comment) {
//                [weakSelf.comment getNewCount:[newComments intValue]];
//            }
//
//            [MBProgressHUD showError:minstr([data valueForKey:@"msg"])];
//            weakSelf.textField.text = @"";
//            [_atArray removeAllObjects];
//            weakSelf.textField.placeholder = @"说点什么...";
//            [self.view endEditing:YES];
//
//        }else if ([code isEqual:@"700"]) {
//            [PublicObj tokenExpired:[data valueForKey:@"msg"]];
//        }else{
//            [MBProgressHUD showError:minstr([data valueForKey:@"msg"])];
//            weakSelf.textField.text = @"";
//            [_atArray removeAllObjects];
//            weakSelf.textField.placeholder = @"说点什么...";
//            [self.view endEditing:YES];
//        }
//    } Fail:nil];
    
}

#pragma mark - set/get
- (UIButton *)goBackBtn{
    if (!_goBackBtn) {
        //左
        _goBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _goBackBtn.frame = CGRectMake(10, 22+statusbarHeight, 40, 40);
        _goBackBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [_goBackBtn setImage:[UIImage imageNamed:@"video_返回"] forState:0];
        [_goBackBtn addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
        
        //左shadow
        _goBackShadow = [UIButton buttonWithType:UIButtonTypeCustom];
        _goBackShadow.frame = CGRectMake(0, 0, 64, 64+statusbarHeight);
        [_goBackShadow addTarget:self action:@selector(clickLeftBtn) forControlEvents:UIControlEventTouchUpInside];
        _goBackShadow.backgroundColor = [UIColor clearColor];
    }
    return _goBackBtn;
}

-(UIScrollView *)backScrollView{
    if (!_backScrollView) {
        _backScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        _backScrollView.contentSize =  CGSizeMake(_window_width, _window_height*3);
        _backScrollView.userInteractionEnabled = YES;
        _backScrollView.pagingEnabled = YES;
        _backScrollView.showsVerticalScrollIndicator = NO;
        _backScrollView.showsHorizontalScrollIndicator =NO;
        _backScrollView.delegate = self;
        _backScrollView.scrollsToTop = NO;
        _backScrollView.bounces = NO;
        _backScrollView.backgroundColor = [UIColor clearColor];
        
        _firstImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        _firstImageView.image = [UIImage imageNamed:@""];
        _firstImageView.contentMode = UIViewContentModeScaleAspectFit;
        _firstImageView.clipsToBounds = YES;
        _firstImageView.backgroundColor = [UIColor blackColor];
        [_backScrollView addSubview:_firstImageView];
        _firstImageView.jp_videoPlayerDelegate = self;
        
        _secondImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, _window_height)];
        _secondImageView.image = [UIImage imageNamed:@""];
        _secondImageView.contentMode = UIViewContentModeScaleAspectFit;
        _secondImageView.clipsToBounds = YES;
        [_backScrollView addSubview:_secondImageView];
        _secondImageView.jp_videoPlayerDelegate = self;
        _secondImageView.backgroundColor = [UIColor blackColor];

        _thirdImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _window_height*2, _window_width, _window_height)];
        _thirdImageView.image = [UIImage imageNamed:@""];
        _thirdImageView.contentMode = UIViewContentModeScaleAspectFit;
        _thirdImageView.clipsToBounds = YES;
        [_backScrollView addSubview:_thirdImageView];
        _thirdImageView.jp_videoPlayerDelegate = self;
        _thirdImageView.backgroundColor = [UIColor blackColor];

        WeakSelf;
        _firstFront = [[FrontView alloc]initWithFrame:_firstImageView.frame callBackEvent:^(NSString *type) {
            [weakSelf clickEvent:type];
        }];
        [_backScrollView addSubview:_firstFront];
        
        _secondFront = [[FrontView alloc]initWithFrame:_secondImageView.frame callBackEvent:^(NSString *type) {
            [weakSelf clickEvent:type];
        }];
        [_backScrollView addSubview:_secondFront];
        
        _thirdFront = [[FrontView alloc]initWithFrame:_thirdImageView.frame callBackEvent:^(NSString *type) {
            [weakSelf clickEvent:type];
        }];
        [_backScrollView addSubview:_thirdFront];
    }
    
    return _backScrollView;
}
#pragma mark - 输入框
-(void)showtextfield{
    if (!_toolBar) {
        _toolBar = [[UIView alloc]initWithFrame:CGRectMake(0,_window_height - 50-ShowDiff, _window_width, 50+ShowDiff)];
        _toolBar.backgroundColor = [RGB(32, 28, 54) colorWithAlphaComponent:0.2];//RGB(27, 25, 41);;//RGB(248, 248, 248);
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
        _textField.placeholderColor = RGB(150, 150, 150);
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
        tv_bg.backgroundColor = [RGB(44, 40, 64) colorWithAlphaComponent:0.2];
        tv_bg.layer.masksToBounds = YES;
        tv_bg.layer.cornerRadius = _textField.layer.cornerRadius;
        [_toolBar addSubview:tv_bg];
        [_toolBar addSubview:_textField];
        
        _finishbtn = [UIButton buttonWithType:0];
        _finishbtn.frame = CGRectMake(_window_width - 44,8,34,34);
        [_finishbtn setImage:[UIImage imageNamed:@"chat_face.png"] forState:0];
        [_finishbtn addTarget:self action:@selector(atFrends) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar addSubview:_finishbtn];
    }
    if (!_emojiV) {
        _emojiV = [[twEmojiView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, EmojiHeight+ShowDiff)];
        _emojiV.delegate = self;
        [self.view addSubview:_emojiV];
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
    
//    [self prepareTextMessage:_toolBarContainer.toolbar.textView.text];
    [self pushmessage];
}

#pragma mark - 网络监听
- (void)checkNetwork{
    AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
    [netManager startMonitoring];  //开始监听 防止第一次安装不显示
    [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        if (status == AFNetworkReachabilityStatusNotReachable) {
            _pages = 1;
//            [self requestMoreVideo];
            return;
        }else if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable){
            NSLog(@"nonetwork-------");
            _pages = 1;
            [self requestMoreVideo];
        }else if ((status == AFNetworkReachabilityStatusReachableViaWWAN)||(status == AFNetworkReachabilityStatusReachableViaWiFi)){
            _pages = 1;
            [self requestMoreVideo];
            NSLog(@"wifi-------");
        }
    }];
}
#pragma mark ============查看商品=============

- (void)showGoodsDeatile{
    
    NSString *goodsid = minstr([_hostdic valueForKey:@"goodsid"]);
    NSLog(@"yyyyyyyyyyyyy----isgoods:%@ \n  dic:%@",goodsid, _hostdic);
//    if (goodsDView) {
//        [goodsDView removeFromSuperview];
//        goodsDView = nil;
//    }
//    goodsDView = [[lookVGoodsDView alloc]initWithGoodsMsg:[_hostdic valueForKey:@"goodsinfo"]];
//    goodsDView.videoid = _videoid;
//    goodsDView.videoUserid = _hostid;
//    [[UIApplication sharedApplication].delegate.window addSubview:goodsDView];
}

@end
/*
 - (void)changeCurrentImageView{
 //增量:根据 _curentIndex 设置上、中、下封面图以及数据
 int incNum;
 if (_curentIndex==0) {
 //第一个视频
 incNum = 1;
 }else if(_curentIndex == _videoList.count-1){
 //最后一个
 incNum = -1;
 }else{
 //中间
 incNum = 0;
 }
 
 for (int i = 0; i<_videoList.count; i++) {
 
 if (i==_curentIndex+incNum-1) {
 [_firstImageView sd_setImageWithURL:[NSURL URLWithString:minstr([_videoList[i] valueForKey:@"thumb"])]];
 [self setUserData:_videoList[i] withFront:_firstFront];
 [self setVideoData:_videoList[i] withFront:_firstFront];
 }
 if (i==_curentIndex+incNum) {
 [_secondImageView sd_setImageWithURL:[NSURL URLWithString:minstr([_videoList[i] valueForKey:@"thumb"])]];
 [self setUserData:_videoList[i] withFront:_secondFront];
 [self setVideoData:_videoList[i] withFront:_secondFront];
 }
 if (i==_curentIndex+incNum+1) {
 [_thirdImageView sd_setImageWithURL:[NSURL URLWithString:minstr([_videoList[i] valueForKey:@"thumb"])]];
 [self setUserData:_videoList[i] withFront:_thirdFront];
 [self setVideoData:_videoList[i] withFront:_thirdFront];
 }
 }
 
 }
 
 */

