//
//  SWLookVGoodsDView.h
//  iphoneLive
//
//  Created by IOS1 on 2019/7/8.
//  Copyright © 2019 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWLookVGoodsDView : UIView
-(instancetype)initWithGoodsMsg:(NSDictionary *)dic;
@property (nonatomic,strong) NSString *videoid;
@property (nonatomic,strong) NSString *videoUserid;

@end

NS_ASSUME_NONNULL_END
