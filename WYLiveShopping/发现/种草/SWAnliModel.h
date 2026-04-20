//
//  SWAnliModel.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/30.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWAnliModel : NSObject
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSAttributedString *contentAttStr;
@property (nonatomic,strong) NSArray *image;
@property (nonatomic,strong) NSArray *goods;
@property (nonatomic,assign) CGFloat rowH;
@property (nonatomic,assign) CGFloat imageH;
@property (nonatomic,assign) CGFloat scrollH;
@property (nonatomic,assign) BOOL isLive;
@property (nonatomic,strong) NSString *views;
@property (nonatomic,strong) NSString *mer_id;
@property (nonatomic,strong) NSString *isattent;
@property (nonatomic,strong) NSString *kolid;
@property (nonatomic,strong) NSString *islike;
@property (nonatomic,strong) NSString *likes;
@property (nonatomic,strong) NSString *nickname;
@property (nonatomic,strong) NSString *avatar;
@property (nonatomic,strong) NSString *add_time;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *shoptype;

-(instancetype)initWithDic:(NSDictionary *)dic;
@end

NS_ASSUME_NONNULL_END
