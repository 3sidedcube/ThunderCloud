//
//  TSCAppViewController.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 23/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCStormViewController.h"

/**
 `TSCAppViewController` is the root class of any Storm CMS driven app. By initialising this class, Storm builds the entire app defined by the JSON files included in the bundle delivered by Storm.
 
 Allocate an instance of this class and set it to the root view controller of the `UIWindow`.
 
 */
@interface TSCAppViewController : TSCStormViewController <UISplitViewControllerDelegate>

@end
