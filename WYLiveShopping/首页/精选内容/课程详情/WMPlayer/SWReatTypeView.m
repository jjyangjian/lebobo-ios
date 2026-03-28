//
//  SWReatTypeView.m
//  YBEducation
//
//  Created by IOS1 on 2021/3/16.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import "SWReatTypeView.h"

@implementation SWReatTypeView

- (IBAction)rateTypeBtnClick:(UIButton *)sender {
    sender.selected = YES;
    if (self.block) {
        if (sender.tag == 1000) {
            //2x
            self.block(2);
        }else if (sender.tag == 1001) {
            //1.5x
            self.block(1.5);
        }else if (sender.tag == 1002) {
            //1x
            self.block(1);
        }else{
            //0.5x
            self.block(0.5);
        }
        [self reloadState:sender.tag];
    }
    self.hidden = YES;
}
- (void)reloadState:(NSInteger)btag{
    for (UIButton *btn in _buttonArray) {
        if (btn.tag != btag) {
            btn.selected = NO;
        }
    }
}

@end
