//
//  TSCAnimatedTableImageViewCell.m
//  ThunderStorm
//
//  Created by Andrew Hart on 04/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCAnimatedTableImageViewCell.h"

@interface TSCAnimatedTableImageViewCell ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation TSCAnimatedTableImageViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
    }
    
    return self;
}

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
    if (self.images.count <= self.currentIndex) {
        return;
    }
    
    UIImage *image = self.images[self.currentIndex];
    
    [self.imageView setImage:image];
    
    if (self.delays.count > self.currentIndex) {
        NSTimeInterval delay = [[self.delays objectAtIndex:self.currentIndex] floatValue] / 1000;
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(nextImage) userInfo:nil repeats:NO];
    }
    else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(nextImage) userInfo:nil repeats:NO];
    }
    
    if (self.currentIndex != self.images.count - 1) {
        self.currentIndex++;
    } else {
        self.currentIndex = 0;
    }
}

@end
