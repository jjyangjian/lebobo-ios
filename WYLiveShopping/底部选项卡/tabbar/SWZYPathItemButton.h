//
//  SWZYPathItemButton.h
//  SWMXtabbar
//
//  Created by tang dixi on 31/7/14.
//  Copyright (c) 2014 Tangdxi. All rights reserved.
//

@import UIKit;

@class SWZYPathItemButton;

/*!
 *  `ZYPathItemButtonDelegate` protocol defines method that informs the delegate object the event of item button's selection.
 */
@protocol ZYPathItemButtonDelegate <NSObject>

/*!
 *  Tells the delegate that the `SWZYPathItemButton` has been selected.
 *
 *  @param itemButton A `SWZYPathItemButton` that has been selected.
 */
- (void)itemButtonTapped:(SWZYPathItemButton *)itemButton;

@end

@interface SWZYPathItemButton : UIButton

/*!
 *  The location of the `SWZYPathItemButton` object in a `SWMXtabbar` object.
 */
@property (assign, nonatomic) NSUInteger index;

/*!
 *  The object that acts as the delegate of the `SWZYPathItemButton` object.
 */
@property (weak, nonatomic) id<ZYPathItemButtonDelegate> delegate;

/*!
 *  Creates a `SWZYPathItemButton` with normal and highlighted foreground and background images of the button.
 *
 *  @param image                      The normal foreground image.
 *  @param highlightedImage           The highlighted foreground image.
 *  @param backgroundImage            The normal background image.
 *  @param backgroundHighlightedImage The highlighted background image.
 *
 *  @return A `SWZYPathItemButton` object.
 */
- (instancetype)initWithImage:(UIImage *)image
             highlightedImage:(UIImage *)highlightedImage
              backgroundImage:(UIImage *)backgroundImage
   backgroundHighlightedImage:(UIImage *)backgroundHighlightedImage;

@end
