//
//  TSCGridPage.m
//  ASPCA
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCGridPage.h"
#import "TSCStandardGridItem.h"
#import "TSCQuizGridCell.h"
#import "TSCAchievementDisplayView.h"
#import "TSCBadge.h"
#import "TSCBadgeController.h"
#import "TSCLink.h"
#import "UINavigationController+TSCNavigationController.h"
#import "TSCImage.h"
#import "TSCStormObject.h"

@import ThunderBasics;
@import ThunderTable;

@interface TSCGridPage () 

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSMutableArray *registeredCellClasses;
@property (nonatomic) CGFloat numberOfColumns;
@property (nonatomic, strong, readwrite) TSCGridItem *selectedGridItem;
@property (nonatomic, strong, readwrite) NSMutableArray *gridItems;

@end

@implementation TSCGridPage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        //Initialising from Storm
        self.title = TSCLanguageString(dictionary[@"title"][@"content"]);
        
        if ([dictionary[@"grid"] class] != [NSNull class]) {
            
            self.gridItems = [[NSMutableArray alloc] init];
            
            for (NSDictionary *unprocessedItem in dictionary[@"grid"][@"children"]) {
                
                TSCGridItem *item = [[TSCGridItem alloc] initWithDictionary:unprocessedItem];
                
                [self.gridItems addObject:item];
            }
            
            self.numberOfColumns = [dictionary[@"grid"][@"columns"] floatValue];
        }
        
        [self.flowLayout setItemSize:[self TSC_itemSizeForCells]];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.gridItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Class gridViewCellClass = [self TSC_gridViewCellClassForIndexPath:indexPath];
    
    // Check if class is registered with table view
    
    if (![self TSC_isCellClassRegistered:gridViewCellClass]) {
        [self TSC_registerCellClass:gridViewCellClass];
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(gridViewCellClass) forIndexPath:indexPath];
    
    [self TSC_configureCell:cell withIndexPath:indexPath];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedGridItem = self.gridItems[indexPath.item];
    
    TSCLink *link = [[TSCLink alloc] initWithDictionary:self.selectedGridItem.link];
    [self.navigationController pushLink:link];
}

#pragma mark - Highlight handling

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [[TSCThemeManager sharedTheme] mainColor];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
}

#pragma mark - Class helpers
- (Class)TSC_gridViewCellClassForIndexPath:(NSIndexPath *)indexPath
{
    TSCGridItem *item = self.gridItems[indexPath.item];
    
    Class cellClass = [TSCStormObject classForClassKey:item.itemClass];
    
    return cellClass;
}

- (BOOL)TSC_isCellClassRegistered:(Class)class
{
    BOOL isCellClassRegistered = NO;
    NSString *queryingClassName = NSStringFromClass(class);
    
    for (NSString *className in self.registeredCellClasses) {
        if ([queryingClassName isEqualToString:className]) {
            isCellClassRegistered = YES;
            break;
        }
    }
    
    return isCellClassRegistered;
}

- (void)TSC_registerCellClass:(Class)class
{
    [self.registeredCellClasses addObject:NSStringFromClass(class)];
    [self.collectionView registerClass:class forCellWithReuseIdentifier:NSStringFromClass(class)];
}

- (void)TSC_configureCell:(UICollectionViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    TSCGridItem *item = self.gridItems[indexPath.item];
    
    if ([cell isKindOfClass:[TSCStandardGridItem class]]) {
        TSCStandardGridItem *standardCell = (TSCStandardGridItem *)cell;
        standardCell.imageView.image = [TSCImage imageWithDictionary:item.image];
        standardCell.textLabel.text = item.title;
        standardCell.detailTextLabel.text = item.itemDescription;
    }
    
    if ([cell isKindOfClass:[TSCQuizGridCell class]]) {
        TSCQuizGridCell *standardCell = (TSCQuizGridCell *)cell;
        
        standardCell.completedImage = standardCell.imageView.image;
        standardCell.isCompleted = [[TSCBadgeController sharedController] hasEarntBadgeWithId:item.badgeId];
    }
    
    [cell layoutSubviews];
}

- (CGSize)TSC_itemSizeForCells
{
    CGSize itemSize = CGSizeMake((self.view.bounds.size.width - (self.numberOfColumns - 1)) / self.numberOfColumns, 230);
    
    return itemSize;
}

@end