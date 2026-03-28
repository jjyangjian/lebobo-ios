//
//  SWApplePay.h
//  TCLVBIMDemo
//
//  Created by 王敏欣 on 2016/12/2.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>





@protocol SWApplePayDelegate <NSObject>

-(void)SWApplePayHUD;
-(void)SWApplePayShowHUD;
-(void)SWApplePaySuccess;

@end

@interface SWApplePay : UIView

@property(nonatomic,assign)id<SWApplePayDelegate>delegate;

typedef void (^SWApplePayBlock)(id arrays);

-(void)SWApplePay:(NSDictionary *)dic;

@end
