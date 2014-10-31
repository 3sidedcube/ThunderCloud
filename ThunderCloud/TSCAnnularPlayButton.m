//
//  RCAnnularPlayButton.m
//  SlideDemo
//
//  Created by Phillip Caudell on 12/04/2013.
//  Copyright (c) 2013 Phillip Caudell. All rights reserved.
//

#import "TSCAnnularPlayButton.h"

@implementation TSCAnnularPlayButton

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
    
        self.lightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TSCAnnularPlayButton-light" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        self.lightView.alpha = 0.0;
        [self addSubview:self.lightView];
        
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.backgroundView.layer.cornerRadius = 35;
        self.backgroundView.alpha = 0.0;
        [self addSubview:self.backgroundView];
        
        self.playView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TSCAnnularPlayButton-play" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]];
        self.playView.alpha = 0.0;
        [self addSubview:self.playView];
    }
    
    return self;
}

- (UIBezierPath *)samplePath
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;

    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGFloat radius = (self.bounds.size.width - 1) / 2;
    CGFloat startAngle = - ((float) M_PI / 2);
    CGFloat endAngle = (2 * (float) M_PI) + startAngle;
    
    [path addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:NO];
    
    return path;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.lightView.frame = CGRectMake(-10, -10, 90, 90);
    self.playView.frame = CGRectMake(15, 15, 40, 40);
}

- (void)startAnimationWithDelay:(CGFloat)delay
{
    [self performSelector:@selector(startAnimation) withObject:nil afterDelay:delay];
}

- (void)startAnimation
{
    if (self.isFinished) {
        return;
    }
    
    if (self.pathLayer == nil) {

        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        
        shapeLayer.path = [[self samplePath] CGPath];
        shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
        shapeLayer.fillColor = nil;
        shapeLayer.lineWidth = 5.0f;
        shapeLayer.lineJoin = kCALineJoinRound;
        
        [self.layer addSublayer:shapeLayer];
        self.pathLayer = shapeLayer;
    }
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.2;
    pathAnimation.fromValue = @(0.0f);
    pathAnimation.toValue = @(1.0f);
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:- ( M_PI * 2.0 * 1 )];
    rotationAnimation.duration = 1.2;
    rotationAnimation.cumulative = YES;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

    CAKeyframeAnimation *alphaAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.duration = 1.2;
    alphaAnimation.values = @[@0.0, @1.0, @1.0, @1.0, @1.0, @0.0];
    alphaAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    alphaAnimation.delegate = self;
    
    [self.pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    [self.lightView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [self.lightView.layer addAnimation:alphaAnimation forKey:@"alphaAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
       
        self.backgroundView.alpha = 1.0;
        self.playView.alpha = 1.0;

    } completion:^(BOOL finished) {
        self.isFinished = YES;
    }];
}

@end
