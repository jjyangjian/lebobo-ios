//
//  JJShareLiveLinkView.h
//  testaaa
//
//  Created by 牛环环 on 2026/3/26.
//

#import <UIKit/UIKit.h>

@interface JJShareLiveLinkView : UIView

@property (nonatomic, copy) NSString *linkText;
@property (nonatomic, copy) void (^dismissBlock)(void);
@property (nonatomic, copy) void (^doneBlock)(void);

- (void)show;
- (void)dismiss;

@end
