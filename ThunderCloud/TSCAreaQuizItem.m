//
//  TSCAreaSelectionQuestion.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCAreaQuizItem.h"
#import "TSCQuizItem.h"
#import "TSCCoordinate.h"
#import "TSCZone.h"
#import "TSCImage.h"

@interface TSCAreaQuizItem ()

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@end

@implementation TSCAreaQuizItem

- (instancetype)initWithQuestion:(TSCQuizItem *)question
{
    if (self = [super init]) {
        
        self.question = question;
        self.image = [TSCImage imageWithDictionary:self.question.image];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = self.question.questionText;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        
        self.hintLabel = [[UILabel alloc] init];
        self.hintLabel.text = self.question.hintText;
        self.hintLabel.backgroundColor = [UIColor clearColor];
        
        self.imageView = [[UIImageView alloc] initWithImage:self.image];
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        self.tapRecognizer.numberOfTapsRequired = 1;
        self.tapRecognizer.numberOfTouchesRequired = 1;
        
        if ([TSCThemeManager isOS7]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    // -- TITLE LABEL -- //
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
    
    // -- IMAGE VIEW -- //
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageView addGestureRecognizer:self.tapRecognizer];
    self.imageView.userInteractionEnabled = YES;
    
    // -- HINT LABEL -- //
    self.hintLabel.backgroundColor = [UIColor clearColor];
    self.hintLabel.textColor = [UIColor lightGrayColor];
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.hintLabel];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat maxHeight = 550.0f;
    CGFloat scaleFactor = self.view.frame.size.width / self.image.size.width;
    
    CGSize constrainedSize = CGSizeMake(self.view.frame.size.width - 20, MAXFLOAT);
    CGSize titleHeight = [self.titleLabel sizeThatFits:constrainedSize];
    
    self.titleLabel.frame = CGRectMake(0, 10, self.view.bounds.size.width, titleHeight.height);
    CGFloat imageHeight = self.image.size.height * scaleFactor;
    self.imageView.frame = CGRectMake(0, self.view.center.y - imageHeight / 2, self.view.frame.size.width, self.image.size.height * scaleFactor);
    self.hintLabel.frame = CGRectMake(10, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 5, self.view.frame.size.width - 20, 44);
    
    if (self.imageView.frame.origin.y < self.hintLabel.frame.origin.y + self.hintLabel.frame.size.height + 10) {
        self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.hintLabel.frame.origin.y + self.hintLabel.frame.size.height + 10, self.imageView.frame.size.width, self.imageView.frame.size.height);
    }
    
    // Run cleanup if the image has resized itself too high!
    if (self.imageView.frame.size.height > maxHeight) {
        
        //Calculate over scale
        CGFloat resolutionFactor = maxHeight / self.imageView.frame.size.height;
        self.imageView.frame = CGRectMake(self.view.center.x - ((self.view.frame.size.width * resolutionFactor) / 2), self.view.center.y - (maxHeight / 2), self.view.frame.size.width * resolutionFactor, self.imageView.frame.size.height * resolutionFactor);
    }
}

#pragma mark Tap handling

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:sender.view];

    //
    // Add Circle
    //
    
    //Check if one exists first
    
    if (circle) {
        [circle removeFromSuperlayer];
    }
    
    //Circle radius (Fixed for now)
    int radius;
    
    if (isPad()) {
        radius = 40;
    } else {
        radius = 20;
    }
    
    //Generate a cricle
    circle = [CAShapeLayer layer];
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0 * radius, 2.0 * radius) cornerRadius:radius].CGPath;
    
    //Move to centre of tapped area (Consider the circle radius on the touched point)
    circle.position = CGPointMake(location.x - radius, location.y - radius);
    
    circle.fillColor = [UIColor clearColor].CGColor;
    circle.strokeColor = [UIColor blackColor].CGColor;
    circle.lineWidth = 3;
    
    //Add circle
    [[sender view].layer addSublayer:circle];
    
    // Configure animation
    CABasicAnimation *drawAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    drawAnimation.duration = 0.5;
    drawAnimation.repeatCount = 1.0;
    drawAnimation.removedOnCompletion = NO;
    drawAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    drawAnimation.toValue   = [NSNumber numberWithFloat:1.0f];
    drawAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

    [circle addAnimation:drawAnimation forKey:@"drawCircleAnimation"];
    
    //Handle validation
    TSCCoordinate *coord = [[TSCCoordinate alloc] init];
    double xPercentage = location.x / [sender view].frame.size.width;
    double yPercentage = location.y / [sender view].frame.size.height;
    coord.x = xPercentage;
    coord.y = yPercentage;
    
    [self validateTapAtCoordinate:coord];
}

- (void)validateTapAtCoordinate:(TSCCoordinate *)coordinate
{
    TSCCoordinate *givenCoordObject = coordinate;
    CGPoint givenCoord = CGPointMake(givenCoordObject.x, givenCoordObject.y);
    
    TSCZone *zone = self.question.correctZone;
    
    if ([zone containsPoint:givenCoord]) {
        self.question.isCorrect = YES;
    } else {
        self.question.isCorrect = NO;
    }
}

@end
