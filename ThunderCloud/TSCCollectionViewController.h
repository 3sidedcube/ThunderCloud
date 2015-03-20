//
//  TSCCollectionViewController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A subclass of `UICollectionViewController` which handles automatically settint up the collection view with a `UICollectionViewFlowLayout` and sends a stat event upon `viewDidAppear:`
 */
@interface TSCCollectionViewController : UICollectionViewController

/**
 @abstract flowLayout the flow layout used for the `UICollectionView` attached to the view controller
 */
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@end
