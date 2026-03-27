#import "JJNoDataNormalView.h"

@implementation JJNoDataNormalView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)configUI {
    self.backgroundColor = [UIColor clearColor];

    {
        UILabel *label = [[UILabel alloc] init];
        label.text = @"暂无数据";
        label.font = [UIFont boldSystemFontOfSize:24];
        label.textColor = RGB_COLOR(@"#888888", 1);
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self.mas_centerY).offset(-50);
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
        }];
        self.label = label;
    }
}

@end
