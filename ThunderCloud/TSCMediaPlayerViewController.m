//
//  TSCMediaPlayerViewController.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 11/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCMediaPlayerViewController.h"
@import AVFoundation;

@interface TSCMediaPlayerViewController ()

@end

@implementation TSCMediaPlayerViewController

- (void)setLoop:(BOOL)loop
{
    if (!_loop && loop) {
        
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[self.player currentItem]];
    } else if (!loop && _loop) {
        
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    
    _loop = loop;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[AVPlayerItem class]]) {
        AVPlayerItem *player = [notification object];
        [player seekToTime:kCMTimeZero];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.loop) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
}

@end
