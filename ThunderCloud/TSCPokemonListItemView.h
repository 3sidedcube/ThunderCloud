//
//  TSCPokemonListItemView.h
//  ThunderStorm
//
//  Created by Andrew Hart on 15/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCListItemView.h"
#import "TSCPokemonListItem.h"
#import "TSCPokemonTableViewCell.h"

@interface TSCPokemonListItemView : TSCListItemView <TSCPokemonTableViewCellDelegate>

@property (nonatomic, strong) NSArray *items;

@end
