//
//  JJHomeLiveListCell.h
//  testaaa
//
//  Created by 牛环环 on 2026/3/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJHomeLiveListCell : UITableViewCell

@property(nonatomic,strong)UIImageView *largeImageView;
@property(nonatomic,strong)UIImageView *avatarImageView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *nicknameLabel;
@property(nonatomic,strong)UILabel *likeCountLabel;
@property(nonatomic,strong)UILabel *watchCountLabel;

- (void)bindFromModel:(NSDictionary *)model;

@end

NS_ASSUME_NONNULL_END
