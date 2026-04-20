//
//  moneyBottomView.m
//  YBEducation
//
//  Created by IOS1 on 2020/5/6.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import "SWCarBottomView.h"

@implementation SWCarBottomView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)allBtnClick:(id)sender {
    _allButton.selected = !_allButton.selected;
    if (self.block) {
        self.block(_allButton.selected);
    }
}
- (IBAction)buyButtonCkick:(id)sender {
    self.block(2);
}
- (IBAction)delateButtonCkick:(id)sender {
    self.block(3);
}
- (IBAction)collectButtonCkick:(id)sender {
    self.block(4);
}

@end
