//
//  TSCMultiVideoPlayerViewController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 16/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@import AVFoundation;
@import UIKit;

@class TSCVideoPlayerControlsView;
@class TSCVideoScrubViewController;

/**
 The multi video player view controller is responsible for displaying new style videos in Storm.
 
 Multi video players can take an array of videos and display the correct video for the current users language.
 
 Users also have the ability to change the language of their video manually
 */
@interface TSCMultiVideoPlayerViewController : UIViewController

/**
 Initialises the video player with an array of available videos
 @param videos An array of `TSCVideo` objects
 */
- (instancetype)initWithVideos:(NSArray *)videos;

@end
