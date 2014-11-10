//
//  TSCPokemonTableViewCell.m
//  ThunderStorm
//
//  Created by Andrew Hart on 15/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCPokemonTableViewCell.h"
#import "TSCPokemonItemView.h"

#define POKEMON_CELL_SIZE CGSizeMake(57, 70)
#define MINIMUM_POKEMON_CELL_SPACING 16

@interface TSCPokemonTableViewCell ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *itemViews;

@end

@implementation TSCPokemonTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        
        self.scrollView = [[UIScrollView alloc] init];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        [self setupContentize];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    
    [self setupContentize];
}

+ (float)heightForNumberOfItems:(float)numberOfItems withWidth:(float)width
{
    return POKEMON_CELL_SIZE.height + (MINIMUM_POKEMON_CELL_SPACING * 2);
}

+ (int)numberOfItemsPerRowWithWidth:(float)width
{
    //Unused, and should remain that way unless multiple lines makes a comeback
    float numberOfItemsPerRow = (width - MINIMUM_POKEMON_CELL_SPACING) / (POKEMON_CELL_SIZE.width + MINIMUM_POKEMON_CELL_SPACING);
    
    return floor(numberOfItemsPerRow);
}

- (void)setupContentize
{
    self.scrollView.contentSize = CGSizeMake(((POKEMON_CELL_SIZE.width + MINIMUM_POKEMON_CELL_SPACING) * self.itemViews.count) + MINIMUM_POKEMON_CELL_SPACING, POKEMON_CELL_SIZE.height);
}

- (void)reloadData
{
    for (TSCPokemonItemView *view in self.itemViews) {
        [view removeFromSuperview];
    }
    
    [self.itemViews removeAllObjects];
    
    self.itemViews = nil;
    
    self.itemViews = [NSMutableArray new];
    
    for (TSCPokemonListItem *item in self.items) {
        
        NSInteger i = self.itemViews.count;
        
        TSCPokemonItemView *view = [[TSCPokemonItemView alloc] init];
        view.frame = CGRectMake(((POKEMON_CELL_SIZE.width + MINIMUM_POKEMON_CELL_SPACING) * i) + MINIMUM_POKEMON_CELL_SPACING,
        MINIMUM_POKEMON_CELL_SPACING,
        POKEMON_CELL_SIZE.width,
        POKEMON_CELL_SIZE.height);
        view.imageView.image = item.image;
        view.imageView.frame = view.bounds;
        view.label.text = item.name;
        view.button.tag = i;
        
        if (item.isInstalled) {
            view.imageView.alpha = 1.0;
        } else {
            view.imageView.alpha = 0.5;
        }
        
        [view.button addTarget:self action:@selector(handleCellTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:view];
        [self.itemViews addObject:view];
    }
}

#pragma mark - Interaction methods

- (void)handleCellTap:(UIButton *)button
{
    [self.delegate tableViewCell:self didTapItemAtIndex:button.tag];
}

#pragma mark - Setter methods

- (void)setItems:(NSArray *)items
{
    _items = items;
    
    [self setupContentize];
    
    [self reloadData];
}

@end
