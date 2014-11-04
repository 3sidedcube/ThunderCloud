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

@protocol TSCLocalisationEditViewControllerDelegate <NSObject>

- (void)editingCancelledInViewController:(TSCLocalisationEditViewController *)viewController;
- (void)editingSavedInViewController:(TSCLocalisationEditViewController *)viewController;

@end

@interface TSCLocalisationEditViewController : TSCTableViewController

- (instancetype)initWithLocalisation:(TSCLocalisation *)localisation;

/**
 @abstract initialises the viewController with just a localisation key
 @description this method should be used if the localisation isn't set on the CMS, it creates a new TSCLocalisation object with all the available languages for the app.
 */
- (instancetype)initWithLocalisationKey:(NSString *)localisationKey;

/**
 @abstract The localisation that is currently being edited
 */
@property (nonatomic, strong) TSCLocalisation *localisation;

@property (nonatomic, strong) id <TSCLocalisationEditViewControllerDelegate> delegate;

@end
