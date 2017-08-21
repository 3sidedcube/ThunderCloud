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
#import "TSCLink.h"
#import "UINavigationController+TSCNavigationController.h"
#import <ThunderCloud/ThunderCloud-Swift.h>

@import ThunderBasics;
@import ThunderTable;

@interface TSCGridPage () 

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong, readwrite) NSMutableArray *gridItems;

@end

@implementation TSCGridPage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        //Initialising from Storm
        self.title = TSCLanguageString(dictionary[@"title"][@"content"]);
        
        if ([dictionary[@"grid"] class] != [NSNull class]) {
            
            if ([dictionary isKindOfClass:[NSDictionary class]] && dictionary[@"name"] && [dictionary[@"name"] isKindOfClass:[NSString class]]) {
                self.pageName = dictionary[@"name"];
            }
            
            if ([dictionary[@"id"] isKindOfClass:[NSNumber class]]) {
                self.pageId = [NSString stringWithFormat:@"%@",dictionary[@"id"]];
            } else {
                self.pageId = dictionary[@"id"];
            }
            
            self.gridItems = [[NSMutableArray alloc] init];
            
            for (NSDictionary *unprocessedItem in dictionary[@"grid"][@"children"]) {
                
                TSCGridItem *item = [[TSCGridItem alloc] initWithDictionary:unprocessedItem];
                
                [self.gridItems addObject:item];
            }
            
            self.numberOfColumns = [dictionary[@"grid"][@"columns"] integerValue];
        }
        
        [self.flowLayout setItemSize:[self itemSizeForCells]];
        self.registeredCellClasses = [NSMutableArray new];
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
    
    [self configureCell:cell withIndexPath:indexPath];
    
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
    cell.contentView.backgroundColor = [TSCThemeManager shared].theme.mainColor;
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
    
    Class cellClass = [[TSCStormObjectFactory shared] classFor:item.itemClass];
    
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

- (void)configureCell:(UICollectionViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    TSCGridItem *item = self.gridItems[indexPath.item];
    
    if ([cell isKindOfClass:[TSCStandardGridItem class]]) {
        TSCStandardGridItem *standardCell = (TSCStandardGridItem *)cell;
        standardCell.imageView.image = item.image
        standardCell.textLabel.text = item.title;
        standardCell.detailTextLabel.text = item.itemDescription;
    }
    
    if ([cell isKindOfClass:[TSCQuizGridCell class]]) {
        TSCQuizGridCell *standardCell = (TSCQuizGridCell *)cell;
        
        standardCell.completedImage = standardCell.imageView.image;
		standardCell.isCompleted = [[TSCBadgeController sharedController] hasEarntBadgeWith: item.badgeId];
    }
    
    [cell layoutSubviews];
}

- (CGSize)itemSizeForCells
{
    CGSize itemSize = CGSizeMake((self.collectionView.bounds.size.width - (self.numberOfColumns - 1)) / self.numberOfColumns, (self.collectionView.bounds.size.width - (self.numberOfColumns - 1)) / self.numberOfColumns);
    
    return itemSize;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.flowLayout setItemSize:[self itemSizeForCells]];
}

@end
