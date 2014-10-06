//
//  TSCPokemonListItem.h
//  ThunderStorm
//
//  Created by Andrew Hart on 15/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCStormObject.h"
@import UIKit;

@interface TSCPokemonListItem : TSCStormObject

@property (nonatomic, strong) NSURL *localLink;
@property (nonatomic, strong) NSURL *appStoreLink;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL isInstalled;

@end