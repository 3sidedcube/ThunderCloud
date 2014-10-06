//
//  PCHUDActivityView.m
//  Glenigan
//
//  Created by Phillip Caudell on 03/05/2012.
//  Copyright (c) 2012 madebyphill.co.uk. All rights reserved.
//

#import "PCHUDActivityView.h"
@import ThunderTable;

@implementation PCHUDActivityView

@synthesize activityIndicatorView;

+ (void)startInView:(UIView *)view
{
    [PCHUDActivityView startInView:view style:PCHUDActivityViewStyleDefault];
}

+ (void)startInView:(UIView *)view style:(PCHUDActivityViewStyle)style
{
    PCHUDActivityView *activityView = [PCHUDActivityView activityInView:view];
    
    if (!activityView) {
        activityView = [[PCHUDActivityView alloc] initWithStyle:style];
    }
    
    activityView.displayCount++;
    
    if (activityView.displayCount == 1) {
        [activityView showInView:view];
    }
}

+ (void)finishInView:(UIView *)view
{
    PCHUDActivityView *activityView = [PCHUDActivityView activityInView:view];
    
    activityView.displayCount--;
    
    if (activityView.displayCount == 0) {
        [activityView finish];
    }
}

+ (PCHUDActivityView *)activityInView:(UIView *)view
{
    for (PCHUDActivityView *activityView in view.subviews) {
        if ([activityView isKindOfClass:[PCHUDActivityView class]]) {
            return activityView;
        }
    }
    
    return nil;
}

- (id)initWithStyle:(PCHUDActivityViewStyle)style
{
    self = [super initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    if (self) {
        
        if (style == PCHUDActivityViewStyleDefault) {
            UIView *background = [[UIView alloc] initWithFrame:self.bounds];
            background.backgroundColor = [UIColor blackColor];
            background.alpha = 0.7;
            background.layer.cornerRadius = 8;
            [self addSubview:background];
        }

        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:self.activityIndicatorView];
        [self.activityIndicatorView setFrame:CGRectMake(self.frame.size.width / 2 - 15, self.frame.size.height / 2 - 15, 30, 30)];
        [self.activityIndicatorView startAnimating];
        
        if (style == PCHUDActivityViewStylePlain) {
            
            self.activityIndicatorView.color = [[TSCThemeManager sharedTheme] mainColor];
        }
        
        self.displayCount = 0;
    }
    
    return self;
}

- (void)showInView:(UIView *)view
{
    [view addSubview:self];
    
    [self setFrame:CGRectMake(view.frame.size.width / 2 - 50, view.frame.size.height / 2 - 50, 100, 100)];
    
    // Pop
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    CATransform3D scale1 = CATransform3DMakeScale(0.1, 0.1, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
    
    NSArray *frameValues = @[[NSValue valueWithCATransform3D:scale1],
                            [NSValue valueWithCATransform3D:scale2],
                            [NSValue valueWithCATransform3D:scale3],
                            [NSValue valueWithCATransform3D:scale4]];
    [animation setValues:frameValues];
    
    
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = 0.65;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

    [self.layer addAnimation:animation forKey:@"popup"];
}

- (void)finish
{
    [UIView animateWithDuration:0.35 animations:^{
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
