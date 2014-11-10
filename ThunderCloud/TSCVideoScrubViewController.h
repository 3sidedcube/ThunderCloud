//
//  TSCVideoScrubViewController.h
//  ThunderCloud
//
//  Created by Sam Houghton on 05/11/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSCVideoScrubViewController : UIView

@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *endTimeLabel;
@property (nonatomic, strong) UISlider *videoProgressTracker;

@end
