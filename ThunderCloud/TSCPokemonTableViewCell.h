//
//  TSCPokemonTableViewCell.h
//  ThunderStorm
//
//  Created by Andrew Hart on 15/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCEmbeddedLinksListItemCell.h"
#import "TSCPokemonListItem.h"

@class TSCPokemonTableViewCell;

@protocol TSCPokemonTableViewCellDelegate

- (void)tableViewCell:(TSCPokemonTableViewCell *)cell didTapItemAtIndex:(NSInteger)index;

@end

@interface TSCPokemonTableViewCell : TSCEmbeddedLinksListItemCell

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, weak) id <TSCPokemonTableViewCellDelegate> delegate;

+ (float)heightForNumberOfItems:(float)numberOfItems withWidth:(float)width;

@end
