//
//  DistributionPosterViewController.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/7/3.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "DistributionPosterViewController.h"

@interface DistributionPosterViewController()<UIScrollViewDelegate>{
    CGFloat lastContenOffset;
}
@property (nonatomic,strong) UIScrollView *backScrollView;
@property (nonatomic,strong)  NSMutableArray *imgArray;
@property (nonatomic,strong) UIImageView *currentImgView;
@property (nonatomic,assign) int curIndex;
@property (nonatomic,strong) UIButton *saveBtn;

@end

@implementation DistributionPosterViewController
- (void)doSave{
    if (!_currentImgView.image) {
        [MBProgressHUD showError:@"图片读取失败"];
        return;
    }
    UIImageWriteToSavedPhotosAlbum(_currentImgView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);

}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo

{

    if (error == NULL) {
        [MBProgressHUD showError:@"保存成功！"];

    }else

    {
        [MBProgressHUD showError:@"保存失败"];

    }

    // NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);

}
- (UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:0];
        _saveBtn.frame = CGRectMake(_backScrollView.left, _backScrollView.bottom + 30, _backScrollView.width, 30);
        [_saveBtn setBackgroundColor:normalColors];
        [_saveBtn setTitle:@"保存海报" forState:0];
        _saveBtn.titleLabel.font = SYS_Font(15);
        _saveBtn.layer.cornerRadius = 15;
        _saveBtn.layer.masksToBounds = YES;
        [_saveBtn addTarget:self action:@selector(doSave) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
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
    [self.view addSubview:self.saveBtn];
    _imgArray = [NSMutableArray array];
    [self requestData];

}

- (void)creatUI:(NSArray *)array{
    for (int i = 0; i < array.count; i ++) {
        NSDictionary *dic = array[i];
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(i * _backScrollView.width, 0, _backScrollView.width, _backScrollView.height)];
        [imgView sd_setImageWithURL:[NSURL URLWithString:minstr([dic valueForKey:@"poster"])]];
        imgView.layer.cornerRadius = 10;
        imgView.layer.masksToBounds = YES;
        [_backScrollView addSubview:imgView];
        [_imgArray addObject:imgView];
    }
    _backScrollView.contentSize = CGSizeMake(_backScrollView.width * array.count, 0);
    [self showBigImgView:0];
}
- (void)requestData{
    [WYToolClass getQCloudWithUrl:@"spread/banner?type=1" Suc:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        if (code == 200) {
            [self creatUI:info];
        }
    } Fail:^{
        
    }];
}
- (void)showBigImgView:(int)index{
    for (int i = 0; i < _imgArray.count; i ++) {
        UIImageView *imgV = _imgArray[i];
        if (i == index) {
            imgV.transform = CGAffineTransformMakeScale(1, 1);
            _currentImgView = imgV;
            _curIndex = i;
        }else{
            imgV.transform = CGAffineTransformMakeScale(0.9 , 0.9);
        }
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self showBigImgView:(int)(scrollView.contentOffset.x/scrollView.width)];
    lastContenOffset = scrollView.contentOffset.x;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat proportion;
    int nextIndex;
    if (scrollView.contentOffset.x > lastContenOffset ) {
        //下一张
        proportion = (scrollView.contentOffset.x-lastContenOffset)/scrollView.width * 0.1;
        nextIndex = _curIndex + 1;
    }else{
        //上一张
        proportion = (lastContenOffset - scrollView.contentOffset.x)/scrollView.width * 0.1;
        nextIndex = _curIndex - 1;

    }
//    NSLog(@"%f",proportion);
    _currentImgView.transform = CGAffineTransformMakeScale(1 - proportion, 1 - proportion);
    if (nextIndex >=0 && nextIndex < _imgArray.count) {
        UIImageView *nextImgV = _imgArray[nextIndex];
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
