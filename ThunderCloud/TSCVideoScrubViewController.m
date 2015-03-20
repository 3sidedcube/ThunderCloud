//
//  TSCVideoScrubViewController.m
//  ThunderCloud
//
//  Created by Sam Houghton on 05/11/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCVideoScrubViewController.h"

@implementation TSCVideoScrubViewController

- (instancetype)init
{
    if (self = [super init]) {
        
        self.currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 12, self.bounds.size.width, 22)];
        self.currentTimeLabel.textAlignment = NSTextAlignmentLeft;
        self.currentTimeLabel.font = [UIFont boldSystemFontOfSize:14];
        self.currentTimeLabel.textColor = [UIColor whiteColor];
        self.currentTimeLabel.backgroundColor = [UIColor clearColor];
        
        self.currentTimeLabel.text = @"0:00";
        
        [self addSubview:self.currentTimeLabel];
        
        self.endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, self.bounds.size.width - 5, 22)];
        self.endTimeLabel.textAlignment = NSTextAlignmentRight;
        self.endTimeLabel.font = [UIFont boldSystemFontOfSize:14];
        self.endTimeLabel.textColor = [UIColor whiteColor];
        self.endTimeLabel.backgroundColor = [UIColor clearColor];
        
        self.endTimeLabel.text = @"0:00";
        
        [self addSubview:self.endTimeLabel];
        
        self.videoProgressTracker = [[UISlider alloc] initWithFrame:CGRectMake(44, 11, self.bounds.size.width - 88, 22)];
        [self.videoProgressTracker setThumbImage:[UIImage imageNamed:@"smallSlider" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        
        [self addSubview:self.videoProgressTracker];
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.currentTimeLabel.frame = CGRectMake(5, 12, self.bounds.size.width, 22);
    self.endTimeLabel.frame = CGRectMake(0, 12, self.bounds.size.width - 5, 22);
    self.videoProgressTracker.frame = CGRectMake(44, 11, self.bounds.size.width - 88, 22);
}

@end
