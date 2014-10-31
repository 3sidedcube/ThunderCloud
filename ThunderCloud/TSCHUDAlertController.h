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
