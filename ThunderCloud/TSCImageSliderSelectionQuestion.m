//
//  TSCImageSliderSelectionQuestion.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCImageSliderSelectionQuestion.h"
#import "TSCQuizQuestion.h"
#import "TSCImage.h"

@interface TSCImageSliderSelectionQuestion ()

@end

@implementation TSCImageSliderSelectionQuestion

- (id)initWithQuestion:(TSCQuizQuestion *)question
{
    self = [super init];
    
    if (self) {
        
        self.question = question;
        
        // TITLE ---
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = self.question.questionText;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        self.titleLabel.numberOfLines = 0;
        
        // IMAGE --
        self.imageView = [[UIImageView alloc] initWithImage:[TSCImage imageWithDictionary:self.question.image]];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = YES;
        
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
        
        self.unitsLabel.text = [NSString stringWithFormat:@"%d %@", (int)self.slider.value, self.question.sliderUnit];
        
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
    
    [self.view addSubview:self.slider];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.unitsLabel];
    [self.view addSubview:self.hintLabel];
    [self.view addSubview:self.titleLabel];}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.titleLabel.frame = CGRectMake(10, 10, self.view.bounds.size.width - 20, 100);
    
    [self.unitsLabel sizeToFit];
    self.unitsLabel.frame = CGRectMake(0, self.view.bounds.origin.y + self.view.bounds.size.height - 110, self.view.bounds.size.width, self.unitsLabel.frame.size.height);
    
    self.slider.frame = CGRectMake((self.view.bounds.size.width * 0.33f) / 2, self.unitsLabel.frame.origin.y + self.unitsLabel.frame.size.height + 5, self.view.bounds.size.width * 0.66f, 34);
    
    self.imageView.frame = CGRectMake(0, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - (self.view.bounds.size.height - self.unitsLabel.frame.origin.y) - self.titleLabel.frame.size.height - 20);
    
    [self.hintLabel sizeToFit];
    self.hintLabel.frame = CGRectMake(self.slider.frame.origin.x + (self.slider.frame.size.width / 2) - (self.hintLabel.frame.size.width / 2), self.slider.frame.origin.y + self.slider.frame.size.height + 5, self.hintLabel.frame.size.width, self.hintLabel.frame.size.height);
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
