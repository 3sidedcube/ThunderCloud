//
//  TSCPokemonListItemView.h
//  ThunderStorm
//
//  Created by Andrew Hart on 15/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCTitleListItem.h"
#import "TSCPokemonListItem.h"


@interface TSCPokemonListItemView : TSCTitleListItem /*<TSCPokemonTableViewCellDelegate>*/

@property (nonatomic, strong) NSArray *items;

@end
