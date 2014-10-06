//
//  TSCGridPage.h
//  ASPCA
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCCollectionViewController.h"
#import "TSCGridItem.h"

@class TSCHUDAlertController;
@class TSCGridPage;

@interface TSCGridPage : TSCCollectionViewController

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSMutableArray *gridItems;
@property (nonatomic, strong) NSMutableArray *registeredCellClasses;
@property (nonatomic) CGFloat numberOfColumns;
@property (nonatomic, strong) TSCGridItem *selectedGridItem;

@property (nonatomic, strong) TSCHUDAlertController *alertController;

@end