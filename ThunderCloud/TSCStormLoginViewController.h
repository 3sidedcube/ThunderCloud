//
//  TSCStormLoginViewController.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 18/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TSCStormLoginCompletion) (BOOL successful, BOOL cancelled);

/**
 A view controller which provides the user with an interface to login to their storm CMS account
 */
@interface TSCStormLoginViewController : UIViewController

/**
 @abstract Defines a block of code to be called when the user has attempted to log in
 */
@property (nonatomic, copy) TSCStormLoginCompletion completion;

@end
