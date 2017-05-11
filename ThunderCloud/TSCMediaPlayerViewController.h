//
//  TSCMediaPlayerViewController.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 11/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import AVKit;

/**
 The view controller presented to play standard video's
 */
@interface TSCMediaPlayerViewController : AVPlayerViewController

@property (nonatomic, assign) BOOL loop;

@end
