//
//  SWBrowserRecordCell.h
//  live1v1
//
//  Created by apple on 2020/2/6.
//  Copyright © 2020 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@class SWChatModel;
@protocol BrowserRecordCellDelegate <NSObject>

- (void)userToast:(SWChatModel *)model;

@end
@interface SWBrowserRecordCell : UITableViewCell
@property(nonatomic,weak)UIViewController *vc;
@property(nonatomic,strong)SWChatModel *model;

@property(nonatomic,weak)id<BrowserRecordCellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
