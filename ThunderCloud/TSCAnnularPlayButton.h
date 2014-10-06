//
//  RCAnnularPlayButton.h
//  SlideDemo
//
//  Created by Phillip Caudell on 12/04/2013.
//  Copyright (c) 2013 Phillip Caudell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSCAnnularPlayButton : UIView

@property (nonatomic, strong) UIImageView *lightView;
@property (nonatomic, weak) CAShapeLayer *pathLayer;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIImageView *playView;
@property (nonatomic, assign) BOOL isFinished;

- (void)startAnimation;
- (void)startAnimationWithDelay:(CGFloat)delay;

@end
