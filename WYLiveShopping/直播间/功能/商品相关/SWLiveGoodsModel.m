//
//  SWLiveGoodsModel.m
//  WYLiveShopping
//
//  Created by IOS1 on 2020/6/8.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWLiveGoodsModel.h"

@implementation SWLiveGoodsModel
-(instancetype)initWithDictionary:(NSDictionary *)map{
    self = [super init];
    if (self) {
        self.thumb = minstr([map valueForKey:@"image"]);
        self.name = minstr([map valueForKey:@"store_name"]);
        self.goodsID = minstr([map valueForKey:@"id"]);
        self.price = minstr([map valueForKey:@"price"]);
        self.is_sale = minstr([map valueForKey:@"is_sale"]);
        self.sales = minstr([map valueForKey:@"sales"]);
        self.salenums = minstr([map valueForKey:@"salenums"]);
        self.bring_price = minstr([map valueForKey:@"bring_price"]);
        if ([map valueForKey:@"vip_price"]) {
            self.vip_price = minstr([map valueForKey:@"vip_price"]);
        }else{
            self.vip_price = @"";
        }
        CGFloat wwww = [[SWToolClass sharedInstance] widthOfString:self.name andFont:SYS_Font(14) andHeight:20];
        if (wwww < (_window_width-30)/2 -16) {
            _isDouble = NO;
        }else{
            _isDouble = YES;
        }
    }
    return self;
}

@end
