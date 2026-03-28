//
//  SWPublishViewVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWPublishViewVC.h"
#import "SWMyTextView.h"
#import "SWPublishShareV.h"
#import "JPVideoPlayerKit.h"
#import "SWVideoClassVC.h"
#import "SWVideoAddGoodsVC.h"
#import <Qiniu/QiniuSDK.h>
#import "SWAddGoodsViewController.h"

@interface SWPublishViewVC ()<UITextViewDelegate>
@property (nonatomic, copy) NSString *thumbURLString;
@property (nonatomic, copy) NSString *videoURLString;
@property (nonatomic, copy) NSString *shareType;
@property (nonatomic, copy) NSString *videoID;
@property (nonatomic, copy) NSString *videoImage;
@property(nonatomic,strong) UIScrollView *bgScrollView;
@property(nonatomic,strong) UIView *topMix;
@property(nonatomic,strong) UIView *videoPreview;
@property(nonatomic,strong) SWMyTextView *videoDesTV;
@property(nonatomic,strong) UILabel *wordsNumL;
@property(nonatomic,strong) SWPublishShareV *platformV;
@property(nonatomic,strong) UIButton *publishBtn;
@property(nonatomic,strong) UIView *shopView;
@property (nonatomic,strong) UILabel *shopLabel;
@property (nonatomic,strong) NSMutableDictionary *shopDic;
@property(nonatomic,strong) UIView *videoClassView;
@property(nonatomic,strong) UILabel *videoClassL;
@property(nonatomic,strong) NSDictionary *videoClassDic;

@end

@implementation SWPublishViewVC
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
                self.wordsNumL.text = [NSString stringWithFormat:@"%lu/50",(50-textView.text.length)];
            }else{
                self.wordsNumL.text = [NSString stringWithFormat:@"%lu/50",(50-toBeString.length)];
            }
        }
    }else{
        if (toBeString.length > 50) {
            textView.text = [toBeString substringToIndex:50];
            self.wordsNumL.text = [NSString stringWithFormat:@"%lu/50",(50-textView.text.length)];
        }else{
            self.wordsNumL.text = [NSString stringWithFormat:@"%lu/50",(50-toBeString.length)];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"发布视频";
    self.thumbURLString = @"";
    self.videoURLString = @"";
    [self.view addSubview:self.bgScrollView];
    [self.videoPreview jp_playVideoWithURL:[NSURL fileURLWithPath:self.videoPath]];
}

- (UIScrollView *)bgScrollView {
    if (!_bgScrollView) {
        _bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-64-statusbarHeight)];
        _bgScrollView.bounces = NO;
        [_bgScrollView addSubview:self.topMix];
        [_bgScrollView addSubview:self.videoClassView];
        [_bgScrollView addSubview:self.shopView];
        [_bgScrollView addSubview:self.platformV];
        [_bgScrollView addSubview:self.publishBtn];

        [_bgScrollView layoutIfNeeded];
        CGFloat maxY = CGRectGetMaxY(self.publishBtn.frame)+10;
        if (maxY < _window_height-64-statusbarHeight-ShowDiff) {
            maxY = _window_height-64-statusbarHeight-ShowDiff;
        }
        _bgScrollView.contentSize = CGSizeMake(0, maxY);
    }
    return _bgScrollView;
}

- (UIView *)topMix {
    if (!_topMix) {
        _topMix = [[UIView alloc] initWithFrame:CGRectMake(15, 10, _window_width-30, 180)];
        _videoPreview = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 100, 150)];
        _videoDesTV = [[SWMyTextView alloc] initWithFrame:CGRectMake(self.videoPreview.right+10, 15, _topMix.width-self.videoPreview.width - 35, self.videoPreview.height)];
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

        [_topMix addSubview:self.videoPreview];
        [_topMix addSubview:self.videoDesTV];
        [_topMix addSubview:self.wordsNumL];
    }
    return _topMix;
}

- (UIView *)videoClassView {
    if (!_videoClassView) {
        _videoClassView = [[UIView alloc]initWithFrame:CGRectMake(15, self.topMix.bottom+10, _window_width-30, 50)];

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
        [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 0, _videoClassView.width, 1) andColor:colorf0 andView:_videoClassView];
    }
    return _videoClassView;
}

- (UIView *)shopView {
    if (!_shopView) {
        _shopView = [[UIView alloc]initWithFrame:CGRectMake(15,  self.videoClassView.bottom+5, _window_width-30, 50)];

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
        [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 0, _shopView.width, 1) andColor:colorf0 andView:_shopView];
        [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, _shopView.height-1, _shopView.width, 1) andColor:colorf0 andView:_shopView];
    }
    return _shopView;
}

- (SWPublishShareV *)platformV {
    if (!_platformV) {
        _platformV = [[SWPublishShareV alloc]initWithFrame:CGRectMake(15,self.shopView.bottom+15, _window_width-30, _window_width/4+30)];
        _platformV.backgroundColor = [UIColor clearColor];
        _platformV.shareEvent = ^(NSString *type) {
            self.shareType = type;
            NSLog(@"share:%@",type);
        };
    }
    return _platformV;
}

- (UIButton *)publishBtn {
    if (!_publishBtn) {
        _publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _publishBtn.frame = CGRectMake(30, self.platformV.bottom+20, _window_width-60, 40);
        [_publishBtn setTitle:@"确认发布" forState:0];
        [_publishBtn setTitleColor:[UIColor whiteColor] forState:0];
        _publishBtn.backgroundColor = normalColors;
        _publishBtn.layer.masksToBounds = YES;
        _publishBtn.layer.cornerRadius = 20;
        [_publishBtn addTarget:self action:@selector(clickPublishBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publishBtn;
}

- (void)clikcVideoClassBtn {
    SWVideoClassVC *videoClass = [[SWVideoClassVC alloc]init];
    WeakSelf;
    videoClass.videoClassEvent = ^(NSDictionary * _Nonnull dic) {
        weakSelf.videoClassDic = dic;
        weakSelf.videoClassL.text = minstr([dic valueForKey:@"name"]);
    };
    [[SWMXBADelegate sharedAppDelegate] pushViewController:videoClass animated:YES];
}

- (void)addShopClick{
    WeakSelf;
    SWAddGoodsViewController *goodsVC = [[SWAddGoodsViewController alloc]init];
    goodsVC.isVideo = YES;
    if (self.shopDic) {
        goodsVC.goodsID = minstr([self.shopDic valueForKey:@"id"]);
    }
    goodsVC.block = ^(NSDictionary * _Nonnull dic) {
        weakSelf.shopLabel.text = minstr([dic valueForKey:@"name"]);
        weakSelf.shopDic = dic.mutableCopy;
    };
    [[SWMXBADelegate sharedAppDelegate]pushViewController:goodsVC animated:YES];
}

- (void)dealloc {
    if (self.videoPreview) {
        [self.videoPreview jp_stopPlay];
        [self.videoPreview removeFromSuperview];
        self.videoPreview = nil;
    }
}

- (void)clickPublishBtn{
    if (self.videoDesTV.text.length == 0) {
        [MBProgressHUD showError:@"请添加视频描述~"];
        return;
    }
    if (!self.videoClassDic) {
        [MBProgressHUD showError:@"请选择视频分类"];
        return;
    }

    [MBProgressHUD showMessage:@"正在上传"];
    [SWToolClass getQCloudWithUrl:@"getupload" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
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
    NSString *token = [SWToolClass decrypt:minstr([dic valueForKey:@"token"] )];
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [self getQNZone:minstr([dic valueForKey:@"region"])];
    }];
    QNUploadOption *option = [[QNUploadOption alloc]initWithMime:nil progressHandler:^(NSString *key, float percent) {

    } params:nil checkCrc:NO cancellationSignal:nil];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    NSData *imageData = UIImagePNGRepresentation(self.coverImage);
    NSString *imageName = [SWToolClass getNameBaseCurrentTime:@"videothumb.png"];
    [upManager putData:imageData key:[NSString stringWithFormat:@"image_%@",imageName] token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (info.ok) {
            self.thumbURLString = key;
            NSLog(@"thumbURLString = %@",self.thumbURLString);
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
    NSString *token = [SWToolClass decrypt:minstr([dic valueForKey:@"token"])];
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [self getQNZone:minstr([dic valueForKey:@"region"])];
    }];
    QNUploadOption *option = [[QNUploadOption alloc]initWithMime:nil progressHandler:^(NSString *key, float percent) {

    } params:nil checkCrc:NO cancellationSignal:nil];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    NSString *videoName = [SWToolClass getNameBaseCurrentTime:@"video.mp4"];
    [upManager putFile:self.videoPath key:videoName token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (info.ok) {
            self.videoURLString = key;
            NSLog(@"videoURLString = %@",self.videoURLString);
            [self doUpload];
        }
        else {
            NSLog(@"%@",info.error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:@"提交失败"];
            });
        }
    } option:option];
}

- (void)doUpload{
    [SWToolClass postNetworkWithUrl:@"setvideo" andParameter:@{
            @"catid":minstr([self.videoClassDic valueForKey:@"id"]),
            @"name":self.videoDesTV.text,
            @"thumb":self.thumbURLString,
            @"url":self.videoURLString,
            @"goodsid":self.shopDic ? minstr([self.shopDic valueForKey:@"id"]) : @"0"
        } success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            if ([self.shareType isEqual:@"wx"]) {
                self.videoID = minstr([info valueForKey:@"id"]);
                self.videoImage = minstr([info valueForKey:@"thumb"]);
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@\n正在分享",msg]];
                [self simplyShare];
            }else{
                [MBProgressHUD showError:msg];
                [self doReturn];
            }
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^{

    }];
}

- (QNZone *)getQNZone:(NSString *)qnStr{
    QNZone *zone = [QNFixedZone zone0];
    if ([qnStr isEqual:@"z1"]) {
        zone = [QNFixedZone zone1];
    }else if ([qnStr isEqual:@"z2"]){
        zone = [QNFixedZone zone2];
    }else if ([qnStr isEqual:@"na0"]){
        zone = [QNFixedZone zoneNa0];
    }else if ([qnStr isEqual:@"as0"]){
        zone = [QNFixedZone zoneAs0];
    }
    return zone;
}

- (void)doReturn{
    if (self.videoPreview) {
        [self.videoPreview jp_stopPlay];
        [self.videoPreview removeFromSuperview];
        self.videoPreview = nil;
    }
    [super doReturn];
}

- (void)simplyShare{
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    int SSDKContentType = SSDKContentTypeAuto;
    NSURL *ParamsURL;

    ParamsURL = [NSURL URLWithString:[h5url stringByAppendingFormat:@"/appapi/video/index?id=%@",self.videoID]];

    [shareParams SSDKSetupShareParamsByText:@""
                                     images:self.videoImage
                                        url:ParamsURL
                                      title:minstr(self.videoDesTV.text)
                                       type:SSDKContentType];

    WeakSelf;
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

- (void)addShare{
    NSDictionary *dic = @{
        @"vid":self.videoID,
        @"sign":[SWToolClass sortString:@{@"vid":self.videoID}]
    };
    [SWToolClass postNetworkWithUrl:@"videoshare" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {

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
