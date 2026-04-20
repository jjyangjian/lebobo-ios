//
//  SWApplyReturnMoneyVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/7.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWApplyReturnMoneyVC.h"
#import "SWMyTextView.h"
#import "SWCartModel.h"
#import "SWEvaluateWriteVC.h"

@interface SWApplyReturnMoneyVC ()<TZImagePickerControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) SWMyTextView *textViewInput;
@property (nonatomic, strong) NSMutableArray *picArray;
@property (nonatomic, strong) NSMutableArray *picImageViewArray;
@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) UIButton *picButton;
@property (nonatomic, strong) UILabel *reasonLabel;
@property (nonatomic, strong) UIView *pictureContainerView;
@property (nonatomic, strong) NSArray *reasonArray;
@property (nonatomic, strong) UIView *pickerBackgroundView;
@property (nonatomic, strong) UIView *pickerShowView;
@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation SWApplyReturnMoneyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"申请退款";
    self.picArray = [NSMutableArray array];
    self.picImageViewArray = [NSMutableArray array];
    [self creatUI];
    [self requestData];
}

- (void)creatUI {
    self.backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.naviView.bottom, _window_width, _window_height - self.naviView.bottom)];
    self.backScrollView.backgroundColor = RGB_COLOR(@"#fafafa", 1);
    [self.view addSubview:self.backScrollView];

    NSMutableArray *goodsArray = [NSMutableArray array];
    for (NSDictionary *dic in [self.orderMessage valueForKey:@"cartInfo"]) {
        SWCartModel *model = [[SWCartModel alloc] initWithDic:dic];
        [goodsArray addObject:model];
    }

    UIView *allGoodsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, goodsArray.count * 80)];
    allGoodsView.backgroundColor = [UIColor whiteColor];
    [self.backScrollView addSubview:allGoodsView];
    for (int i = 0; i < goodsArray.count; i++) {
        SWCartModel *model = goodsArray[i];
        UIView *goodsView = [[UIView alloc] initWithFrame:CGRectMake(0, i * 80, _window_width, 80)];
        [allGoodsView addSubview:goodsView];
        UIImageView *thumbImgV = [[UIImageView alloc] init];
        thumbImgV.contentMode = UIViewContentModeScaleAspectFill;
        [thumbImgV sd_setImageWithURL:[NSURL URLWithString:model.image]];
        thumbImgV.layer.cornerRadius = 5;
        thumbImgV.layer.masksToBounds = YES;
        [goodsView addSubview:thumbImgV];
        [thumbImgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(goodsView).offset(15);
            make.centerY.equalTo(goodsView);
            make.width.height.mas_equalTo(60);
        }];
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.text = [NSString stringWithFormat:@"¥%@", model.price];
        priceLabel.font = SYS_Font(14);
        priceLabel.textColor = color96;
        [goodsView addSubview:priceLabel];
        [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(goodsView).offset(-15);
            make.top.equalTo(thumbImgV).offset(2);
        }];
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = model.store_name;
        nameLabel.font = SYS_Font(14);
        nameLabel.textColor = color32;
        nameLabel.numberOfLines = 2;
        [goodsView addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(thumbImgV.mas_right).offset(8);
            make.top.equalTo(thumbImgV).offset(2);
            make.right.lessThanOrEqualTo(priceLabel.mas_left).offset(-10);
        }];
        UILabel *numsLabel = [[UILabel alloc] init];
        numsLabel.text = [NSString stringWithFormat:@"x%@", model.cart_num];
        numsLabel.font = SYS_Font(14);
        numsLabel.textColor = color96;
        [goodsView addSubview:numsLabel];
        [numsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(priceLabel);
            make.top.equalTo(priceLabel.mas_bottom).offset(8);
        }];
    }

    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, allGoodsView.bottom, _window_width, 10) andColor:colorf0 andView:self.backScrollView];
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, allGoodsView.bottom + 10, _window_width, 250)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.backScrollView addSubview:contentView];
    NSArray *array = @[@"退货件数", @"退款金额", @"退款原因", @"备注说明"];
    NSArray *array2 = @[minstr([self.orderMessage valueForKey:@"total_num"]), [NSString stringWithFormat:@"¥%@", minstr([self.orderMessage valueForKey:@"pay_price"])], @"退款原因"];

    for (int i = 0; i < array.count; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, i * 50, _window_width, i == 3 ? 100 : 50)];
        [contentView addSubview:view];
        [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(15, view.height - 1, _window_width - 30, 1) andColor:RGB_COLOR(@"#fafafa", 1) andView:view];
        UILabel *label = [[UILabel alloc] init];
        label.text = array[i];
        label.font = SYS_Font(15);
        label.textColor = color32;
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view).offset(15);
            make.centerY.equalTo(view.mas_top).offset(24.5);
        }];
        if (i < 3) {
            UILabel *rightLabel = [[UILabel alloc] init];
            rightLabel.text = array2[i];
            rightLabel.font = SYS_Font(15);
            rightLabel.textColor = color32;
            [view addSubview:rightLabel];
            [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(view.mas_right).offset(-15);
                make.centerY.equalTo(label);
            }];
            if (i == 2) {
                UIImageView *rightImgV = [[UIImageView alloc] init];
                rightImgV.image = [UIImage imageNamed:@"detalies右"];
                [view addSubview:rightImgV];
                [rightImgV mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(view).offset(-10);
                    make.centerY.equalTo(label);
                    make.width.height.mas_equalTo(15);
                }];
                [rightLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(rightImgV.mas_left).offset(-3);
                    make.centerY.equalTo(label);
                }];
                self.reasonLabel = rightLabel;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedReason)];
                [view addGestureRecognizer:tap];
            }
        } else {
            self.textViewInput = [[SWMyTextView alloc] initWithFrame:CGRectMake(10, 45, _window_width - 20, 50)];
            self.textViewInput.placeholder = @"请填写备注信息，100字以内";
            self.textViewInput.placeholderColor = RGB_COLOR(@"#C8C8C8", 1);
            self.textViewInput.font = SYS_Font(14);
            self.textViewInput.textColor = color32;
            self.textViewInput.backgroundColor = [UIColor clearColor];
            [view addSubview:self.textViewInput];
        }
    }

    self.pictureContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, contentView.bottom, _window_width, 156)];
    self.pictureContainerView.backgroundColor = [UIColor whiteColor];
    [self.backScrollView addSubview:self.pictureContainerView];
    UILabel *picLeftLabel = [[UILabel alloc] init];
    picLeftLabel.text = @"上传凭证";
    picLeftLabel.font = SYS_Font(15);
    picLeftLabel.textColor = color32;
    [self.pictureContainerView addSubview:picLeftLabel];
    [picLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pictureContainerView).offset(15);
        make.centerY.equalTo(self.pictureContainerView.mas_top).offset(24.5);
    }];
    UILabel *picRightLabel = [[UILabel alloc] init];
    picRightLabel.text = @"（ 最多可上传3张 ）";
    picRightLabel.font = SYS_Font(15);
    picRightLabel.textColor = color96;
    [self.pictureContainerView addSubview:picRightLabel];
    [picRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pictureContainerView.mas_right).offset(-15);
        make.centerY.equalTo(picLeftLabel);
    }];

    CGFloat buttonWidth = (self.pictureContainerView.width - 30) / 4;
    self.picButton = [UIButton buttonWithType:0];
    self.picButton.frame = CGRectMake(15, 73, buttonWidth - 10, buttonWidth - 10);
    [self.picButton addTarget:self action:@selector(showImagePicker:) forControlEvents:UIControlEventTouchUpInside];
    [self.picButton setImage:[UIImage imageNamed:@"上传图片"] forState:0];
    [self.pictureContainerView addSubview:self.picButton];

    UIButton *applyButton = [UIButton buttonWithType:0];
    [applyButton setTitle:@"申请退款" forState:0];
    [applyButton setBackgroundColor:normalColors];
    applyButton.titleLabel.font = SYS_Font(15);
    applyButton.layer.cornerRadius = 20;
    applyButton.layer.masksToBounds = YES;
    [applyButton addTarget:self action:@selector(doApply) forControlEvents:UIControlEventTouchUpInside];
    applyButton.frame = CGRectMake(15, self.pictureContainerView.bottom + 10, _window_width - 30, 40);
    [self.backScrollView addSubview:applyButton];
    self.backScrollView.contentSize = CGSizeMake(0, applyButton.bottom + ShowDiff + 20);
}

- (void)showImagePicker:(UIButton *)sender {
    TZImagePickerController *imagePC = [[TZImagePickerController alloc] initWithMaxImagesCount:3 - self.picArray.count delegate:self];
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
    CGFloat buttonWidth = (self.pictureContainerView.width - 30) / 4;
    for (UIImage *image in photos) {
        SWPhotoView *view = [[SWPhotoView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonWidth)];
        view.thumbImgView.image = image;
        [self.pictureContainerView addSubview:view];
        [self.picImageViewArray addObject:view];
    }
}

- (void)reloadPicView {
    self.picButton.hidden = self.picImageViewArray.count == 3;
    CGFloat buttonWidth = (self.pictureContainerView.width - 20) / 4;
    if (self.picImageViewArray.count > 0) {
        for (int i = 0; i < self.picImageViewArray.count; i++) {
            SWPhotoView *view = self.picImageViewArray[i];
            view.delateBtn.tag = 1000 + i;
            [view.delateBtn removeTarget:self action:@selector(doDelateImage:) forControlEvents:UIControlEventTouchUpInside];
            [view.delateBtn addTarget:self action:@selector(doDelateImage:) forControlEvents:UIControlEventTouchUpInside];
            view.frame = CGRectMake(15 + (i % 4) * buttonWidth, 68 + i / 4 * (buttonWidth + 5), buttonWidth, buttonWidth);
            self.picButton.frame = CGRectMake(view.right + 5, 73, buttonWidth - 10, buttonWidth - 10);
        }
    } else {
        self.picButton.frame = CGRectMake(15, 73, buttonWidth - 10, buttonWidth - 10);
    }
}

- (void)doDelateImage:(UIButton *)sender {
    SWPhotoView *view = self.picImageViewArray[sender.tag - 1000];
    [view removeFromSuperview];
    [self.picImageViewArray removeObjectAtIndex:sender.tag - 1000];
    [self.picArray removeObjectAtIndex:sender.tag - 1000];
    [self reloadPicView];
}

- (void)requestData {
    [SWToolClass getQCloudWithUrl:@"order/refund/reason" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            self.reasonArray = info;
            if (self.reasonArray.count > 0) {
                self.reasonLabel.text = minstr([self.reasonArray firstObject]);
            }
        }
    } Fail:^{
    }];
}

- (void)selectedReason {
    [self.view endEditing:YES];
    if (self.reasonArray.count == 0) {
        [self requestData];
    }
    if (!self.pickerBackgroundView) {
        self.pickerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, _window_height)];
        self.pickerBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self.view addSubview:self.pickerBackgroundView];
        UIButton *hideButton = [UIButton buttonWithType:0];
        hideButton.frame = CGRectMake(0, 0, _window_width, _window_height * 0.6);
        [hideButton addTarget:self action:@selector(hidePicker) forControlEvents:UIControlEventTouchUpInside];
        [self.pickerBackgroundView addSubview:hideButton];

        self.pickerShowView = [[UIView alloc] initWithFrame:CGRectMake(0, _window_height, _window_width, _window_height * 0.4)];
        self.pickerShowView.backgroundColor = [UIColor whiteColor];
        [self.pickerBackgroundView addSubview:self.pickerShowView];

        UIPickerView *pick = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, _window_width, self.pickerShowView.height - 40)];
        pick.backgroundColor = [UIColor whiteColor];
        pick.delegate = self;
        pick.dataSource = self;
        [self.pickerShowView addSubview:pick];

        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _window_width, 40)];
        titleView.backgroundColor = [UIColor clearColor];
        [self.pickerShowView addSubview:titleView];
        [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 39, _window_width, 1) andColor:colorf0 andView:titleView];
        UIButton *cancelButton = [UIButton buttonWithType:0];
        cancelButton.frame = CGRectMake(0, 0, 80, 40);
        cancelButton.tag = 100;
        cancelButton.titleLabel.font = SYS_Font(15);
        [cancelButton setTitle:@"取消" forState:0];
        [cancelButton setTitleColor:color64 forState:0];
        [cancelButton addTarget:self action:@selector(cancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:cancelButton];
        UIButton *sureButton = [UIButton buttonWithType:0];
        sureButton.frame = CGRectMake(titleView.width - 80, 0, 80, 40);
        sureButton.tag = 101;
        sureButton.titleLabel.font = SYS_Font(15);
        [sureButton setTitle:@"确定" forState:0];
        [sureButton setTitleColor:normalColors forState:0];
        [sureButton addTarget:self action:@selector(cancleOrSure:) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:sureButton];
    }
    [self showPicker];
}

- (void)showPicker {
    self.pickerBackgroundView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.pickerShowView.bottom = _window_height;
    }];
}

- (void)hidePicker {
    [UIView animateWithDuration:0.2 animations:^{
        self.pickerShowView.y = _window_height;
    } completion:^(BOOL finished) {
        self.pickerBackgroundView.hidden = YES;
    }];
}

- (void)cancleOrSure:(UIButton *)button {
    if (button.tag != 100) {
        self.reasonLabel.text = self.reasonArray[self.selectIndex];
    }
    [self hidePicker];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.reasonArray.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.reasonArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectIndex = row;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _window_width, 40)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = self.reasonArray[row];
    label.textColor = color32;
    label.font = [UIFont systemFontOfSize:15];
    label.backgroundColor = [UIColor clearColor];
    [[SWToolClass sharedInstance] lineViewWithFrame:CGRectMake(0, 39, _window_width, 1) andColor:colorf0 andView:label];
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40.0;
}

- (void)doApply {
    [MBProgressHUD showMessage:@""];
    if (self.picArray.count > 0) {
        [self doUploadImage];
    } else {
        [self doSubmitReturnMoney:@[]];
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
                [nameArray addObject:minstr([data valueForKey:@"url"] )];
                if (nameArray.count == self.picArray.count) {
                    [self doSubmitReturnMoney:nameArray];
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

- (void)doSubmitReturnMoney:(NSArray *)array {
    NSString *pics = @"";
    for (NSString *str in array) {
        pics = pics.length == 0 ? str : [NSString stringWithFormat:@"%@,%@", pics, str];
    }
    NSDictionary *dic = @{
        @"uni": minstr([self.orderMessage valueForKey:@"order_id"]),
        @"text": self.reasonLabel.text,
        @"refund_reason_wap_img": pics,
        @"refund_reason_wap_explain": minstr(self.textViewInput.text)
    };
    [SWToolClass postNetworkWithUrl:@"order/refund/verify" andParameter:dic success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            [MBProgressHUD showError:msg];
            if (self.block) {
                self.block();
            }
            [self doReturn];
        }
    } fail:^{
    }];
}

@end
