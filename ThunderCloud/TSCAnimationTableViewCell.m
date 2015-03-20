//
//  TSCAnimationTableViewCell.m
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCAnimationTableViewCell.h"
#import "TSCAnimationFrame.h"
#import "TSCAnimation.h"

@interface TSCAnimationTableViewCell ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation TSCAnimationTableViewCell

- (void)resetAnimations
{
    [self.timer invalidate];
    
    [self nextImage];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)nextImage
{
    if (self.animation.animationFrames.count <= self.currentIndex) {
        return;
    }
    
    TSCAnimationFrame *currentFrame = self.animation.animationFrames[self.currentIndex];
    
    UIImage *image = currentFrame.image;
    
    [self.imageView setImage:image];
    
    if (self.animation.animationFrames.count > self.currentIndex) {
        
        if(self.animation.animationFrames.count == self.currentIndex + 1) {
            
            if(!self.animation.looped) {
                return;
            }
            
        }
        
        NSTimeInterval delay = currentFrame.delay.doubleValue / 1000;
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(nextImage) userInfo:nil repeats:NO];
    }
    else {
        
        if (self.animation.looped) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(nextImage) userInfo:nil repeats:NO];
        }
    }
    
    if (self.currentIndex != self.animation.animationFrames.count - 1) {
        self.currentIndex++;
    } else {
        self.currentIndex = 0;
    }
}

@end
