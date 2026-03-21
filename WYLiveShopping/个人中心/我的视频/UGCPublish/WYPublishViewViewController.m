//
//  WYPublishViewViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "WYPublishViewViewController.h"
#import "MyTextView.h"
#import "PublishShareV.h"
#import "JPVideoPlayerKit.h"
#import "WYVideoClassVC.h"
#import "WYVideoAddGoodsVC.h"
#import <Qiniu/QiniuSDK.h>
#import "AddGoodsViewController.h"

@interface WYPublishViewViewController ()<UITextViewDelegate>{
    NSString *thumbURLString;
    NSString *videoURLString;
    NSString *sharetype;
    NSString *videoID;
    NSString *videoImage;
}
/** 背景scorll */
@property(nonatomic,strong)UIScrollView *bgScrollView;

/** 顶部组合：视频预览、视频描述 */
@property(nonatomic,strong)UIView   *topMix;
@property(nonatomic,strong)UIView  *videoPreview;               //视频预览
@property(nonatomic,strong)MyTextView  *videoDesTV;             //视频描述
@property(nonatomic,strong) UILabel *wordsNumL;                 //字符统计


/** 分享平台组合 */
@property(nonatomic,strong)PublishShareV *platformV;

/** 发布按钮 */
@property(nonatomic,strong)UIButton *publishBtn;
//商品
@property(nonatomic,strong)UIView *shopView;
@property (nonatomic,strong) UILabel *shopLabel;
@property (nonatomic,strong) NSMutableDictionary *shopDic;

//分类
@property(nonatomic,strong)UIView *videoClassView;
@property(nonatomic,strong)UILabel *videoClassL;
@property(nonatomic,strong)NSDictionary *videoClassDic;


@end

@implementation WYPublishViewViewController
#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView*)textView {

    NSString *toBeString = textView.text;
    NSString *lang = [[[UITextInputMode activeInputModes]firstObject] primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > 50) {
                textView.text = [toBeString substringToIndex:50];
                _wordsNumL.text = [NSString stringWithFormat:@"%lu/50",(50-textView.text.length)];
            }else{
                _wordsNumL.text = [NSString stringWithFormat:@"%lu/50",(50-toBeString.length)];
            }
        }else{
            //有高亮选择的字符串，则暂不对文字进行统计和限制
        }
    }else{
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > 50) {
            textView.text = [toBeString substringToIndex:50];
            _wordsNumL.text = [NSString stringWithFormat:@"%lu/50",(50-textView.text.length)];
        }else{
            _wordsNumL.text = [NSString stringWithFormat:@"%lu/50",(50-toBeString.length)];
        }
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"发布视频";
    thumbURLString = @"";
    videoURLString = @"";
    [self.view addSubview:self.bgScrollView];
    [_videoPreview jp_playVideoWithURL:[NSURL fileURLWithPath:_videoPath]];
}
- (UIScrollView *)bgScrollView {
    if (!_bgScrollView) {
        _bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight)];
        _bgScrollView.bounces = NO;
        //顶部视图：预览、描述
        [_bgScrollView addSubview:self.topMix];
                
        //分类
        [_bgScrollView addSubview:self.videoClassView];

        
        [_bgScrollView addSubview:self.shopView];

        //分享平台
        [_bgScrollView addSubview:self.platformV];
        //发布
        [_bgScrollView addSubview:self.publishBtn];
        
        [_bgScrollView layoutIfNeeded];
        CGFloat maxY = CGRectGetMaxY(_publishBtn.frame)+10;
        if (maxY < _window_height-64-statusbarHeight-ShowDiff) {
            maxY = _window_height-64-statusbarHeight-ShowDiff;
        }
        _bgScrollView.contentSize = CGSizeMake(0, maxY);
        
    }
    return _bgScrollView;
}

-(UIView *)topMix {
    if (!_topMix) {
        _topMix = [[UIView alloc] initWithFrame:CGRectMake(15, 10, _window_width-30, 180)];
        
        //视频预览
        _videoPreview = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 100, 150)];
        
        //视频描述
        _videoDesTV = [[MyTextView alloc] initWithFrame:CGRectMake(_videoPreview.right+10, 15, _topMix.width-_videoPreview.width - 35, _videoPreview.height)];
        _videoDesTV.backgroundColor = [UIColor clearColor];
        _videoDesTV.delegate = self;
        _videoDesTV.layer.borderColor = _topMix.backgroundColor.CGColor;
        _videoDesTV.font = SYS_Font(13);
        _videoDesTV.textColor = color32;
        _videoDesTV.placeholder = @"添加视频描述~";
        _videoDesTV.placeholderColor = RGB_COLOR(@"#969696", 1);
        
        _wordsNumL = [[UILabel alloc] initWithFrame:CGRectMake(_videoDesTV.right-50, _videoDesTV.bottom-12, 50, 12)];
        _wordsNumL.text = @"0/50";
        _wordsNumL.textColor = RGB_COLOR(@"#969696", 1);
        _wordsNumL.font = [UIFont systemFontOfSize:12];
        _wordsNumL.backgroundColor =[UIColor clearColor];
        _wordsNumL.textAlignment = NSTextAlignmentRight;
        
        [_topMix addSubview:_videoPreview];
        [_topMix addSubview:_videoDesTV];
        [_topMix addSubview:_wordsNumL];
        
    }
    return _topMix;
}



- (UIView *)videoClassView {
    if (!_videoClassView) {
        _videoClassView = [[UIView alloc]initWithFrame:CGRectMake(15, _topMix.bottom+10, _window_width-30, 50)];
        
        UIImageView *imageloca = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"视频-分类"]];
        imageloca.contentMode = UIViewContentModeScaleAspectFit;
        imageloca.frame = CGRectMake(15,50/2-7.5,15,15);
        [_videoClassView addSubview:imageloca];
        
        _videoClassL = [[UILabel alloc]initWithFrame:CGRectMake(imageloca.right+5, 0, _videoClassView.width-50, 50)];
        _videoClassL.font = SYS_Font(14);
        _videoClassL.text = @"视频分类";
        _videoClassL.textColor = color32;
        [_videoClassView addSubview:_videoClassL];
        
        UIImageView *rightImgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"askWhite_jiantou"]];
        rightImgV.contentMode = UIViewContentModeScaleAspectFit;
        rightImgV.frame = CGRectMake(_videoClassView.width-20,50/2-7.5,15,15);
        [_videoClassView addSubview:rightImgV];
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(0, 0, _videoClassView.width, _videoClassView.height);
        [btn addTarget:self action:@selector(clikcVideoClassBtn) forControlEvents:UIControlEventTouchUpInside];
        [_videoClassView addSubview:btn];
        [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 0, _videoClassView.width, 1) andColor:colorf0 andView:_videoClassView];

    }
    return _videoClassView;
}

-(UIView *)shopView {
    if (!_shopView) {
        //商品
        _shopView = [[UIView alloc]initWithFrame:CGRectMake(15,  _videoClassView.bottom+5, _window_width-30, 50)];
        
        UIImageView *imageloca = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"video_shop"]];
        imageloca.contentMode = UIViewContentModeScaleAspectFit;
        imageloca.frame = CGRectMake(15,50/2-7.5,15,15);
        [_shopView addSubview:imageloca];
        
        _shopLabel = [[UILabel alloc]initWithFrame:CGRectMake(imageloca.right+5, 0, _shopView.width-50, 50)];
        _shopLabel.font = SYS_Font(14);
        _shopLabel.text = @"关联商品";
        _shopLabel.textColor = color32;
        [_shopView addSubview:_shopLabel];
        
        UIImageView *rightImgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"askWhite_jiantou"]];
        rightImgV.contentMode = UIViewContentModeScaleAspectFit;
        rightImgV.frame = CGRectMake(_shopView.width-20,50/2-7.5,15,15);
        [_shopView addSubview:rightImgV];
        
        UIButton *btn = [UIButton buttonWithType:0];
        btn.frame = CGRectMake(0, 0, _shopView.width, _shopView.height);
        [btn addTarget:self action:@selector(addShopClick) forControlEvents:UIControlEventTouchUpInside];
        [_shopView addSubview:btn];
        [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 0, _shopView.width, 1) andColor:colorf0 andView:_shopView];
        [[WYToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, _shopView.height-1, _shopView.width, 1) andColor:colorf0 andView:_shopView];

    }
    return _shopView;
}

- (PublishShareV *)platformV {
    if (!_platformV) {
            _platformV = [[PublishShareV alloc]initWithFrame:CGRectMake(15,_shopView.bottom+15, _window_width-30, _window_width/4+30)];
        _platformV.backgroundColor = [UIColor clearColor];
        _platformV.shareEvent = ^(NSString *type) {
            sharetype = type;
            NSLog(@"share:%@",type);
        };
    }
    return _platformV;
}

-(UIButton *)publishBtn {
    if (!_publishBtn) {
        _publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _publishBtn.frame = CGRectMake(30, _platformV.bottom+20, _window_width-60, 40);
        [_publishBtn setTitle:@"确认发布" forState:0];
        [_publishBtn setTitleColor:[UIColor whiteColor] forState:0];
        _publishBtn.backgroundColor = normalColors;
        _publishBtn.layer.masksToBounds = YES;
        _publishBtn.layer.cornerRadius = 20;
        [_publishBtn addTarget:self action:@selector(clickPublishBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishBtn;
}
#pragma mark - 视频分类
-(void)clikcVideoClassBtn {
    
    WYVideoClassVC *videoClass = [[WYVideoClassVC alloc]init];
    WeakSelf;
    videoClass.videoClassEvent = ^(NSDictionary * _Nonnull dic) {
        weakSelf.videoClassDic = dic;
        weakSelf.videoClassL.text = minstr([dic valueForKey:@"name"]);
    };
    [[MXBADelegate sharedAppDelegate] pushViewController:videoClass animated:YES];
    
}
#pragma mark - 商品
- (void)addShopClick{
    WeakSelf;
    AddGoodsViewController *goodsVC = [[AddGoodsViewController alloc]init];
    goodsVC.isVideo = YES;
    if (_shopDic) {
        goodsVC.goodsID = minstr([_shopDic valueForKey:@"id"]);
    }
    goodsVC.block = ^(NSDictionary * _Nonnull dic) {
        weakSelf.shopLabel.text = minstr([dic valueForKey:@"name"]);
        weakSelf.shopDic = dic.mutableCopy;
    };
    [[MXBADelegate sharedAppDelegate]pushViewController:goodsVC animated:YES];
}
- (void)dealloc {
    if (_videoPreview) {
        [_videoPreview jp_stopPlay];
        [_videoPreview removeFromSuperview];
        _videoPreview = nil;
    }
}

- (void)clickPublishBtn{
    if (_videoDesTV.text.length == 0) {
        [MBProgressHUD showError:@"请添加视频描述~"];
        return;
    }
    if (!_videoClassDic) {
        [MBProgressHUD showError:@"请选择视频分类"];
        return;
    }

    [MBProgressHUD showMessage:@"正在上传"];
    [WYToolClass getQCloudWithUrl:@"getupload" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [self doUploadToQiniuForImage:info];
        }else{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:msg];
        }
    } Fail:^{
        
    }];
}
- (void)doUploadToQiniuForImage:(NSDictionary *)dic{
    NSString *token = [WYToolClass decrypt:minstr([dic valueForKey:@"token"])];
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [self getQNZone:minstr([dic valueForKey:@"region"])];
    }];
    QNUploadOption *option = [[QNUploadOption alloc]initWithMime:nil progressHandler:^(NSString *key, float percent) {
        
    } params:nil checkCrc:NO cancellationSignal:nil];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    NSData *imageData = UIImagePNGRepresentation(_coverImage);
    NSString *imageName = [WYToolClass getNameBaseCurrentTime:@"videothumb.png"];
    [upManager putData:imageData key:[NSString stringWithFormat:@"image_%@",imageName] token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (info.ok) {
            thumbURLString = key;
            NSLog(@"thumbURLString = %@",thumbURLString);
            [self doUploadToQiniuForVideo:dic];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"提交失败"];
            });
            return ;
        }
    } option:option];

}
- (void)doUploadToQiniuForVideo:(NSDictionary *)dic{
    NSString *token = [WYToolClass decrypt:minstr([dic valueForKey:@"token"])];
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [self getQNZone:minstr([dic valueForKey:@"region"])];
    }];
    QNUploadOption *option = [[QNUploadOption alloc]initWithMime:nil progressHandler:^(NSString *key, float percent) {
        
    } params:nil checkCrc:NO cancellationSignal:nil];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    NSString *videoName = [WYToolClass getNameBaseCurrentTime:@"video.mp4"];
    //传图片
    [upManager putFile:_videoPath key:videoName token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (info.ok) {
            videoURLString = key;
            NSLog(@"videoURLString = %@",videoURLString);
            [self doUpload];
        }
        else {
            //视频失败
            NSLog(@"%@",info.error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"提交失败"];
            });

        }

    } option:option];

}
- (void)doUpload{
    [WYToolClass postNetworkWithUrl:@"setvideo" andParameter:@{
            @"catid":minstr([_videoClassDic valueForKey:@"id"]),
            @"name":_videoDesTV.text,
            @"thumb":thumbURLString,
            @"url":videoURLString,
            @"goodsid":_shopDic ? minstr([_shopDic valueForKey:@"id"]) : @"0"
        } success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            if ([sharetype isEqual:@"wx"]) {
                videoID = minstr([info valueForKey:@"id"]);
                videoImage = minstr([info valueForKey:@"thumb"]);
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@\n正在分享",msg]];
                [self simplyShare];
            }else{
                [MBProgressHUD showError:msg];
                [self doReturn];
            }
        }else
        {
            [MBProgressHUD showError:msg];

        }
    } fail:^{
        
    }];
}
#pragma makr - 七牛划分区域开始
-(QNZone *)getQNZone:(NSString *)qnStr{
//    存储区域 z0华东 z1华北 z2华南 na0北美 as0东南亚 cn-east-2华东-浙江2
    //默认:华东
    QNZone *zone = [QNFixedZone zone0];
    if ([qnStr isEqual:@"z1"]) {
        //华北
        zone = [QNFixedZone zone1];
        
    }else if ([qnStr isEqual:@"z2"]){
        //华南
        zone = [QNFixedZone zone2];
        
    }else if ([qnStr isEqual:@"na0"]){
        //北美
        zone = [QNFixedZone zoneNa0];
        
    }else if ([qnStr isEqual:@"as0"]){
        //新加坡
        zone = [QNFixedZone zoneAs0];
    }
    return zone;
}
-(void)doReturn{
    if (_videoPreview) {
        [_videoPreview jp_stopPlay];
        [_videoPreview removeFromSuperview];
        _videoPreview = nil;
    }
    [super doReturn];
}

- (void)simplyShare
{
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    int SSDKContentType = SSDKContentTypeAuto;
    NSURL *ParamsURL;

    ParamsURL = [NSURL URLWithString:[h5url stringByAppendingFormat:@"/appapi/video/index?id=%@",videoID]];

    [shareParams SSDKSetupShareParamsByText:@""
                                     images:videoImage
                                        url:ParamsURL
                                      title:minstr(_videoDesTV.text)
                                       type:SSDKContentType];
    
    WeakSelf;
    //进行分享
    [ShareSDK share:SSDKPlatformSubTypeWechatSession
         parameters:shareParams
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
         switch (state) {
             case SSDKResponseStateSuccess:
             {
                 [MBProgressHUD showSuccess:@"分享成功"];
                 [weakSelf addShare];
                 break;
             }
             case SSDKResponseStateFail:
             {
                 [MBProgressHUD showError:@"分享失败"];
                 break;
             }
             case SSDKResponseStateCancel:
             {
                 break;
             }
             default:
                 break;
         }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doReturn];
        });

     }];
}
-(void)addShare{
    NSDictionary *dic = @{
        @"vid":videoID,
        @"sign":[WYToolClass sortString:@{@"vid":videoID}]
    };
    [WYToolClass postNetworkWithUrl:@"videoshare" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {

    } fail:^{
        
    }];
    

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
