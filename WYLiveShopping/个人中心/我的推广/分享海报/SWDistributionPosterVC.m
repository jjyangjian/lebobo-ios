//
//  SWDistributionPosterVC.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/3.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWDistributionPosterVC.h"

@interface SWDistributionPosterVC()<UIScrollViewDelegate>
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) UIImageView *currentImageView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIButton *saveButton;

@end

@implementation SWDistributionPosterVC
- (void)doSave{
    if (!self.currentImageView.image) {
        [MBProgressHUD showError:@"图片读取失败"];
        return;
    }
    UIImageWriteToSavedPhotosAlbum(self.currentImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error == NULL) {
        [MBProgressHUD showError:@"保存成功！"];
    }else{
        [MBProgressHUD showError:@"保存失败"];
    }
}

- (UIButton *)saveButton{
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:0];
        _saveButton.frame = CGRectMake(self.backScrollView.left, self.backScrollView.bottom + 30, self.backScrollView.width, 30);
        [_saveButton setBackgroundColor:normalColors];
        [_saveButton setTitle:@"保存海报" forState:0];
        _saveButton.titleLabel.font = SYS_Font(15);
        _saveButton.layer.cornerRadius = 15;
        _saveButton.layer.masksToBounds = YES;
        [_saveButton addTarget:self action:@selector(doSave) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (UIScrollView *)backScrollView{
    if (!_backScrollView) {
        _backScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(_window_width*0.1, self.naviView.bottom+20, _window_width*0.8, _window_width*1.33)];
        _backScrollView.delegate = self;
        _backScrollView.clipsToBounds = NO;
        _backScrollView.pagingEnabled = YES;
        _backScrollView.bounces = NO;
        _backScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _backScrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleL.text = @"分销海报";
    self.view.backgroundColor = RGB_COLOR(@"#C8C8C8", 1);
    self.view.clipsToBounds = YES;
    [self.view addSubview:self.backScrollView];
    [self.view addSubview:self.saveButton];
    self.imageViewArray = [NSMutableArray array];
    [self requestData];
}

- (void)creatUI:(NSArray *)array{
    for (int i = 0; i < array.count; i ++) {
        NSDictionary *dic = array[i];
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(i * self.backScrollView.width, 0, self.backScrollView.width, self.backScrollView.height)];
        [imgView sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"poster"])]];
        imgView.layer.cornerRadius = 10;
        imgView.layer.masksToBounds = YES;
        [self.backScrollView addSubview:imgView];
        [self.imageViewArray addObject:imgView];
    }
    self.backScrollView.contentSize = CGSizeMake(self.backScrollView.width * array.count, 0);
    [self showBigImgView:0];
}

- (void)requestData{
    [SWToolClass getQCloudWithUrl:@"spread/banner?type=1" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [self creatUI:info];
        }
    } Fail:^{

    }];
}

- (void)showBigImgView:(int)index{
    for (int i = 0; i < self.imageViewArray.count; i ++) {
        UIImageView *imgV = self.imageViewArray[i];
        if (i == index) {
            imgV.transform = CGAffineTransformMakeScale(1, 1);
            self.currentImageView = imgV;
            self.currentIndex = i;
        }else{
            imgV.transform = CGAffineTransformMakeScale(0.9 , 0.9);
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self showBigImgView:(int)(scrollView.contentOffset.x/scrollView.width)];
    self.lastContentOffset = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat proportion;
    NSInteger nextIndex;
    if (scrollView.contentOffset.x > self.lastContentOffset ) {
        proportion = (scrollView.contentOffset.x-self.lastContentOffset)/scrollView.width * 0.1;
        nextIndex = self.currentIndex + 1;
    }else{
        proportion = (self.lastContentOffset - scrollView.contentOffset.x)/scrollView.width * 0.1;
        nextIndex = self.currentIndex - 1;
    }
    self.currentImageView.transform = CGAffineTransformMakeScale(1 - proportion, 1 - proportion);
    if (nextIndex >=0 && nextIndex < self.imageViewArray.count) {
        UIImageView *nextImgV = self.imageViewArray[nextIndex];
        nextImgV.transform = CGAffineTransformMakeScale(0.9 + proportion, 0.9 + proportion);
    }
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
