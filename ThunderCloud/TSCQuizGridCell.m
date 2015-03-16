//
//  TSCQuizGridCell.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizGridCell.h"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@implementation TSCQuizGridCell

- (void)setupAppearance
{
    if (self.isCompleted) {
        self.imageView.image = self.completedImage;
        self.backgroundColor = [UIColor whiteColor];
        self.imageView.alpha = 1.0;
    } else {
        
        if (self.nonCompletedImage) {
            
            self.imageView.image = self.nonCompletedImage;
            self.imageView.alpha = 1.0;
        } else {
            
            self.imageView.image = self.completedImage;
            self.imageView.alpha = 0.25;
        }
    }
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setImageView:(UIImageView *)imageView
{
    [super setImageView:imageView];
    [self setupAppearance];
}

- (void)setIsCompleted:(BOOL)isCompleted
{
    _isCompleted = isCompleted;
    [self setupAppearance];
}

- (void)wiggle
{
    [self _TSCStartWiggle];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.75 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self _TSCStopWiggle];
    });
}

- (void)makeImageViewVisible
{
    [UIView animateWithDuration:0.75  delay:0.0 options:kNilOptions animations:^ {
        self.imageView.hidden = NO;
    } completion:NULL];
}

#pragma mark - Wiggle methods

- (void)_TSCStartWiggle
{
    float currentAlpha = self.imageView.alpha;
    
    [UIView animateWithDuration:0.75 delay:0.0 options:kNilOptions animations:^ {
        self.imageView.alpha = MAX(0.6, currentAlpha);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.75 delay:0.0 options:kNilOptions animations:^ {
            self.imageView.alpha = currentAlpha;
        } completion:NULL];}];
    
    self.imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(-5));
    
    [UIView animateWithDuration:0.25 delay:0.0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse) animations:^ {
        self.imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, RADIANS(5));
    } completion:NULL];
}

- (void)_TSCStopWiggle
{
    [UIView animateWithDuration:0.25 delay:0.0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear) animations:^ {
        self.imageView.transform = CGAffineTransformIdentity;
    } completion:NULL];
}

@end