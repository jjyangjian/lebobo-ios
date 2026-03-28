//
//  JJGoodsOnSaleView.h
//  WYLiveShopping
//

#import <UIKit/UIKit.h>
#import "SWLiveGoodsModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^JJGoodsViewRefreshBlock)(void);
typedef void(^JJGoodsViewSelectBlock)(SWLiveGoodsModel *model);
typedef void(^JJGoodsViewActionBlock)(SWLiveGoodsModel *model, NSString *actionType);

@interface JJGoodsOnSaleView : UIView

@property (nonatomic, copy) JJGoodsViewRefreshBlock refreshBlock;
@property (nonatomic, copy) JJGoodsViewSelectBlock selectBlock;
@property (nonatomic, copy) JJGoodsViewActionBlock actionBlock;

- (void)requestFirstPageData;

@end

NS_ASSUME_NONNULL_END
