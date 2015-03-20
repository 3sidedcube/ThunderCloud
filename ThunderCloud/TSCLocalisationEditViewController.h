//
//  TSCLocalisationEditViewController.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 17/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCLocalisation.h"
@import ThunderTable;

@class TSCLocalisationEditViewController;

/**
 A protocol used to communicate changes made in an instance of `TSCLocalisationEditViewController`
 */
@protocol TSCLocalisationEditViewControllerDelegate <NSObject>

/**
 This method is called when the user cancels editing a storm localisation
 @param viewController The view controller in which the editing was cancelled
 */
- (void)editingCancelledInViewController:(TSCLocalisationEditViewController *)viewController;

/**
 This method is called when the user has requested the changes they made to a localisation be saved
 @param viewController The view controller in which the editing occured
 */
- (void)editingSavedInViewController:(TSCLocalisationEditViewController *)viewController;

@end

/**
 Used to display and allow editing of CMS localisation values
 */
@interface TSCLocalisationEditViewController : TSCTableViewController

/**
 @abstract Initialises the viewController with a `TSCLocalisation` object
 @discussion this method should be used if the localisation is already set in the CMS and has been allocated as an instance of `TSCLocalisation`
 */
- (instancetype)initWithLocalisation:(TSCLocalisation *)localisation;

/**
 @abstract Initialises the viewController with a localisation key
 @discussion this method should be used if the localisation isn't set on the CMS, it creates a new TSCLocalisation object with all the available languages for the app.
 */
- (instancetype)initWithLocalisationKey:(NSString *)localisationKey;

/**
 @abstract The localisation that is currently being edited
 */
@property (nonatomic, strong) TSCLocalisation *localisation;

/**
 @abstract The delegate which will be notified of the user editing or cancelling editing of the localisation
 @see `TSCLocalisationEditViewControllerDelegate`
 */
@property (nonatomic, strong) id <TSCLocalisationEditViewControllerDelegate> delegate;

@end
