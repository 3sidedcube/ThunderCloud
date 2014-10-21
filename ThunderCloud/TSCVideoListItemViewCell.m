//
//  TSCVideoListItemViewCell.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 21/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCVideoListItemViewCell.h"
#import "TSCAnnularPlayButton.h"

@interface TSCVideoListItemViewCell ()

@property (nonatomic, strong) UILabel *durationLabel;

@property (nonatomic, strong) UIImageView *gradientImageView;

@end

@implementation TSCVideoListItemViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        self.playButton = [[TSCAnnularPlayButton alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        
        self.durationLabel = [[UILabel alloc] init];
        self.durationLabel.textColor = [UIColor whiteColor];
        self.durationLabel.font = [UIFont systemFontOfSize:16];
        self.durationLabel.textAlignment = NSTextAlignmentRight;
        self.durationLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.durationLabel];
        
        self.gradientImageView = [[UIImageView alloc] init];
        self.gradientImageView.image = [UIImage imageNamed:@"NameLabel-bg"];
        [self.contentView addSubview:self.gradientImageView];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.imageView addSubview:self.playButton];
    [self.imageView bringSubviewToFront:self.playButton];
    self.playButton.center = self.contentView.center;
    self.playButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.playButton startAnimationWithDelay:0.2];
    
    float durationLabelInset = 5;
    
    if (![TSCThemeManager isOS7]) {
        durationLabelInset = 15;
    }
    
    if (self.duration > 0) {
        [self.contentView addSubview:self.textLabel];
        [self.contentView addSubview:self.durationLabel];
        self.durationLabel.frame = CGRectMake(durationLabelInset, self.frame.size.height - 24, self.frame.size.width - (durationLabelInset * 2), 20);
        self.gradientImageView.frame = CGRectMake(0, self.frame.size.height - 53, self.frame.size.width, 53);
        
        [self.contentView bringSubviewToFront:self.textLabel];
        [self.contentView bringSubviewToFront:self.gradientImageView];
    } else {
        [self.textLabel removeFromSuperview];
        [self.gradientImageView removeFromSuperview];
    }
}

- (void)setupDurationLabelText
{
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:self.duration sinceDate:date1];
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit;
    
    NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
    
    NSUInteger minute = [breakdownInfo minute];
    NSUInteger second = [breakdownInfo second];
    
    NSString *timeString = @"";
    /*
    if (hoursIncluded) {
        NSString *hoursString = [timeString stringByAppendingFormat:@"%i", (int)hour];
        if (hoursString.length == 1) {
            hoursString = [NSString stringWithFormat:@"0%@", hoursString];
        }
        
        timeString = [timeString stringByAppendingFormat:@"%@:", hoursString];
    }*/
    
    NSString *minutesString = [NSString stringWithFormat:@"%i", (int)minute];
    
    if (minutesString.length == 1) {
        minutesString = [NSString stringWithFormat:@"0%@", minutesString];
    }
    
    timeString = [timeString stringByAppendingFormat:@"%@:", minutesString];
    
    NSString *secondsString = [NSString stringWithFormat:@"%i", (int)second];
    
    if (secondsString.length == 1) {
        secondsString = [NSString stringWithFormat:@"0%@", secondsString];
    }
    
    timeString = [timeString stringByAppendingFormat:@"%@", secondsString];
    
    self.durationLabel.text = timeString;

}

- (void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
    
    [self setupDurationLabelText];
}

@end
