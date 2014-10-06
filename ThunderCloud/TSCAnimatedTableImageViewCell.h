//
//  TSCAnimatedTableImageViewCell.h
//  ThunderStorm
//
//  Created by Andrew Hart on 04/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderTable;

@interface TSCAnimatedTableImageViewCell : TSCTableImageViewCell

@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *delays;
@property (nonatomic) int currentIndex;

- (void)resetAnimations;

@end
