//
//  SWCatalogView.h
//  YBEducation
//
//  Created by IOS1 on 2020/3/12.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWCatalogView : UIView
-(instancetype)initWithFrame:(CGRect)frame andCourseID:(NSString *)str;
@property (nonatomic,strong) NSDictionary *homeDic;
- (void)reloadLIst:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
