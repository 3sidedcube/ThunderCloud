//
//  TSCVideoListItemViewCell.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 21/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCAnnularPlayButton;

@import ThunderTable;

/**
 The cell that displays an image and play animated play button to let the user know there is a video to play
 */
@interface TSCVideoListItemViewCell : TSCTableImageViewCell

/**
 The animated play button
 */
@property (nonatomic, strong) TSCAnnularPlayButton *playButton;

/**
 The length of the video in seconds
 */
@property (nonatomic) NSTimeInterval duration;

@end
