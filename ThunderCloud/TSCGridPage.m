//
//  TSCGridPage.m
//  ASPCA
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCGridPage.h"
#import "TSCQuizGridCell.h"
#import <ThunderCloud/ThunderCloud-Swift.h>

@import ThunderBasics;
@import ThunderTable;

@interface TSCGridPage () <StormObjectProtocol>

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong, readwrite) NSMutableArray *gridItems;

@end

@implementation TSCGridPage

- (void)configureCell:(UICollectionViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
//    TSCGridItem *item = self.gridItems[indexPath.item];
//    
//    if ([cell isKindOfClass:[TSCStandardGridItem class]]) {
//        TSCStandardGridItem *standardCell = (TSCStandardGridItem *)cell;
//        standardCell.imageView.image = item.image;
//        standardCell.textLabel.text = item.title;
//        standardCell.detailTextLabel.text = item.itemDescription;
//    }
//    
//    if ([cell isKindOfClass:[TSCQuizGridCell class]]) {
//        TSCQuizGridCell *standardCell = (TSCQuizGridCell *)cell;
//        
//        standardCell.completedImage = standardCell.imageView.image;
//		standardCell.isCompleted = [[TSCBadgeController sharedController] hasEarntBadgeWith: item.badgeId];
//    }
//    
//    [cell layoutSubviews];
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
