//
//  TSCVideoScrubViewController.h
//  ThunderCloud
//
//  Created by Sam Houghton on 05/11/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 The bar that is shown at the top of the screen when playing a video.
 
 Responsibe for showing the length of the video, the current time of the video and a slider representing the current position of the video
 */
@interface TSCVideoScrubViewController : UIView

/**
 A label that displays the seconds and minutes that the video on screen has currently progressed through
 */
@property (nonatomic, strong) UILabel *currentTimeLabel;

/**
 A label that displays the total length of the video
 */
@property (nonatomic, strong) UILabel *endTimeLabel;

/**
 A slider representing the progress of the currently playing video
 */
@property (nonatomic, strong) UISlider *videoProgressTracker;

@end
