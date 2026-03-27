//
//  JJGoodsOffShelfView.h
//  WYLiveShopping
//

#import <UIKit/UIKit.h>
#import "liveGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^JJGoodsOffShelfRefreshBlock)(void);
typedef void(^JJGoodsOffShelfSelectBlock)(liveGoodsModel *model);
typedef void(^JJGoodsOffShelfActionBlock)(liveGoodsModel *model, NSString *actionType);

@interface JJGoodsOffShelfView : UIView

@property (nonatomic, copy) JJGoodsOffShelfRefreshBlock refreshBlock;
@property (nonatomic, copy) JJGoodsOffShelfSelectBlock selectBlock;
@property (nonatomic, copy) JJGoodsOffShelfActionBlock actionBlock;

- (void)requestFirstPageData;

@end

NS_ASSUME_NONNULL_END
