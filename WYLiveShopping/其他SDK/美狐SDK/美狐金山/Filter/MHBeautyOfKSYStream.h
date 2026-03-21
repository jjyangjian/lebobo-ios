//
//  MHBeautyOfKSYStream.h


#import <libksygpulive/libksygpulive.h>
#import <GPUImage/GPUImage.h>
#import <libksygpulive/libksygpulive.h>
#import <MHBeautySDK/MHBeautyManager.h>
#import <libksygpulive/libksystreamerengine.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHBeautyOfKSYStream : KSYGPUPicInput<GPUImageInput>
- (id)initMHSDKWithManager:(MHBeautyManager *)manager;
@end

NS_ASSUME_NONNULL_END
