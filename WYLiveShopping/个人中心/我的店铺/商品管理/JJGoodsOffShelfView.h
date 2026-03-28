//
//  JJGoodsOffShelfView.h
//  WYLiveShopping
//

#import <UIKit/UIKit.h>
#import "SWLiveGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^JJGoodsOffShelfRefreshBlock)(void);
typedef void(^JJGoodsOffShelfSelectBlock)(SWLiveGoodsModel *model);
typedef void(^JJGoodsOffShelfActionBlock)(SWLiveGoodsModel *model, NSString *actionType);

@interface JJGoodsOffShelfView : UIView

@property (nonatomic, copy) JJGoodsOffShelfRefreshBlock refreshBlock;
@property (nonatomic, copy) JJGoodsOffShelfSelectBlock selectBlock;
@property (nonatomic, copy) JJGoodsOffShelfActionBlock actionBlock;

- (void)requestFirstPageData;

@end

NS_ASSUME_NONNULL_END
