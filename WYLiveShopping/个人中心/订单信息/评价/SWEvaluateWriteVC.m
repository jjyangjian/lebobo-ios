//
//  SWEvaluateWriteVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/7.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWEvaluateWriteVC.h"
#import "SWStarView.h"
#import "SWMyTextView.h"

@implementation SWPhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _thumbImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, self.width - 10, self.height - 10)];
        _thumbImgView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbImgView.clipsToBounds = YES;
        [self addSubview:_thumbImgView];
        _delateBtn = [UIButton buttonWithType:0];
        [_delateBtn setBackgroundImage:[UIImage imageNamed:@"photo_delate"] forState:0];
        _delateBtn.frame = CGRectMake(self.width - 10, 0, 10, 10);
        [self addSubview:_delateBtn];
    }
    return self;
}

@end

@interface SWEvaluateWriteVC ()<WYStarViewClickDelegate,TZImagePickerControllerDelegate>
@property (nonatomic, strong) SWStarView *zhiliangStar;
@property (nonatomic, strong) UILabel *zhiliangLabel;
@property (nonatomic, strong) SWStarView *fuwuStar;
@property (nonatomic, strong) UILabel *fuwuLabel;
@property (nonatomic, strong) SWStarView *wuliuStar;
@property (nonatomic, strong) UILabel *wuliuLabel;
@property (nonatomic, strong) UIView *wordAndPicView;
@property (nonatomic, strong) SWMyTextView *textViewInput;
@property (nonatomic, strong) NSMutableArray *picArray;
@property (nonatomic, strong) NSMutableArray *picImageViewArray;
@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) UIButton *picButton;

@end

@implementation SWEvaluateWriteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"商品评价";
    self.picArray = [NSMutableArray array];
    self.picImageViewArray = [NSMutableArray array];
    [self creatUI];
}

- (void)creatUI {
    self.backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, _window_height - self.naviView.bottom)];
    [self.view addSubview:self.backScrollView];

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, 83)];
    [self.backScrollView addSubview:view];
    UIImageView *thumbImgV = [[UIImageView alloc] init];
    thumbImgV.contentMode = UIViewContentModeScaleAspectFill;
    [thumbImgV sd_setImageWithURL:[NSURL URLWithString:self.goodsModel.image]];
    thumbImgV.layer.cornerRadius = 5;
    thumbImgV.layer.masksToBounds = YES;
    [view addSubview:thumbImgV];
    [thumbImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.centerY.equalTo(view);
        make.width.height.mas_equalTo(60);
    }];

    UILabel *priceLabel = [[UILabel alloc] init];
    priceLabel.text = [NSString stringWithFormat:@"¥%@", self.goodsModel.price];
    priceLabel.font = SYS_Font(14);
    priceLabel.textColor = color96;
    [view addSubview:priceLabel];
    [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).offset(-15);
        make.top.equalTo(thumbImgV).offset(2);
    }];

    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.text = self.goodsModel.store_name;
    nameLabel.font = SYS_Font(14);
    nameLabel.textColor = color32;
    nameLabel.numberOfLines = 2;
    [view addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(thumbImgV.mas_right).offset(8);
        make.top.equalTo(thumbImgV).offset(2);
        make.right.lessThanOrEqualTo(priceLabel.mas_left).offset(-10);
    }];

    UILabel *numsLabel = [[UILabel alloc] init];
    numsLabel.text = [NSString stringWithFormat:@"x%@", self.goodsModel.cart_num];
    numsLabel.font = SYS_Font(14);
    numsLabel.textColor = color96;
    [view addSubview:numsLabel];
    [numsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(priceLabel);
        make.top.equalTo(priceLabel.mas_bottom).offset(8);
    }];
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, view.height - 1, _window_width, 1) andColor:colorf0 andView:view];

    NSArray *array = @[@"商品质量", @"服务态度", @"物流服务"];
    for (int i = 0; i < array.count; i++) {
        UIView *starView = [[UIView alloc] initWithFrame:CGRectMake(0, view.bottom + 15 + i * 40, _window_width, 40)];
        [self.backScrollView addSubview:starView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 65, 40)];
        label.text = array[i];
        label.font = SYS_Font(14);
        label.textColor = color32;
        [starView addSubview:label];
        SWStarView *scoreView = [[SWStarView alloc] initWithFrame:CGRectMake(label.right + 10, 10, 150, 20) starCount:5 starStyle:0 isAllowScroe:YES];
        scoreView.delegate = self;
        [starView addSubview:scoreView];
        UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(scoreView.right + 10, 0, 65, 40)];
        showLabel.font = SYS_Font(12);
        showLabel.textColor = RGB_COLOR(@"#C8C8C8", 1);
        [starView addSubview:showLabel];
        if (i == 0) {
            self.zhiliangStar = scoreView;
            self.zhiliangLabel = showLabel;
        } else if (i == 1) {
            self.fuwuStar = scoreView;
            self.fuwuLabel = showLabel;
        } else {
            self.wuliuStar = scoreView;
            self.wuliuLabel = showLabel;
        }
    }

    self.wordAndPicView = [[UIView alloc] initWithFrame:CGRectMake(15, view.bottom + 150, _window_width - 30, 180)];
    self.wordAndPicView.backgroundColor = RGB_COLOR(@"#FAFAFA", 1);
    self.wordAndPicView.layer.cornerRadius = 5;
    [self.backScrollView addSubview:self.wordAndPicView];

    self.textViewInput = [[SWMyTextView alloc] initWithFrame:CGRectMake(15, 15, self.wordAndPicView.width - 30, 45)];
    self.textViewInput.placeholder = @"商品满足你的期待么？说说你的想法，分享给想买的他们吧～";
    self.textViewInput.placeholderColor = RGB_COLOR(@"#C8C8C8", 1);
    self.textViewInput.font = SYS_Font(14);
    self.textViewInput.textColor = color32;
    self.textViewInput.backgroundColor = [UIColor clearColor];
    [self.wordAndPicView addSubview:self.textViewInput];

    CGFloat buttonWidth = (self.wordAndPicView.width - 20) / 4;
    self.picButton = [UIButton buttonWithType:0];
    self.picButton.frame = CGRectMake(10, 90, buttonWidth - 10, buttonWidth - 10);
    [self.picButton addTarget:self action:@selector(showImagePicker:) forControlEvents:UIControlEventTouchUpInside];
    [self.picButton setImage:[UIImage imageNamed:@"上传图片"] forState:0];
    [self.wordAndPicView addSubview:self.picButton];

    UIView *submitView = [[UIView alloc] init];
    submitView.backgroundColor = [UIColor whiteColor];
    [self.backScrollView addSubview:submitView];
    [submitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self.backScrollView);
        make.top.equalTo(self.wordAndPicView.mas_bottom);
        make.height.mas_equalTo(80);
    }];

    UIButton *createButton = [UIButton buttonWithType:0];
    [createButton setTitle:@"立即评价" forState:0];
    [createButton setBackgroundColor:normalColors];
    createButton.titleLabel.font = SYS_Font(15);
    createButton.layer.cornerRadius = 20;
    createButton.layer.masksToBounds = YES;
    [createButton addTarget:self action:@selector(doSubmitPingjia) forControlEvents:UIControlEventTouchUpInside];
    createButton.frame = CGRectMake(15, 20, _window_width - 30, 40);
    [submitView addSubview:createButton];
}

- (void)didClickStarView:(SWStarView *)starView andCurrentScore:(CGFloat)score {
    if (starView == self.zhiliangStar) {
        self.zhiliangLabel.text = [NSString stringWithFormat:@"%.0f分", score];
    } else if (starView == self.fuwuStar) {
        self.fuwuLabel.text = [NSString stringWithFormat:@"%.0f分", score];
    } else {
        self.wuliuLabel.text = [NSString stringWithFormat:@"%.0f分", score];
    }
}

- (void)showImagePicker:(UIButton *)sender {
    TZImagePickerController *imagePC = [[TZImagePickerController alloc] initWithMaxImagesCount:8 - self.picArray.count delegate:self];
    imagePC.allowCameraLocation = YES;
    imagePC.allowTakeVideo = NO;
    imagePC.allowPickingVideo = NO;
    imagePC.allowPickingOriginalPhoto = NO;
    [self presentViewController:imagePC animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    if (photos.count > 0) {
        [self.picArray addObjectsFromArray:photos];
        [self addNewPhotoView:photos];
        [self reloadPicView];
    }
}

- (void)addNewPhotoView:(NSArray<UIImage *> *)photos {
    CGFloat buttonWidth = (self.wordAndPicView.width - 20) / 4;
    for (UIImage *image in photos) {
        SWPhotoView *view = [[SWPhotoView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonWidth)];
        view.thumbImgView.image = image;
        [self.wordAndPicView addSubview:view];
        [self.picImageViewArray addObject:view];
    }
}

- (void)reloadPicView {
    self.picButton.hidden = self.picImageViewArray.count == 8;
    CGFloat buttonWidth = (self.wordAndPicView.width - 20) / 4;
    if (self.picImageViewArray.count > 0) {
        for (int i = 0; i < self.picImageViewArray.count; i++) {
            SWPhotoView *view = self.picImageViewArray[i];
            view.delateBtn.tag = 1000 + i;
            [view.delateBtn removeTarget:self action:@selector(doDelateImage:) forControlEvents:UIControlEventTouchUpInside];
            [view.delateBtn addTarget:self action:@selector(doDelateImage:) forControlEvents:UIControlEventTouchUpInside];
            view.frame = CGRectMake(10 + (i % 4) * buttonWidth, 85 + i / 4 * (buttonWidth + 5), buttonWidth, buttonWidth);
            if (i == self.picImageViewArray.count - 1) {
                self.picButton.frame = CGRectMake(10 + ((i + 1) % 4) * buttonWidth + 5, 85 + (i + 1) / 4 * (buttonWidth + 5) + 5, buttonWidth - 10, buttonWidth - 10);
                if (self.picButton.bottom > 180) {
                    if (i == 7) {
                        self.wordAndPicView.height = view.bottom + 20;
                    } else {
                        self.wordAndPicView.height = self.picButton.bottom + 20;
                    }
                } else {
                    self.wordAndPicView.height = 180;
                }
            }
        }
    } else {
        self.picButton.frame = CGRectMake(10, 90, buttonWidth - 10, buttonWidth - 10);
        self.wordAndPicView.height = 180;
    }
}

- (void)doDelateImage:(UIButton *)sender {
    SWPhotoView *view = self.picImageViewArray[sender.tag - 1000];
    [view removeFromSuperview];
    [self.picImageViewArray removeObjectAtIndex:sender.tag - 1000];
    [self.picArray removeObjectAtIndex:sender.tag - 1000];
    [self reloadPicView];
}

- (void)doSubmitPingjia {
    if (self.zhiliangStar.currentScore == 0) {
        [MBProgressHUD showError:@"请为商品评分"];
        return;
    }
    if (self.fuwuStar.currentScore == 0) {
        [MBProgressHUD showError:@"请为服务评分"];
        return;
    }
    if (self.wuliuStar.currentScore == 0) {
        [MBProgressHUD showError:@"请为物流评分"];
        return;
    }
    if (self.textViewInput.text.length == 0) {
        [MBProgressHUD showError:@"请输入评价内容"];
        return;
    }
    [MBProgressHUD showMessage:@""];
    if (self.picArray.count > 0) {
        [self doUploadImage];
    } else {
        [self doPingjia:@[]];
    }
}

- (void)doUploadImage {
    NSMutableArray *nameArray = [NSMutableArray array];
    for (UIImage *image in self.picArray) {
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        NSString *url = [NSString stringWithFormat:@"%@upload/image", purl];
        [session POST:url parameters:nil headers:@{@"Authori-zation": [NSString stringWithFormat:@"Bearer %@", [SWConfig getOwnToken]]} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 0.5) name:@"file" fileName:[SWToolClass getNameBaseCurrentTime:@"livethumb.png"] mimeType:@"image/jpeg"];
        } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [MBProgressHUD hideHUD];
            NSDictionary *data = [responseObject valueForKey:@"data"];
            NSString *code = [NSString stringWithFormat:@"%@", [responseObject valueForKey:@"status"]];
            if ([code isEqual:@"200"]) {
                [nameArray addObject:minstr([data valueForKey:@"url"])];
                if (nameArray.count == self.picArray.count) {
                    [self doPingjia:nameArray];
                }
            } else {
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[data valueForKey:@"msg"]];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"网络错误"];
        }];
    }
}

- (void)doPingjia:(NSArray *)array {
    NSString *pics = @"";
    for (NSString *str in array) {
        pics = pics.length == 0 ? str : [NSString stringWithFormat:@"%@,%@", pics, str];
    }
    NSDictionary *dic = @{
        @"unique": self.goodsModel.unique,
        @"comment": self.textViewInput.text,
        @"pics": pics,
        @"product_score": [NSString stringWithFormat:@"%.0f", self.zhiliangStar.currentScore],
        @"service_score": [NSString stringWithFormat:@"%.0f", self.fuwuStar.currentScore],
        @"express_score": [NSString stringWithFormat:@"%.0f", self.wuliuStar.currentScore],
    };
    [SWToolClass postNetworkWithUrl:@"order/comment" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            [MBProgressHUD showSuccess:@"感谢您的评价!"];
            if (self.block) {
                self.block();
            }
            [self doReturn];
        }
    } fail:^{
    }];
}

@end
