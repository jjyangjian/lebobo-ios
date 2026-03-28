//
//  SWFindVideoModel.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/9/2.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWFindVideoModel : NSObject
@property (nonatomic,strong) NSString *thumb;
@property (nonatomic,strong) NSString *videoid;
@property (nonatomic,strong) NSArray *goods;

-(instancetype)initWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
