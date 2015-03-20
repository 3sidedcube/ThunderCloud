//
//  TSCVideoPlayerControlsView.h
//  ThunderCloud
//
//  Created by Sam Houghton on 28/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MediaPlayer;

/**
 The view shown over/below a full screen video that displays controls
 */
@interface TSCVideoPlayerControlsView : UIView

/**
 The volume view for adjusting the video volume or switching to an Airplay device
 */
@property (nonatomic, strong) MPVolumeView *volumeView;

/**
 The play/pause button for the video
 */
@property (nonatomic, strong) UIButton *playButton;

/**
 Where multiple languages are available, this button is available for choosing the video in an alternative language
 */
@property (nonatomic, strong) UIButton *languageButton;

@end
