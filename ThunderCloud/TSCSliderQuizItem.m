//
//  TSCImageSliderSelectionQuestion.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCSliderQuizItem.h"
#import "TSCQuizItem.h"
#import "TSCImage.h"
@import ThunderBasics;

@interface TSCSliderQuizItem ()

@property (nonatomic, strong) UIView *titleWrapper;
@property (nonatomic, strong) UIView *bottomWrapper;

@end

@implementation TSCSliderQuizItem

- (instancetype)initWithQuestion:(TSCQuizItem *)question
{
    if (self = [super init]) {
        
        self.question = question;
        
        self.titleWrapper = [UIView new];
        self.titleWrapper.backgroundColor = [UIColor whiteColor];
        
        self.bottomWrapper = [UIView new];
        self.bottomWrapper.backgroundColor = [UIColor whiteColor];
        
        // TITLE ---
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = self.question.questionText;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        self.titleLabel.numberOfLines = 0;
        
        // IMAGE --
        self.imageView = [[UIImageView alloc] initWithImage:[TSCImage imageWithJSONObject:self.question.image]];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = 6.0f;
        
        // UNITS ---
        self.unitsLabel = [[UILabel alloc] init];
        self.unitsLabel.text = self.question.sliderUnit;
        self.unitsLabel.backgroundColor = [UIColor clearColor];
        self.unitsLabel.textAlignment = NSTextAlignmentCenter;
        
        // SLIDER ---
        self.slider = [[UISlider alloc] init];
        [self.slider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
        
        self.slider.minimumValue = self.question.sliderStartValue;
        self.slider.minimumTrackTintColor = [[TSCThemeManager sharedTheme] mainColor];
        self.slider.maximumValue = self.question.sliderMaxValue;
        self.slider.value = self.question.sliderInitialValue;
        
        // HINT ---
        self.hintLabel = [[UILabel alloc] init];
        self.hintLabel.text = self.question.hintText;
        self.hintLabel.textColor = [UIColor lightGrayColor];
        self.hintLabel.backgroundColor = [UIColor clearColor];
        self.hintLabel.numberOfLines = 2;
        self.hintLabel.textAlignment = NSTextAlignmentCenter;
        
        self.unitsLabel.text = [NSString stringWithFormat:@"%d %@", (int)self.slider.value, self.question.sliderUnit];
        
        if ([TSCThemeManager isOS7]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
        
        self.view.backgroundColor = [[TSCThemeManager sharedTheme] backgroundColor];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.bottomWrapper addSubview:self.slider];
    [self.view addSubview:self.imageView];
    [self.bottomWrapper addSubview:self.unitsLabel];
    [self.titleWrapper addSubview:self.hintLabel];
    [self.titleWrapper addSubview:self.titleLabel];
    [self.view addSubview:self.titleWrapper];
    [self.view addSubview:self.bottomWrapper];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.titleWrapper.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(0, 0, self.titleWrapper.frame.size.width - 20, self.titleLabel.frame.size.height);
    [self.titleLabel setCenterX:self.view.frame.size.width/2];
    
    [self.hintLabel sizeToFit];
    self.hintLabel.frame = CGRectMake(10, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 10, self.view.frame.size.width - 20, self.hintLabel.frame.size.height);
    [self.hintLabel setCenterX:self.view.frame.size.width/2];
    
    [self.titleWrapper setHeight:self.titleLabel.frame.size.height + self.hintLabel.frame.size.height + 35];
    [self.titleWrapper centerSubviewsVertically];
    
    self.bottomWrapper.frame = CGRectMake(0, self.view.frame.size.height - 75, self.view.frame.size.width, 75);
    
    [self.unitsLabel sizeToFit];
    self.unitsLabel.frame = CGRectMake(0, 8, self.view.bounds.size.width, self.unitsLabel.frame.size.height);
    
    self.slider.frame = CGRectMake(0, self.unitsLabel.frame.origin.y + self.unitsLabel.frame.size.height + 5, self.view.bounds.size.width * 0.9, 34);
    [self.slider setCenterX:self.view.frame.size.width/2];
    
    if (isPad()) {
        
        CGFloat aspect = self.imageView.image.size.height/self.imageView.image.size.width;
        self.imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width * 0.92, self.view.bounds.size.width*0.92*aspect);
        self.imageView.center = CGPointMake(self.view.bounds.size.width/2, (self.bottomWrapper.frame.origin.y + CGRectGetMaxY(self.titleWrapper.frame))/2);
    } else {
        
        self.imageView.frame = CGRectMake(0, 0, self.view.bounds.size.width * 0.92, 0);
        [self.imageView setCenterX:self.view.frame.size.width/2];
        [self.imageView setHeight:(self.view.frame.size.height) - (self.titleWrapper.frame.size.height + self.titleWrapper.frame.origin.y) - self.bottomWrapper.frame.size.height - 30];
        [self.imageView setY:self.titleWrapper.frame.size.height + 15];
    }
}

#pragma mark Slider handling
- (void)sliderMoved:(UISlider *)sender
{
    self.unitsLabel.text = [NSString stringWithFormat:@"%d %@", (int)sender.value, self.question.sliderUnit];
    [self calculateIfCorrect];
}

- (void)calculateIfCorrect
{
    if ((int)self.slider.value == self.question.sliderCorrectAnswer) {
        self.question.isCorrect = YES;
    } else {
        self.question.isCorrect = NO;
    }
}

@end
