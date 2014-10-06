//
//  TSCMultiVideoPlayerViewController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 16/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@import AVFoundation;
@import UIKit;

@interface TSCMultiVideoPlayerViewController : UIViewController

- (id)initWithVideos:(NSArray *)videos;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *videoPlayerLayer;
//@property (nonatomic, strong) TSCLink *retryYouTubeLink;
@property (nonatomic, strong) NSArray *videos;
@end
