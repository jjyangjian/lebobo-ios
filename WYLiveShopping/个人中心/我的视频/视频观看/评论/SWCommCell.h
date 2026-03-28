//
//  SWCommCell.h
//  yunbaolive
//
//  Created by Boom on 2018/12/17.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCommentModel.h"
@protocol SWCommCellDelegate <NSObject>

-(void)pushDetails:(NSDictionary *)commentdic;//跳回复列表

-(void)makeLikeRloadList:(NSString *)commectid andLikes:(NSString *)likes islike:(NSString *)islike;
- (void)reloadCurCell:(SWCommentModel *)model andIndex:(NSIndexPath *)curIndex andReplist:(NSArray *)list;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SWCommCell : UITableViewCell<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *zanBtn;
@property (weak, nonatomic) IBOutlet UILabel *zanNumLabel;
@property (weak, nonatomic) IBOutlet UITableView *replyTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableHeight;
@property(nonatomic,strong)NSMutableArray *replyArray;
@property(nonatomic,strong)UIButton *Reply_Button;//回复
@property(nonatomic,strong)UIView *replyBottomView;//回复
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property(nonatomic,strong)NSIndexPath *curIndex;//回复
@property (nonatomic,assign) BOOL isNoMore;//判断是不是没有更多了
@property(nonatomic,strong)SWCommentModel *model;
@property(nonatomic,assign)id<SWCommCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
