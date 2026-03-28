//
//  SWApplyShopVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/22.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWApplyShopVC.h"
#import "SWMineShopVC.h"

@interface SWApplyShopVC ()<TZImagePickerControllerDelegate>
@property (nonatomic, strong) UIView *applyView;
@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *cardTextField;
@property (nonatomic, assign) NSInteger selectedButtonTag;
@property (nonatomic, strong) UIImage *positiveImage;
@property (nonatomic, strong) UIImage *backImage;
@property (nonatomic, strong) UIImage *handImage;
@property (nonatomic, strong) UIImage *businessImage;
@property (nonatomic, strong) UIImage *licenceImage;
@property (nonatomic, strong) UIImage *otherImage;
@property (nonatomic, strong) NSMutableDictionary *parametersDictionary;
@property (nonatomic, strong) UIView *failView;

@end

@implementation SWApplyShopVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"开通店铺";
    [self requestData];
}

- (void)requestData{
    [SWToolClass getQCloudWithUrl:@"shopstatus" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            int status = [minstr([info valueForKey:@"status"]) intValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == -2) {
                    [self creatApplyUI];
                }else if (status == 0){
                    [self showSuccessView];
                }else if (status == -1){
                    [self showFailView:minstr([info valueForKey:@"reason"])];
                }else if (status == 1){
                    SWMineShopVC *vc = [[SWMineShopVC alloc]init];
                    [[SWMXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
                }
            });
        }else{
            [super doReturn];
        }
    } Fail:^{

    }];
}

- (void)creatApplyUI{
    self.applyView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-(64+statusbarHeight))];
    self.applyView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.applyView];

    self.backScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height-(64+statusbarHeight+75+ShowDiff))];
    self.backScrollView.backgroundColor = colorf0;
    [self.applyView addSubview:self.backScrollView];

    UIView *view1 = [[UIView alloc]init];
    view1.backgroundColor = [UIColor whiteColor];
    [self.backScrollView addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.equalTo(self.backScrollView);
    }];
    UILabel *label1 = [[UILabel alloc]init];
    label1.text = @"店主信息";
    label1.font = [UIFont boldSystemFontOfSize:15];
    label1.textColor = color32;
    [view1 addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1).offset(15);
        make.top.equalTo(view1);
        make.height.mas_equalTo(50);
    }];
    NSArray *array = @[@"姓名",@"手机号",@"身份证号"];
    for (int i = 0; i < array.count; i ++) {
        UITextField *textT = [[UITextField alloc]init];
        textT.font = SYS_Font(14);
        textT.placeholder = array[i];
        [view1 addSubview:textT];
        [textT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label1.mas_bottom).offset(i*51);
            make.left.equalTo(label1);
            make.right.equalTo(view1).offset(-15);
            make.height.mas_equalTo(50);
        }];
        UIView *lineV = [[UIView alloc]init];
        lineV.backgroundColor = RGB_COLOR(@"#E6E6E6", 1);
        [view1 addSubview:lineV];
        [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(textT);
            make.top.equalTo(textT.mas_bottom);
            make.height.mas_equalTo(1);
        }];
        if (i == 0) {
            self.nameTextField = textT;
        }else if (i == 1){
            self.phoneTextField = textT;
        }else {
            self.cardTextField = textT;
        }
    }

    NSArray *array2 = @[@"身份证正面照",@"身份证背面照",@"手持身份证照"];

    CGFloat www = (IS_IPHONE_5 ? 90 : 100);
    CGFloat speace = (_window_width -30 -3*www)/2;
    for (int i = 0; i < array2.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        [btn setImage:[UIImage imageNamed:@"photo"] forState:0];
        [btn addTarget:self action:@selector(showImagePicker:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1000 + i;
        [view1 addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label1.mas_bottom).offset(173);
            make.left.equalTo(view1).offset(15+i*(www + speace));
            make.width.mas_equalTo(www);
            make.height.equalTo(btn.mas_width).multipliedBy(0.75);
        }];
        UILabel *label = [[UILabel alloc]init];
        label.text = array2[i];
        label.textColor = color64;
        label.font = SYS_Font(12);
        [view1 addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btn.mas_bottom).offset(10);
            make.centerX.equalTo(btn);
        }];
        if (i == array2.count - 1) {
            [view1 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.top.width.equalTo(self.backScrollView);
                make.bottom.equalTo(label.mas_bottom).offset(20);
            }];
        }
    }

    UIView *view2 = [[UIView alloc]init];
    view2.backgroundColor = [UIColor whiteColor];
    [self.backScrollView addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(view1);
        make.top.equalTo(view1.mas_bottom).offset(5);
    }];
    UILabel *label2 = [[UILabel alloc]init];
    label2.text = @"资质证明";
    label2.font = [UIFont boldSystemFontOfSize:15];
    label2.textColor = color32;
    [view2 addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view2).offset(15);
        make.top.equalTo(view2);
        make.height.mas_equalTo(50);
    }];
    NSArray *array3 = @[@"营业执照",@"许可证",@"其他证件"];

    for (int i = 0; i < array3.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:0];
        [btn setImage:[UIImage imageNamed:@"photo"] forState:0];
        [btn addTarget:self action:@selector(showImagePicker:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = 1003 + i;
        [view2 addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label2.mas_bottom).offset(5);
            make.left.equalTo(view2).offset(15+i*(www + speace));
            make.width.mas_equalTo(www);
            make.height.equalTo(btn.mas_width).multipliedBy(0.75);
        }];
        UILabel *label = [[UILabel alloc]init];
        label.text = array3[i];
        label.textColor = color64;
        label.font = SYS_Font(12);
        [view2 addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btn.mas_bottom).offset(10);
            make.centerX.equalTo(btn);
        }];
        if (i == array3.count - 1) {
            [view2 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.width.equalTo(view1);
                make.top.equalTo(view1.mas_bottom).offset(5);
                make.bottom.equalTo(label.mas_bottom).offset(20);
            }];
        }
    }
    [self.backScrollView layoutIfNeeded];
    self.backScrollView.contentSize = CGSizeMake(0, view2.bottom + 20);
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.applyView.height-75-ShowDiff, _window_width, 75 + ShowDiff)];
    bottomView.backgroundColor =[UIColor whiteColor];
    [self.applyView addSubview:bottomView];
    UIButton *addBtn = [UIButton buttonWithType:0];
    addBtn.frame = CGRectMake(15, 17.5, _window_width - 30, 40);
    [addBtn setTitle:@"提交" forState:0];
    [addBtn setBackgroundColor:normalColors];
    addBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    addBtn.layer.cornerRadius = 20;
    addBtn.layer.masksToBounds = YES;
    [addBtn addTarget:self action:@selector(addBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:addBtn];
}

- (void)showImagePicker:(UIButton *)sender{
    [self.view endEditing:YES];
    self.selectedButtonTag = sender.tag;
    TZImagePickerController *imagePC = [[TZImagePickerController alloc]initWithMaxImagesCount:1 delegate:self];
    imagePC.allowCameraLocation = YES;
    imagePC.allowTakeVideo = NO;
    imagePC.allowPickingVideo = NO;
    imagePC.showSelectBtn = NO;
    imagePC.allowCrop = YES;
    imagePC.allowPickingOriginalPhoto = NO;
    imagePC.scaleAspectFillCrop = YES;
    imagePC.photoWidth = 350;
    imagePC.photoPreviewMaxWidth = 300;
    imagePC.cropRect = CGRectMake(0, (_window_height-_window_width*0.75)/2, _window_width, _window_width*0.75);
    [self presentViewController:imagePC animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    if (photos.count > 0) {
        UIImage *image = [photos firstObject];
        UIButton *btn = (UIButton *)[self.backScrollView viewWithTag:self.selectedButtonTag];
        [btn setImage:image forState:UIControlStateNormal];

        switch (self.selectedButtonTag) {
            case 1000:
                self.positiveImage = image;
                break;
            case 1001:
                self.backImage = image;
                break;
            case 1002:
                self.handImage = image;
                break;
            case 1003:
                self.businessImage = image;
                break;
            case 1004:
                self.licenceImage = image;
                break;
            case 1005:
                self.otherImage = image;
                break;
            default:
                break;
        }
    }
}

- (void)addBtnClick:(UIButton *)sender{
    if (self.nameTextField.text.length == 0 || self.phoneTextField.text.length == 0 || self.cardTextField.text.length == 0 || !self.positiveImage || !self.backImage || !self.handImage) {
        [MBProgressHUD showError:@"请填写店主信息"];
        return;
    }
    if (!self.businessImage) {
        [MBProgressHUD showError:@"请上传营业执照"];
        return;
    }

    [MBProgressHUD showMessage:@""];
    [self uploadImage];
}

- (void)uploadImage{
    NSMutableArray *imageArray = @[
        @{@"key":@"cer_f",@"image":self.positiveImage},
        @{@"key":@"cer_b",@"image":self.backImage},
        @{@"key":@"cer_h",@"image":self.handImage},
        @{@"key":@"business",@"image":self.businessImage}
    ].mutableCopy;
    if (self.licenceImage) [imageArray addObject:@{@"key":@"license",@"image":self.licenceImage}];
    if (self.otherImage) [imageArray addObject:@{@"key":@"other",@"image":self.otherImage}];
    self.parametersDictionary = [NSMutableDictionary dictionary];
    for (NSDictionary *dic in imageArray) {
        NSString *keyStr = minstr([dic valueForKey:@"key"]);
        UIImage *image = [dic valueForKey:@"image"];
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        NSString *url = [NSString stringWithFormat:@"%@upload/image",purl];
        [session POST:url parameters:nil headers:@{@"Authori-zation":[NSString stringWithFormat:@"Bearer %@",[SWConfig getOwnToken]]} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                [formData appendPartWithFileData:UIImageJPEGRepresentation(image,0.5) name:@"file" fileName:[SWToolClass getNameBaseCurrentTime:@"livethumb.png"] mimeType:@"image/jpeg"];
        } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [MBProgressHUD hideHUD];

            NSDictionary *data = [responseObject valueForKey:@"data"];
            NSString *code = [NSString stringWithFormat:@"%@",[responseObject valueForKey:@"status"]];
            if ([code isEqual:@"200"]) {
                [self.parametersDictionary setObject:minstr([data valueForKey:@"url"]) forKey:keyStr];
                if (self.parametersDictionary.count == imageArray.count) {
                    NSLog(@"%@",self.parametersDictionary);
                    [self doApply];
                }
            }else{
                [MBProgressHUD hideHUD];
                [MBProgressHUD showError:[data valueForKey:@"msg"]];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:@"网络错误"];
        }];
    }
}

- (void)doApply{
    [self.parametersDictionary setObject:minstr(self.nameTextField.text) forKey:@"realname"];
    [self.parametersDictionary setObject:minstr(self.phoneTextField.text) forKey:@"tel"];
    [self.parametersDictionary setObject:minstr(self.cardTextField.text) forKey:@"cer_no"];
    [SWToolClass postNetworkWithUrl:@"shopapply" andParameter:self.parametersDictionary success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUD];
        if (code == 200) {
            [self showSuccessView];
        }
    } fail:^{
        [MBProgressHUD hideHUD];
    }];
}

- (void)showSuccessView{
    if (self.applyView) {
        self.applyView.hidden = YES;
    }
    UIView *examineView = [[UIView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-(64+statusbarHeight))];
    examineView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:examineView];
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width * 0.32, 35, _window_width*0.36, _window_width * 0.306)];
    imgV.image = [UIImage imageNamed:@"shop-tips"];
    [examineView addSubview:imgV];
    UILabel *label1 = [[UILabel alloc]init];
    label1.font = SYS_Font(16);
    label1.textColor = color32;
    label1.text = @"信息审核中...";
    [examineView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(examineView);
        make.top.equalTo(imgV.mas_bottom).offset(38);
    }];

    UILabel *label2 = [[UILabel alloc]init];
    label2.font = SYS_Font(13);
    label2.textColor = color64;
    label2.text = @"3个工作日内会有审核结果，请耐心等待";
    [examineView addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(examineView);
        make.top.equalTo(label1.mas_bottom).offset(13);
    }];
}

- (void)showFailView:(NSString *)reason{
    self.failView = [[UIView alloc]initWithFrame:CGRectMake(0, 64+statusbarHeight, _window_width, _window_height-(64+statusbarHeight))];
    self.failView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.failView];
    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width * 0.32, 35, _window_width*0.36, _window_width * 0.306)];
    imgV.image = [UIImage imageNamed:@"shop-tips"];
    [self.failView addSubview:imgV];
    UILabel *label1 = [[UILabel alloc]init];
    label1.font = SYS_Font(16);
    label1.textColor = normalColors;
    label1.text = @"身份信息审核未通过";
    [self.failView addSubview:label1];
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.failView);
        make.top.equalTo(imgV.mas_bottom).offset(38);
    }];

    UILabel *label2 = [[UILabel alloc]init];
    label2.font = SYS_Font(13);
    label2.textColor = color64;
    label2.text = reason;
    [self.failView addSubview:label2];
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.failView);
        make.top.equalTo(label1.mas_bottom).offset(13);
    }];
    UIButton *againBtn = [UIButton buttonWithType:0];
    [againBtn setTitle:@"重新申请" forState:0];
    [againBtn setBackgroundColor:normalColors];
    againBtn.titleLabel.font = SYS_Font(16);
    againBtn.layer.cornerRadius = 20;
    againBtn.layer.masksToBounds = YES;
    [againBtn addTarget:self action:@selector(aginBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.failView addSubview:againBtn];
    [againBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.failView);
        make.top.equalTo(label2.mas_bottom).offset(20);
        make.width.equalTo(self.failView).multipliedBy(0.55);
        make.height.mas_equalTo(40);
    }];
}

- (void)aginBtnClick{
    [self.failView removeFromSuperview];
    self.failView = nil;
    [self creatApplyUI];
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
