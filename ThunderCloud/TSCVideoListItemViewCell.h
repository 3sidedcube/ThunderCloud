//
//  TSCVideoListItemViewCell.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 21/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCAnnularPlayButton;

@import ThunderTable;

@interface TSCVideoListItemViewCell : TSCTableImageViewCell

@property (nonatomic, strong) TSCAnnularPlayButton *playButton;
@property (nonatomic) NSTimeInterval duration;

@end
