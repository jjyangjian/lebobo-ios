//
//  WYWaterFallLayout.h
//  WYLiveShopping
//
//  Created by IOS1 on 2021/8/31.
//  Copyright © 2021 IOS1. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WYWaterFallLayout;
NS_ASSUME_NONNULL_BEGIN

@protocol  WYWaterFallLayoutDeleaget<UICollectionViewDelegateFlowLayout>

@required
/**
 * 每个item的高度
 */
- (CGFloat)waterFallLayout:(WYWaterFallLayout *)waterFallLayout heightForItemAtIndexPath:(NSUInteger)indexPath itemWidth:(CGFloat)itemWidth;

@optional
/**
 * 有多少列
 */
- (NSUInteger)columnCountInWaterFallLayout:(WYWaterFallLayout *)waterFallLayout;

/**
 * 每列之间的间距
 */
- (CGFloat)columnMarginInWaterFallLayout:(WYWaterFallLayout *)waterFallLayout;

/**
 * 每行之间的间距
 */
- (CGFloat)rowMarginInWaterFallLayout:(WYWaterFallLayout *)waterFallLayout;

/**
 * 每个item的内边距
 */
- (UIEdgeInsets)edgeInsetdInWaterFallLayout:(WYWaterFallLayout *)waterFallLayout;


@end

@interface WYWaterFallLayout : UICollectionViewLayout
/** 代理 */
@property (nonatomic, weak) id<WYWaterFallLayoutDeleaget> delegate;



@end

NS_ASSUME_NONNULL_END
