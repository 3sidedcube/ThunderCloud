//
//  TSCTipViewController.h
//  ThunderStorm
//
//  Created by Andrew Hart on 30/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import UIKit;

/**
 A placeholder `UIViewController` which is shown in the detail of a `TSCAccordionTabBarViewController` when there is nothing else to show in the detail view
 */
@interface TSCPlaceholderViewController : UIViewController

/**
 @abstract The detail text to be shown on the placeholder view
 */
@property (nonatomic, strong) NSString *placeholderDescription;

/**
 @abstract The image to be shown on the placeholder view
 */
@property (nonatomic, strong) UIImage *image;

@end
