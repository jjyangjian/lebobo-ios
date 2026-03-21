//
//  MHBeautyOfKSYStream.m


#import "MHBeautyOfKSYStream.h"
@interface MHBeautyOfKSYStream()
@property KSYGPUPicOutput *pipOut;
@property (nonatomic, strong) MHBeautyManager *beautyManager;
@property(nonatomic,assign)BOOL isDefault;

@end

@implementation MHBeautyOfKSYStream

- (id)initMHSDKWithManager:(MHBeautyManager *)manager{
    self = [super initWithFmt:kCVPixelFormatType_32BGRA];
    if (self) {
        _pipOut = [[KSYGPUPicOutput alloc] initWithOutFmt:kCVPixelFormatType_32BGRA];
        __weak MHBeautyOfKSYStream *weak_filter = self;
        _beautyManager = manager;
        _pipOut.videoProcessingCallback = ^(CVPixelBufferRef pixelBuffer, CMTime timeInfo) {
            [weak_filter renderMHSDK:pixelBuffer timeInfo:timeInfo manager:manager];
        };
    }
    return self;
}

#pragma mark - Render CallBack
- (void)renderMHSDK:(CVPixelBufferRef)pixelBuffer timeInfo:(CMTime)timeInfo  manager:(MHBeautyManager *)manager {
    OSType formatType = CVPixelBufferGetPixelFormatType(pixelBuffer) ;
    if(manager){
        
        [manager processWithPixelBuffer:pixelBuffer formatType:formatType];
        /* 设置初始化默认值，即一打开直播有美颜效果
        if (!_isDefault) {
            [self setupDefaultBeautyAndFaceValueWithIsTX:NO];
            _isDefault = YES;
        }
         */
    }
    [self processPixelBuffer:pixelBuffer time:timeInfo];
}

- (void)setupDefaultBeautyAndFaceValueWithIsTX:(BOOL)isTX{
    //设置美型默认数据，按照数组的名称设置初始值，不要换顺序
    //此处只是说明该位置对应的类型，如果打开注释，请填写具体数值
    
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
//    for (int i = 0; i<originalValuesArr.count; i++) {
//        if (i != 0) {
//            NSInteger value = (NSInteger)originalValuesArr[i];
//            [self handleFaceBeautyWithType:i sliderValue:value];
//        }
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
        [_beautyManager setBuffing:(mopi.floatValue)/9.0];
        [_beautyManager setSkinWhiting:(white.floatValue)/9.0];
        [_beautyManager setRuddiness:(hongrun.floatValue)/9.0];
    }
    
}

#pragma GPUImageInput
- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    [_pipOut newFrameReadyAtTime:frameTime atIndex:textureIndex];
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex {
    [_pipOut setInputFramebuffer:newInputFramebuffer atIndex:textureIndex];
}

- (NSInteger)nextAvailableTextureIndex {
    return 0;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    [_pipOut setInputSize:newSize atIndex:textureIndex];
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    [_pipOut setInputRotation:newInputRotation atIndex:textureIndex];
}

- (GPUImageRotationMode)getInputRotation {
    return [_pipOut getInputRotation];
}

- (CGSize)maximumOutputSize {
    return [_pipOut maximumOutputSize];
}

- (void)endProcessing {
}

- (BOOL)shouldIgnoreUpdatesToThisTarget {
    return NO;
}

- (BOOL)wantsMonochromeInput {
    return NO;
}

- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue {
}

@end

