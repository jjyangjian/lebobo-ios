//
//  SWCourseContentVC.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/13.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWBaseViewController.h"
#import "SWCatalogModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^courseContentViewBackBlock)();
@interface SWCourseContentVC : SWBaseViewController
@property (nonatomic,strong) NSDictionary *courseMsgDic;

/// 1=详情目录里的小课时进入
@property (nonatomic,assign) int fromWhere;
@property (nonatomic,strong) SWCatalogModel *model;
@property (nonatomic,strong) NSString *thumb;
@property (nonatomic,copy) courseContentViewBackBlock block;

@end

NS_ASSUME_NONNULL_END
