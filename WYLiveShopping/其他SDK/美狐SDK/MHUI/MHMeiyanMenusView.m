//
//  MHMeiyanMenusView.m

#import "MHMeiyanMenusView.h"
#import "MHBeautyMenuCell.h"
#import "MHStickersView.h"
#import "MHBeautyParams.h"
#import "StickerDataListModel.h"
#import "StickerManager.h"
#import "MHMagnifiedView.h"
#import "MHBeautyAssembleView.h"
#import "MHSpecificAssembleView.h"
#import "MHBeautiesModel.h"
#import "MHFilterModel.h"
#import <MHBeautySDK/MHBeautySDK.h>
#import "MHMakeUpView.h"
#define kBasicStickerURL @"aHR0cHM6Ly9kYXRhLmZhY2VnbC5jb20vYXBpL3Nkay92MS9zdGlja2VyL2luZGV4"
static NSString *StickerImg = @"stickerFace";
static NSString *BeautyImg = @"beauty1";
static NSString *FaceImg = @"face";
static NSString *CameraImg = @"beautyCamera";
static NSString *FilterImg = @"filter";
static NSString *SpecificImg = @"specific";
static NSString *HahaImg = @"haha";
static NSString *MakeUpImg =@"beautyMakeup";


@interface MHMeiyanMenusView()<UICollectionViewDelegate,UICollectionViewDataSource,MHBeautyAssembleViewDelegate,MHStickersViewDelegate,MHMagnifiedViewDelegate,MHSpecificAssembleViewDelegate,MHBeautyManagerDelegate,MHMakeUpViewDelegate>
@property (nonatomic, strong) MHBeautyManager *beautyManager;//美型特性管理器，必须传入
@property (nonatomic, strong) UICollectionView *collectionView;
//@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) UIView *currentView;
@property (nonatomic, assign) NSInteger lastIndex;//上一个index
@property (nonatomic, strong) UIView *superView;
@property (nonatomic, strong) MHMagnifiedView *magnifiedView;//哈哈镜
@property (nonatomic, strong) MHBeautyAssembleView *beautyAssembleView;//美颜集合
@property (nonatomic, strong) MHSpecificAssembleView *specificAssembleView;//特效集合
@property (nonatomic, strong) MHStickersView *stickersView;//贴纸
@property (nonatomic, strong) MHMakeUpView *makeUpView;//美妆
@property (nonatomic, assign) BOOL menuHidden;
@property (nonatomic, assign) int sdkLevelTYpe;///<sdk类型

@property (nonatomic, assign) BOOL isShowStatusLabel;///<是否显示提示状态label
@property (nonatomic, strong) UILabel * statusLabel;

@end
@implementation MHMeiyanMenusView

- (void)setupDefaultBeautyAndFaceValueWithIsTX:(BOOL)isTX{
//    设置美型默认数据，按照数组的名称设置初始值，不要换顺序
//    此处只是说明该位置对应的类型，如果打开注释，请填写具体数值
    
//    NSArray *originalValuesArr = @[@"0",@"大眼",@"瘦脸",
//    @"嘴型",
//    @"瘦鼻",
//    @"下巴",
//    @"额头",
//    @"眉毛",
//    @"眼角",
//    @"眼距",
//    @"开眼角",
//    @"削脸",
//    @"长鼻"];
    //美型
//    NSArray *originalValuesArr = @[@"0",@"30",@"30",
//    @"30",
//    @"30",
//    @"50",
//    @"0",
//    @"0",
//    @"0",
//    @"0",
//    @"0",
//    @"0",
//    @"50"];
//    for (int i = 0; i<originalValuesArr.count; i++) {
//        NSString *faceKey = [NSString stringWithFormat:@"face_%ld",(long)i];
//        NSString * value = [[NSUserDefaults standardUserDefaults] objectForKey:faceKey];
//        if (i != 0) {
//            [self handleFaceBeautyWithType:i sliderValue:value.integerValue];
//        }
//        [[NSUserDefaults standardUserDefaults] setInteger:value.integerValue forKey:faceKey];
//    }
//
//    originalValuesArr = @[@"0",@"5",@"5",@"7",@"5"];
//    //美颜
//    for (int i = 0; i<originalValuesArr.count; i++) {
//        NSString *faceKey = [NSString stringWithFormat:@"beauty_%ld",(long)i];
//        NSString * value = [[NSUserDefaults standardUserDefaults] objectForKey:faceKey];
//        if (i != 0) {
//            [self handleBeautyWithType:i level:(value.integerValue/10.0)];
//        }
//        [[NSUserDefaults standardUserDefaults] setInteger:value.integerValue forKey:faceKey];
//    }
    
    //设置美颜参数,范围是0-9
//    NSArray *beautyArr =
//     @[@"磨皮数值",@"美白数值",@"红润数值"];
     NSString *mopi =  @"7";//磨皮数值
     NSString *white = @"7";//美白数值
     NSString *hongrun = @"5";//红润数值
    if (isTX) {
        [self beautyLevel:mopi.intValue whitenessLevel:white.intValue ruddinessLevel:hongrun.intValue brightnessLevel:57];
    } else {
        [_beautyManager setBuffing:(mopi.integerValue/10.0)];
        [_beautyManager setSkinWhiting:(white.integerValue/10.0)];
        [_beautyManager setRuddiness:(hongrun.integerValue/10.0)];
        [_beautyManager setBrightnessLift:5/10.0];
    }
  
    ///美妆 设置需要先设置人脸识别打开
//    self.beautyManager.isUseMakeUp = YES;
//    ///睫毛
//    NSString * eyelashKey = [NSString stringWithFormat:@"makeUp_%ld",(long)1];
//    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:eyelashKey];
//    [self.beautyManager setBeautyManagerMakeUpType:1 withOn:YES];
//    NSString * lipstickKey = [NSString stringWithFormat:@"makeUp_%ld",(long)2];
//    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:lipstickKey];
//    [self.beautyManager setBeautyManagerMakeUpType:2 withOn:YES];
//    NSString * blushKey = [NSString stringWithFormat:@"makeUp_%ld",(long)3];
//    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:blushKey];
//    [self.beautyManager setBeautyManagerMakeUpType:3 withOn:YES];
//    NSString * eyelinerKey = [NSString stringWithFormat:@"makeUp_%ld",(long)4];
//    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:eyelinerKey];
//    [self.beautyManager setBeautyManagerMakeUpType:4 withOn:YES];
    
}
- (instancetype)initWithFrame:(CGRect)frame superView:(UIView *)superView delegate:(id<MHMeiyanMenusViewDelegate>)delegate beautyManager:(MHBeautyManager *)manager isTXSDK:(BOOL)isTx {
    if (self = [super initWithFrame:frame]) {
        self.superView = superView;
        self.delegate = delegate;
        self.menuHidden = NO;
        self.isTX = isTx;
        self.beautyManager = manager;
        self.beautyManager.delegate = self;
        [self addSubview:self.collectionView];
        self.lastIndex = -1;
        if ([MHSDK shareInstance].menuArray.count > 0) {
            for (MHBeautiesModel * model in self.array) {
                NSString * itemName = model.beautyTitle;
                if ([itemName isEqualToString:@"贴纸"]) {
                    [self getSticks];
                }else if ([itemName isEqualToString:@"特效"]){
                    [self.specificAssembleView getActionSource];
                }
            }
        }
        

//        if (self.sdkLevelTYpe == 1) {
            [superView addSubview:self.statusLabel];
//        }
        
    }
    return self;
}

- (void)showMenuView:(BOOL)show {
    if (self.currentView) {
        ///<修改MHUI
        [UIView animateWithDuration:0.3 animations:^{
                
            self.currentView.frame = CGRectMake(0, window_height, window_width, self.currentView.frame.size.height);
            } completion:^(BOOL finished) {
                [self.currentView removeFromSuperview];
                self.show = YES;
                self.currentView = nil;
                self.hidden = NO;
                return;
            }];
        
        
    }
    if (show) {
        if (![self isDescendantOfView:self.superView]) {
               [self.superView addSubview:self];
            
        }
    } else {
        [self removeFromSuperview];
    }
    self.show = show;
    
    self.hidden = !show;
    
    
}
- (void)showMenusWithoutRecord:(BOOL)show
{
    self.menuHidden = !show;
    [self.collectionView reloadData];
}


- (void)setIsTX:(BOOL)isTX {
    _isTX = isTX;
    self.beautyAssembleView.isTXSDK = isTX;
}

#pragma mark - delegate
//美颜-腾讯直播SDK使用
- (void)beautyLevel:(NSInteger)beauty whitenessLevel:(NSInteger)white ruddinessLevel:(NSInteger)ruddiness brightnessLevel:(NSInteger)brightness{
    if ([self.delegate respondsToSelector:@selector(beautyEffectWithLevel:whitenessLevel:ruddinessLevel:)]) {
        [self.delegate beautyEffectWithLevel:beauty whitenessLevel:white ruddinessLevel:ruddiness];
    }
    [_beautyManager setBrightnessLift:(int)brightness];
}

//美颜-非腾讯直播SDK使用
- (void)handleBeautyWithType:(NSInteger)type level:(CGFloat)beautyLevel {
    switch (type) {
            case MHBeautyType_Original:{
                [_beautyManager setRuddiness:0];
                [_beautyManager setSkinWhiting:0];
                [_beautyManager setBuffing:0.0];
            }
                break;
            
            case MHBeautyType_Mopi:
            [_beautyManager setBuffing:beautyLevel];
           
            break;
            case MHBeautyType_White:
            [_beautyManager setSkinWhiting:beautyLevel];
            break;
            case MHBeautyType_Ruddiess:
            [_beautyManager setRuddiness:beautyLevel];
            break;
            case MHBeautyType_Brightness:
            [_beautyManager setBrightnessLift:beautyLevel];
            break;
            
        default:
            break;
    }
}

//美型
-(void)handleFaceBeautyWithType:(NSInteger)type sliderValue:(NSInteger)value {
    self.beautyManager.isUseFaceBeauty = YES;
    switch (type) {
        case MHBeautyFaceType_Original:{
            //原图-->人脸识别设置
            self.beautyManager.isUseFaceBeauty = NO;
            [self.beautyManager setFaceLift:0];
            [self.beautyManager setBigEye:0];
            [self.beautyManager setMouthLift:0];
            [self.beautyManager setNoseLift:0];
            [self.beautyManager setChinLift:0];
            [self.beautyManager setForeheadLift:0];
            [self.beautyManager setEyeBrownLift:0];
            [self.beautyManager setEyeAngleLift:0];
            [self.beautyManager setEyeAlaeLift:0];
            [self.beautyManager setShaveFaceLift:0];
            [self.beautyManager setEyeDistanceLift:0];
        }
            break;
        case MHBeautyFaceType_ThinFace:
            [self.beautyManager setFaceLift:(int)value];
            break;
        case MHBeautyFaceType_BigEyes:
            [self.beautyManager setBigEye:(int)value];
            break;
        case MHBeautyFaceType_Mouth:
            [self.beautyManager setMouthLift:(int)value];
            break;
        case MHBeautyFaceType_Nose:
            [self.beautyManager setNoseLift:(int)value];
            break;
        case MHBeautyFaceType_Chin:
            [self.beautyManager setChinLift:(int)value];
            break;
        case MHBeautyFaceType_Forehead:
            [self.beautyManager setForeheadLift:(int)value];
            break;
        case MHBeautyFaceType_Eyebrow:
            [self.beautyManager setEyeBrownLift:(int)value];
            break;
        case MHBeautyFaceType_Canthus:
            [self.beautyManager setEyeAngleLift:(int)value];
            break;
        case MHBeautyFaceType_EyeAlae:
            [self.beautyManager setEyeAlaeLift:(int)value];
            break;
        case MHBeautyFaceType_EyeDistance:
            [self.beautyManager setEyeDistanceLift:(int)value];
            break;
        case MHBeautyFaceType_ShaveFace:
            [self.beautyManager setShaveFaceLift:(int)value];
            break;
        case MHBeautyFaceType_LongNose:
            [self.beautyManager setLengthenNoseLift:(int)value];
            break;
        default:
            break;
    }
   
}

//一键美颜
- (void)handleQuickBeautyValue:(MHBeautiesModel *)model {
    if (model.type == 0){
        self.beautyManager.isUseOneKey = NO;
    }else{
        self.beautyManager.isUseOneKey = YES;
    }
    [self.beautyManager setFaceLift:model.face_defaultValue.intValue];
    [self.beautyManager setBigEye:model.bigEye_defaultValue.intValue];
    [self.beautyManager setMouthLift:model.mouth_defaultValue.intValue];
    [self.beautyManager setNoseLift:model.nose_defaultValue.intValue];
    [self.beautyManager setChinLift:model.chin_defaultValue.intValue];
    [self.beautyManager setForeheadLift:model.forehead_defaultValue.intValue];
    [self.beautyManager setEyeBrownLift:model.eyeBrown_defaultValue.intValue];
    [self.beautyManager setEyeAngleLift:model.eyeAngle_defaultValue.intValue];
    [self.beautyManager setEyeAlaeLift:model.eyeAlae_defaultValue.intValue];
    [self.beautyManager setShaveFaceLift:model.shaveFace_defaultValue.intValue];
    [self.beautyManager setEyeDistanceLift:model.eyeDistance_defaultValue.intValue];
    if (self.isTX) {
        if ([self.delegate respondsToSelector:@selector(beautyEffectWithLevel:whitenessLevel:ruddinessLevel:)]) {
            
            [self.delegate beautyEffectWithLevel:model.buffingValue.integerValue whitenessLevel:model.whiteValue.integerValue ruddinessLevel:model.ruddinessValue.integerValue];
        }
    } else {
            [_beautyManager setRuddiness:(model.ruddinessValue.floatValue)/9.0];
            [_beautyManager setSkinWhiting:(model.whiteValue.floatValue)/9.0];
            [_beautyManager setBuffing:(model.buffingValue.floatValue)/9.0];

    }
}


- (void)handleQuickBeautyWithSliderValue:(NSInteger)value quickBeautyModel:(nonnull MHBeautiesModel *)model{
    if (!model) {
        return;
    }
    if (value >= model.bigEye_minValue.integerValue && value <= model.bigEye_maxValue.integerValue) {
        [self.beautyManager setBigEye:(int)value];
        
    }
    if (value >= model.face_minValue.integerValue && value <= model.face_minValue.integerValue) {
        [self.beautyManager setFaceLift:(int)value];
        
    }
    if (value >= model.mouth_minValue.integerValue && value <= model.mouth_maxValue.integerValue) {
        [self.beautyManager setMouthLift:(int)value];
        
    }
    if (value >= model.shaveFace_minValue.integerValue && value <= model.shaveFace_maxValue.integerValue) {
        [self.beautyManager setShaveFaceLift:(int)value];
        
    }
    if (value >= model.eyeAlae_minValue.integerValue && value <= model.eyeAlae_maxValue.integerValue) {
        [self.beautyManager setEyeAlaeLift:(int)value];
        
    }
    if (value >= model.eyeAngle_minValue.integerValue && value <= model.eyeAngle_maxValue.integerValue) {
        [self.beautyManager setEyeAngleLift:(int)value];
        
    }
    if (value >= model.eyeBrown_minValue.integerValue && value <= model.eyeBrown_maxValue.integerValue) {
        [self.beautyManager setEyeBrownLift:(int)value];
        
    }
    if (value >= model.forehead_minValue.integerValue && value <= model.forehead_maxValue.integerValue) {
        [self.beautyManager setForeheadLift:(int)value];
        
    }
    if (value >= model.chin_minValue.integerValue && value <= model.chin_maxValue.integerValue) {
        [self.beautyManager setChinLift:(int)value];
        
    }
    if (value >= model.nose_minValue.integerValue && value <= model.nose_maxValue.integerValue) {
        [self.beautyManager setNoseLift:(int)value];
        
    }
    if (value >= model.eyeDistance_minValue.integerValue && value <= model.eyeDistance_maxValue.integerValue) {
        [self.beautyManager setEyeDistanceLift:(int)value];
        
    }
}
//滤镜
- (void)handleFiltersEffectWithType:(NSInteger)filter  withFilterName:(nonnull NSString *)filterName{
    MHFilterModel *model = [MHFilterModel unzipFiltersFile:filterName];
    if (model) {
        NSDictionary *dic = @{@"kUniformList":model.uniformList,
              @"kUniformData":model.uniformData,
              @"kUnzipDesPath":model.unzipDesPath,
              @"kName":model.name,
              @"kFragmentShader":model.fragmentShader
        };
        [_beautyManager setFilterType:filter newFilterInfo:dic];
    } else {
        [_beautyManager setFilterType:filter newFilterInfo:[NSDictionary dictionary]];
    }
}
///修改MHUI
///<照相
- (void)takePhoto{
    if ([self.delegate respondsToSelector:@selector(cameraAction)]) {
        [self.delegate cameraAction];
    }
}
///<隐藏
- (void)clickPackUp{
    [self showMenuView:YES];
}

//水印
- (void)handleWatermarkWithModel:(MHBeautiesModel *)model {
    [self.beautyManager setWatermarkRect:CGRectMake(0.08, 0.08, 0.1, 0.1)];
    [self.beautyManager setWatermark:model.imgName alignment:model.aliment];
}
//特效
- (void)handleSpecificWithType:(NSInteger)type {
    [self.beautyManager setJitterType:type];
}
//动作识别
- (void)handleSpecificStickerActionEffect:(NSString *)stickerContent sticker:(StickerDataListModel *)model action:(int)action{
    if (model == nil || action == 0){
        _beautyManager.isUseSticker = NO;
    }else{
        _beautyManager.isUseSticker = YES;
    }
    [self.beautyManager setSticker:stickerContent action:action];
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (action) {
            case 0:
            {
                self.statusLabel.hidden = YES;
                self.statusLabel.text = @"";
            }
                break;
            case 1:
            {
                self.statusLabel.hidden = NO;
                self.statusLabel.text = YZMsg(@"请抬头");
            }
                break;
            case 2:
            {
                self.statusLabel.hidden = NO;
                self.statusLabel.text = YZMsg(@"请张嘴");
            }
                break;
            case 3:
            {
                self.statusLabel.hidden = NO;
                self.statusLabel.text = YZMsg(@"请眨眼");
            }
                break;
                
            default:
                break;
        }
        
        if ([MHSDK shareInstance].menuArray.count > 0) {
            for (MHBeautiesModel * model in self.array) {
                NSString * itemName = model.beautyTitle;
                if ([itemName isEqualToString:@"贴纸"]) {
                    [self.stickersView clearStikerUI];
                }
            }
        }
        
    });
    
}

//美妆
- (void)handleMakeUpType:(NSInteger)type withON:(BOOL)On{
    if (type == 0) {
        self.beautyManager.isUseMakeUp = NO;
    }else{
        self.beautyManager.isUseMakeUp = YES;
    }
    [self.beautyManager setBeautyManagerMakeUpType:type withOn:On];
}

- (void)getManagerActionStatus:(BOOL)hidden{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.hidden = YES;
        self.statusLabel.text = @"";
    });
    
}

//特效里面的哈哈镜
- (void)handleMagnityWithType:(NSInteger)type{
    [self handleMagnify:type withIsMenu:NO];
}

//哈哈镜
-(void)handleMagnify:(NSInteger)type withIsMenu:(BOOL)isMenu{
    if (type == 0){
        _beautyManager.isUseHaha = NO;
    }else{
        _beautyManager.isUseHaha = YES;
    }
    [_beautyManager setDistortType:type withIsMenu:isMenu];
}

//贴纸
- (void)handleStickerEffect:(NSString *)stickerContent sticker:(StickerDataListModel *)model withLevel:(NSInteger)level{
    if (model == nil){
        _beautyManager.isUseSticker = NO;
    }else{
        _beautyManager.isUseSticker = YES;
    }
    [self.beautyManager setSticker:stickerContent withLevel:level];
    if (self.sdkLevelTYpe == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.statusLabel.hidden == NO) {
                self.statusLabel.hidden = YES;
                self.statusLabel.text = @"";
            }
            [self.specificAssembleView clearAllActionEffects];
        });
    }
    
    
    
}

#pragma mark - 贴纸解析
- (void)getSticks {
     __weak typeof(self) weakSelf = self;
    
    if ([MHSDK shareInstance].stickerArray.count == 0) {
        return;
    }
    NSDictionary * itemDic = [MHSDK shareInstance].stickerArray[0];
    
    NSString * urlString = [NSString stringWithFormat:@"%@%@",@"https://data.facegl.com",itemDic[@"mark"]];
    NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    urlString = [data base64EncodedStringWithOptions:0];
    
    dispatch_async(dispatch_queue_create("com.suory.stickers", DISPATCH_QUEUE_SERIAL), ^{
        [[StickerManager sharedManager] requestStickersListWithUrl:urlString Success:^(NSArray<StickerDataListModel *> * _Nonnull stickerArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.stickersView configureStickers:stickerArray];
            });
        } Failed:^{
            
        }];
    });
}


#pragma mark - collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.array.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MHBeautyMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MHBeautyMenuCell" forIndexPath:indexPath];
    cell.isSimplification = self.sdkLevelTYpe==2?YES:NO;
    cell.menuModel = self.array[indexPath.row];
    if (![cell.menuModel.beautyTitle isEqualToString:@"单击拍"]){
        cell.hidden = self.menuHidden;
    }else{
        //短视频图片变化
        [cell changeRecordState:self.menuHidden];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake((window_width-40)/self.array.count, MHMeiyanMenusCellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了MHUI");
    if ([MHSDK shareInstance].menuArray.count == 0) {
        return;
    }
    MHBeautiesModel *currentModel = self.array[indexPath.row];
    if ([currentModel.beautyTitle isEqual:@""]) {
        if ([self.delegate respondsToSelector:@selector(cameraAction)]) {
            [self.delegate cameraAction];
        }
        return;
    }
    else if([currentModel.beautyTitle isEqual:@"单击拍"]){
        if ([self.delegate respondsToSelector:@selector(recordAction)]) {
            [self.delegate recordAction];
        }
        return;
    }else if ([currentModel.beautyTitle isEqual:YZMsg(@"特效")]){
        [self showBeautyViews:self.specificAssembleView];
    }else if ([currentModel.beautyTitle isEqual:YZMsg(@"贴纸")]){
        [self showBeautyViews:self.stickersView];
    }else if ([currentModel.beautyTitle isEqual:YZMsg(@"美颜")]){
        [self.beautyAssembleView configureUI];
        [self showBeautyViews:self.beautyAssembleView];
    }else if ([currentModel.beautyTitle isEqual:YZMsg(@"哈哈镜")]){
        [self showBeautyViews:self.magnifiedView];
    }else if ([currentModel.beautyTitle isEqual:YZMsg(@"美妆")]){
        [self showBeautyViews:self.makeUpView];
    }
    
    currentModel.isSelected = YES;
    if (self.lastIndex >= 0) {
        MHBeautiesModel *lastModel = self.array[self.lastIndex];
        lastModel.isSelected = NO;
    }
    self.lastIndex = indexPath.row;
    [self.collectionView reloadData];
}

#pragma mark - 切换美颜效果分类
- (void)showBeautyViews:(UIView *)currentView {
    
    [self.superView addSubview:currentView];
    CGRect rect = currentView.frame;
    rect.origin.y = window_height - currentView.frame.size.height - BottomIndicatorHeight;
    [currentView setFrame:rect];
    self.currentView = currentView;
    ///修改MHUI
    self.currentView.transform = CGAffineTransformMakeTranslation(0.00,  currentView.frame.size.height);
        [UIView animateWithDuration:0.3 animations:^{
           
            self.currentView.transform = CGAffineTransformMakeTranslation(0.00, 0.00);

        }];
    if ([currentView isEqual:self.beautyAssembleView]) {
        [self.beautyAssembleView configureUI];
        //[self.beautyAssembleView configureSlider];
    }
    ///修改MHUI
   
    self.hidden = YES;
    
    
}
- (void)animationOfTakingPhoto{
    MHBeautyMenuCell *cell = (MHBeautyMenuCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathWithIndex:2]];
    [cell takePhotoAnimation];
}
#pragma mark - lazy
- (MHBeautyAssembleView *)beautyAssembleView {
    if (!_beautyAssembleView) {
        _beautyAssembleView = [[MHBeautyAssembleView alloc] initWithFrame:CGRectMake(0, window_height-MHBeautyAssembleViewHeight-BottomIndicatorHeight, window_width, MHBeautyAssembleViewHeight)];
        _beautyAssembleView.delegate = self;
        
    }
    return _beautyAssembleView;
}

- (MHSpecificAssembleView *)specificAssembleView {
    if (!_specificAssembleView) {
        _specificAssembleView = [[MHSpecificAssembleView alloc] initWithFrame:CGRectMake(0, window_height-MHSpecificAssembleViewHeight-BottomIndicatorHeight, window_width, MHSpecificAssembleViewHeight)];
        _specificAssembleView.delegate = self;
        ///修改MHUI
        _specificAssembleView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:MHBlackAlpha];
    }
    return _specificAssembleView;
}
- (MHMagnifiedView *)magnifiedView {
    if (!_magnifiedView) {
        _magnifiedView = [[MHMagnifiedView alloc] initWithFrame:CGRectMake(0, window_height-MHMagnifyViewHeight-BottomIndicatorHeight, window_width, MHMagnifyViewHeight)];
        _magnifiedView.delegate = self;
        ///修改MHUI
        _magnifiedView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:MHBlackAlpha];
    }
    return _magnifiedView;
}

- (MHStickersView *)stickersView {
    if (!_stickersView) {
        _stickersView = [[MHStickersView alloc] initWithFrame:CGRectMake(0, window_height-MHStickersViewHeight-BottomIndicatorHeight , window_width, MHStickersViewHeight)];
        _stickersView.delegate = self;
        ///修改MHUI
        _stickersView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:MHBlackAlpha];
    }
    return _stickersView;
}


- (MHMakeUpView *)makeUpView {
    if (!_makeUpView) {
        _makeUpView = [[MHMakeUpView alloc] initWithFrame:CGRectMake(0, window_height-MHMagnifyViewHeight-BottomIndicatorHeight , window_width, MHMagnifyViewHeight)];
        _makeUpView.delegate = self;
        ///修改MHUI
        _makeUpView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:MHBlackAlpha];
    }
    return _makeUpView;
}


-(NSMutableArray *)array {
    if (!_array) {
        
        NSArray * itemArray = @[@{@"贴纸":StickerImg},@{@"美颜":BeautyImg},@{@"":CameraImg},@{@"特效":SpecificImg},@{@"哈哈镜":HahaImg},@{@"美妆":MakeUpImg}];
        NSMutableArray * selectedItem = [MHSDK shareInstance].menuArray;
        NSMutableArray * arr = [NSMutableArray array];
        for (int i = 0; i < selectedItem.count; i++) {
            NSString * name = selectedItem[i][@"name"];
            for (int j = 0; j < itemArray.count; j++) {
                NSDictionary * dic = itemArray[j];
                NSString * imageName = dic[name];
                if (imageName) {
                    [arr addObject:dic];
                }
            }
        }
//        if (arr.count == 4) {
//            [arr insertObject:itemArray[2] atIndex:2];
//        }else if(arr.count == 2){
//            [arr insertObject:itemArray[2] atIndex:1];
//        }
        
        
        _array = [NSMutableArray array];
        for (int i = 0; i<arr.count; i++) {
            NSDictionary * dic = arr[i];
            MHBeautiesModel *model = [[MHBeautiesModel alloc] init];
            model.imgName = dic.allValues[0];
            model.beautyTitle = dic.allKeys[0];
            model.menuType = MHBeautyMenuType_Menu;
            [_array addObject:model];
        }
        if (_array.count == 0) {
            for (int i = 0; i<itemArray.count; i++) {
                NSDictionary * dic = itemArray[i];
                MHBeautiesModel *model = [[MHBeautiesModel alloc] init];
                model.imgName = dic.allValues[0];
                model.beautyTitle = dic.allKeys[0];
                model.menuType = MHBeautyMenuType_Menu;
                [_array addObject:model];
            }
        }
        
        
        
    }
    
    
    return _array;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0,20);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, window_width, self.frame.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[MHBeautyMenuCell class] forCellWithReuseIdentifier:@"MHBeautyMenuCell"];
    }
    return _collectionView;
}

- (UILabel*)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake((window_width - 60)/2, window_height - MHStickersViewHeight - BottomIndicatorHeight - 50, 60, 22)];
//        _statusLabel.backgroundColor = [UIColor redColor];
        _statusLabel.text = @"请张嘴";
        _statusLabel.hidden = YES;
    }
    return _statusLabel;
}

- (int)sdkLevelTYpe{
    return [[MHSDK shareInstance] getSDKLevel];
}
@end
