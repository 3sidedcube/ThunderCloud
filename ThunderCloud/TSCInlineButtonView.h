//
//  TSCButtonView.h
//  ThunderStorm
//
//  Created by Simon Mitchell on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSCLink;

/**
 `TSCInlineButtonView` is a `UIButton` that is used inside of cells to display embedded links.
 */
@interface TSCInlineButtonView : UIButton

/**
 @abstract The `TSCLink` to determine what action is performed when the button is pressed
 */
@property (nonatomic, strong) TSCLink *link;

/**
 @abstract A BOOL to disable and enable the button
 */
@property (nonatomic) BOOL disabled;

@end