//
//  JJOrderBaseListView.h
//  WYLiveShopping
//
//  Created by IOS1 on 2026/3/27.
//  Copyright © 2026 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
@class orderModel;

NS_ASSUME_NONNULL_BEGIN

@interface JJOrderBaseListView : UIView

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSString *statusType;
@property (nonatomic, copy) void (^selectBlock)(orderModel *model);
@property (nonatomic, copy) void (^refreshBlock)(void);

- (void)configUI;
- (void)requestFirstPageData;
- (void)requestData;
- (void)updateNoDataViewHidden;

@end

NS_ASSUME_NONNULL_END