//
//  RCAnnularPlayButton.h
//  SlideDemo
//
//  Created by Phillip Caudell on 12/04/2013.
//  Copyright (c) 2013 Phillip Caudell. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 An animated play button that appears over video objects
 */
@interface TSCAnnularPlayButton : UIView

/**
 The light image that animated around the outside of the play circle
 */
@property (nonatomic, strong) UIImageView *lightView;

/**
 The path that the animating image will take
 */
@property (nonatomic, weak) CAShapeLayer *pathLayer;

/**
 The background of the play button
 */
@property (nonatomic, strong) UIView *backgroundView;

/**
 The play image of the play button
 */
@property (nonatomic, strong) UIImageView *playView;

/**
 Whether or not the play button has finished it's animation
 */
@property (nonatomic, assign) BOOL isFinished;

/**
 Begins the animation that circles the play button
 */
- (void)startAnimation;

/**
 Begins the animation that circles the play button after a delay
 @param delay The number of seconds to wait before animating
 */
- (void)startAnimationWithDelay:(CGFloat)delay;

@end
