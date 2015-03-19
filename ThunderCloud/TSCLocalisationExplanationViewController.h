//
//  TSCLocalisationExplanationViewController.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 18/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A view controller which explains to the user what is going on when they enter 'edit localisation' mode
 */
@interface TSCLocalisationExplanationViewController : UIViewController

/**
 @abstract A block which is called when the view controller wants to dismiss itself
 */
@property (nonatomic, copy) void (^TSCLocalisationDismissHandler)();

@end
