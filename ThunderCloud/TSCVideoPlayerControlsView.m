//
//  TSCVideoPlayerControlsView.m
//  ThunderCloud
//
//  Created by Sam Houghton on 28/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCVideoPlayerControlsView.h"
@import ThunderTable;

@implementation TSCVideoPlayerControlsView

- (instancetype)init
{
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor colorWithRed:74.0f/255.0f green:75.0f/255.0f blue:77.0f/255.0f alpha:1.0];
        
        self.playButton = [UIButton new];
        [self.playButton setImage:[UIImage imageNamed:@"mediaPauseButton" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self addSubview:self.playButton];
        
        self.languageButton = [UIButton new];
        [self.languageButton setImage:[UIImage imageNamed:@"mediaLanguageButton" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self addSubview:self.languageButton];
        
        self.volumeView = [MPVolumeView new];
        
        [self addSubview:self.volumeView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        
        self.playButton.frame = CGRectMake((self.frame.size.width / 2) - 50, 10, 24, 26);
        self.languageButton.frame = CGRectMake((self.frame.size.width / 2) + 20, 10, 24, 26);
        self.volumeView.frame = CGRectMake(44, self.bounds.size.height - 30, self.bounds.size.width - 88, 22);
        
    } else if (UIInterfaceOrientationIsLandscape(orientation)) {
        
        self.playButton.frame = CGRectMake((self.center.x), 7, 24, 26);
        self.languageButton.frame = CGRectMake(self.frame.size.width - 45, 7, 24, 26);
        self.volumeView.frame = CGRectMake(20, self.bounds.size.height - 30, (self.bounds.size.width / 2) - 50, 22);
    }
}

@end
