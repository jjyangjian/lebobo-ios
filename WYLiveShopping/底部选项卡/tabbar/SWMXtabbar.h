//
//  SWMXtabbar.h
//  SWMXtabbar
//
//  Created by tang dixi on 30/7/14.
//  Copyright (c) 2014 Tangdxi. All rights reserved.
//

#import "SWZYPathItemButton.h"

@import UIKit;
@import QuartzCore;
@import AudioToolbox;

@class SWMXtabbar;

/*!
 *  The direction of a `SWMXtabbar` object's bloom animation.
 */
typedef NS_ENUM(NSUInteger, kMXtabbarBloomDirection) {
    /*!
     *  Bloom animation gose to the top of the `SWMXtabbar` object.
     */
    kMXtabbarBloomDirectionTop = 1,
    /*!
     *  Bloom animation gose to top left of the `SWMXtabbar` object.
     */
    kMXtabbarBloomDirectionTopLeft = 2,
    /*!
     *  Bloom animation gose to the left of the `SWMXtabbar` object.
     */
    kMXtabbarBloomDirectionLeft = 3,
    /*!
     *  Bloom animation gose to bottom left of the `SWMXtabbar` object.
     */
    kMXtabbarBloomDirectionBottomLeft = 4,
    /*!
     *  Bloom animation gose to the bottom of the `SWMXtabbar` object.
     */
    kMXtabbarBloomDirectionBottom = 5,
    /*!
     *  Bloom animation gose to bottom right of the `SWMXtabbar` object.
     */
    kMXtabbarBloomDirectionBottomRight = 6,
    /*!
     *  Bloom animation gose to the right of the `SWMXtabbar` object.
     */
    kMXtabbarBloomDirectionRight = 7,
    /*!
     *  Bloom animation gose around the `SWMXtabbar` object.
     */
    kMXtabbarBloomDirectionTopRight = 8,
};

/*!
 *  `MXtabbarDelegate` protocol defines methods that inform the delegate object the events of item button's selection, presentation and dismissal.
 */
@protocol MXtabbarDelegate <NSObject>

/*!
 *  Tells the delegate that the item button at an index is clicked.
 *
 *  @param SWMXtabbar    A `SWMXtabbar` object informing the delegate about the button click.
 *  @param itemButtonIndex The index of the item button being clicked.
 */
- (void)pathButton:(SWMXtabbar *)SWMXtabbar clickItemButtonAtIndex:(NSUInteger)itemButtonIndex;

@optional

/*!
 *  Tells the delegate that the `SWMXtabbar` object will present its items.
 *
 *  @param SWMXtabbar A `SWMXtabbar` object that is about to present its items.
 */
- (void)willPresentMXtabbarItems:(SWMXtabbar *)SWMXtabbar;
/*!
 *  Tells the delegate that the `SWMXtabbar` object has already presented its items.
 *
 *  @param SWMXtabbar A `SWMXtabbar` object that has presented its items.
 */
- (void)didPresentMXtabbarItems:(SWMXtabbar *)SWMXtabbar;

/*!
 *  Tells the delegate that the `SWMXtabbar` object will dismiss its items.
 *
 *  @param SWMXtabbar A `SWMXtabbar` object that is about to dismiss its items
 */
- (void)willDismissMXtabbarItems:(SWMXtabbar *)SWMXtabbar;
/*!
 *  Tells the delegate that the `SWMXtabbar` object has already dismissed its items.
 *
 *  @param SWMXtabbar A `SWMXtabbar` object that has dismissed its items.
 */
- (void)didDismissMXtabbarItems:(SWMXtabbar *)SWMXtabbar;

@end

@interface SWMXtabbar : UIView <UIGestureRecognizerDelegate>

/*!
 *  The object that acts as the delegate of the `SWMXtabbar` object.
 */
@property (weak, nonatomic) id<MXtabbarDelegate> delegate;

/*!
 *  `SWMXtabbar` object's bloom animation's duration.
 */
@property (assign, nonatomic) NSTimeInterval basicDuration;
/*!
 *  `YES` if allows `SWMXtabbar` object's sub items to rotate. Otherwise `NO`.
 */
@property (assign, nonatomic) BOOL allowSubItemRotation;

/*!
 *  `SWMXtabbar` object's bloom radius. The default value is 105.0f.
 */
@property (assign, nonatomic) CGFloat bloomRadius;

/*!
 *  `SWMXtabbar` object's bloom angle.
 */
@property (assign, nonatomic) CGFloat bloomAngel;

/*!
 *  The center of a `SWMXtabbar` object's position. The default value positions the `SWMXtabbar` object in bottom center.
 */
@property (assign, nonatomic) CGPoint ZYButtonCenter;

/*!
 *  If set to `YES` a sound will be played when the `SWMXtabbar` object is being interacted. The default value is `YES`.
 */
@property (assign, nonatomic) BOOL allowSounds;

/*!
 *  The path to the `SWMXtabbar` object's bloom effect sound file.
 */
@property (copy, nonatomic) NSString *bloomSoundPath;

/*!
 *  The path to the `SWMXtabbar` object's fold effect sound file.
 */
@property (copy, nonatomic) NSString *foldSoundPath;

/*!
 *  The path to the `SWMXtabbar` object's item action sound file.
 */
@property (copy, nonatomic) NSString *itemSoundPath;

/*!
 *  `YES` if allows the `SWMXtabbar` object's center button to rotate. Otherwise `NO`.
 */
@property (assign, nonatomic) BOOL allowCenterButtonRotation;

/*!
 *  Color of the backdrop view when `SWMXtabbar` object's sub items are shown.
 */
@property (strong, nonatomic) UIColor *bottomViewColor;

/*!
 *  Direction of `SWMXtabbar` object's bloom animation.
 */
@property (assign, nonatomic) kMXtabbarBloomDirection bloomDirection;

/*!
 *  Creates a `SWMXtabbar` object with a given normal image and highlited images for center button.
 *
 *  @param centerImage            The normal image for `SWMXtabbar` object's center button.
 *  @param centerHighlightedImage The highlighted image for `SWMXtabbar` object's center button.
 *
 *  @return A `SWMXtabbar` object.
 */
- (instancetype)initWithCenterImage:(UIImage *)centerImage
                   highlightedImage:(UIImage *)centerHighlightedImage;

/*!
 *  Creates a `SWMXtabbar` object with a given frame, normal and highlighted images for its center button.
 *
 *  @param centerButtonFrame      The frame of `SWMXtabbar` object.
 *  @param centerImage            The normal image for `SWMXtabbar` object's center button.
 *  @param centerHighlightedImage The highlighted image for `SWMXtabbar` object's center button.
 *
 *  @return A `SWMXtabbar` object.
 */
- (instancetype)initWithButtonFrame:(CGRect)centerButtonFrame
                        centerImage:(UIImage *)centerImage
                   highlightedImage:(UIImage *)centerHighlightedImage;

/*!
 *  Adds item buttons to an existing `SWMXtabbar` object.
 *
 *  @param pathItemButtons The item buttons to be added.
 */
- (void)addPathItems:(NSArray *)pathItemButtons;

@end
