//
//  TSCHUDAlertController.h
//  ThunderStorm
//
//  Created by Andrew Hart on 19/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCHUDButton.h"
#import "TSCStormObject.h"
@import UIKit;

#define ALERT_CONTROLLER_WIDTH 274

//First approach was to make this class be a sharedController.
//Buuuuuut, since it has a data source and delegate, that wouldn't be appropriate.
//Since it could change and mess everything up at any time.
//So it's not shared. Remember to add it as a property though.
//If you don't then very bad things will happen (object won't be retained, delegate calls will go nowhere, and everyone will be sad)
//(and then there won't be any cake)

typedef enum {
    TSCAlertAdditionalButtonTypeNone,
    TSCAlertAdditionalButtonTypeShare
} TSCAlertAdditionalButtonType;

@class TSCHUDAlertController;

@protocol TSCHUDAlertControllerDataSource <NSObject>

- (UIView *)customViewForAlertController:(TSCHUDAlertController *)controller;

- (int)numberOfActionButtonsForAlertController:(TSCHUDAlertController *)controller;
- (NSString *)alertController:(TSCHUDAlertController *)controller titleForActionButtonAtIndex:(NSInteger)index;
- (HUDButtonType)alertController:(TSCHUDAlertController *)controller typeForActionButtonAtIndex:(NSInteger)index;

@optional

- (TSCAlertAdditionalButtonType)additionalButtonTypeForAlertController:(TSCHUDAlertController *)controller;

- (BOOL)shouldDisplayDismissButtonInAlertController:(TSCHUDAlertController *)controller;

@end

@protocol  TSCHUDAlertControllerDelegate <NSObject>

- (void)alertController:(TSCHUDAlertController *)controller buttonWasSelectedAtIndex:(NSInteger)index;

@optional

- (void)additionalButtonWasTappedInAlertController:(TSCHUDAlertController *)controller;
- (void)willDismissAlertController:(TSCHUDAlertController *)controller;

@end

@interface TSCHUDAlertController : TSCStormObject

- (void)show;
- (void)dismiss;

- (void)reloadData;

@property (nonatomic, weak) id <TSCHUDAlertControllerDataSource> dataSource;
@property (nonatomic, weak) id <TSCHUDAlertControllerDelegate> delegate;

@end
