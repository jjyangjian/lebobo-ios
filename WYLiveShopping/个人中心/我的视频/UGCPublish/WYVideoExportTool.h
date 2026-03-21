//
//  WYVideoExportTool.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PHAsset;

NS_ASSUME_NONNULL_BEGIN
typedef void(^WYVideoExportToolResultBlock)(NSString *mp4File, NSData *mp4Data, NSError *error);

typedef enum : NSUInteger {
    ExportPresetLowQuality,        //低质量 可以通过移动网络分享
    ExportPresetMediumQuality,     //中等质量 可以通过WIFI网络分享
    ExportPresetHighestQuality,    //高等质量
    ExportPreset640x480,
    ExportPreset960x540,
    ExportPreset1280x720,    //720pHD
    ExportPreset1920x1080,   //1080pHD
    ExportPreset3840x2160,
} ExportPresetQuality;

@interface WYVideoExportTool : NSObject
/// 转码 MOV--MP4
/// @param resourceAsset MOV资源
/// @param exportQuality 预设
/// @param movEncodeToMpegToolResultBlock 转码后的MP4文件链接
+ (void)convertMovToMp4FromPHAsset:(PHAsset*)resourceAsset
     andAVAssetExportPresetQuality:(ExportPresetQuality)exportQuality
 andMovEncodeToMpegToolResultBlock:(WYVideoExportToolResultBlock)resultBlock;
@end

NS_ASSUME_NONNULL_END
