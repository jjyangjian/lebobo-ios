//
//  SWYBLookVideoVC.h
//  yunbaolive
//
//  Created by ybRRR on 2020/9/17.
//  Copyright © 2020 cat. All rights reserved.
//

#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFPlayerControlView.h>
#import <ZFPlayer/ZFIJKPlayerManager.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
NS_ASSUME_NONNULL_BEGIN

@interface SWYBLookVideoVC : SWBaseViewController

@property (nonatomic, assign) ZFPlayerScrollViewDirection scrollViewDirection; //滚动方向(垂直、横向)
@property(nonatomic,strong)NSString *fromWhere;
/**
 *  从消息顶部的 赞、评论、@ 功能 进来不能上下滑动 sourceBaseUrl传空字符串即可
 */
@property(nonatomic,strong)NSString *sourceBaseUrl;

@property(nonatomic,assign)BOOL firstPush;                  //第一次从其他页面跳转
@property(nonatomic,assign) NSInteger pushPlayIndex;        //第一次从第几个开始播放

@property(nonatomic,strong)NSMutableArray *videoList;
@property (nonatomic,assign) NSInteger pages;

@end

NS_ASSUME_NONNULL_END
