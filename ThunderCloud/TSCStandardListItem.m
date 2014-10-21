//
//  TSCStandardListItemView.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCStandardListItem.h"
#import "TSCInlineButton.h"
#import "TSCInlineButtonView.h"
#import "TSCLink.h"
#import "TSCImage.h"
#import "UINavigationController+TSCNavigationController.h"

@interface TSCStandardListItem ()

@end

@implementation TSCStandardListItem

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject styler:(TSCStormStyler *)styler
{
    if (self = [super initWithDictionary:dictionary parentObject:parentObject styler:styler]) {
        
        self.title = TSCLanguageDictionary(dictionary[@"title"]);
        self.subtitle = TSCLanguageDictionary(dictionary[@"description"]);
        self.link = [[TSCLink alloc] initWithDictionary:dictionary[@"link"]];
        self.image = [TSCImage imageWithDictionary:dictionary[@"image"]];
    }
    
    return self;
}

- (TSCTableViewCell *)tableViewCell:(TSCTableViewCell *)cell
{
    self.parentNavigationController = cell.parentViewController.navigationController;
    
    return cell;
}

- (Class)tableViewCellClass
{
    return [TSCTableViewCell class];
}

- (SEL)rowSelectionSelector
{
    return NSSelectorFromString(@"handleSelection:");
}

- (id)rowSelectionTarget
{
    return [self stormParentObject];
}

- (NSString *)rowTitle
{
    return self.title;
}

- (NSString *)rowSubtitle
{
    return self.subtitle;
}

- (UIImage *)rowImage
{
    return self.image;
}

- (TSCLink *)rowLink
{
    return self.link;
}

/*

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        
        self.title = TSCLanguageDictionary(dictionary[@"title"]);
        self.subtitle = TSCLanguageDictionary(dictionary[@"description"]);
        self.link = [[TSCLink alloc] initWithDictionary:dictionary[@"link"]];
        self.image = [TSCImage imageWithDictionary:dictionary[@"image"]];
        
        NSMutableArray *array = [NSMutableArray new];
        
        for (NSDictionary *link in dictionary[@"embeddedLinks"]) {
            TSCInlineButton *button = [[TSCInlineButton alloc] initWithDictionary:link];
            [array addObject:button];
        }
        self.buttons = array;
    }
    
    return self;
}

- (TSCTableButtonViewCell *)tableViewCell:(TSCTableButtonViewCell *)cell
{
    self.parentNavigationController = cell.parentViewController.navigationController;
    
//    [cell resetButtonViewsFromButtons:self.buttons];
//    cell.cellDelegate = self;
//    [cell layoutSubviews];
    
    return cell;
}

- (Class)tableViewCellClass
{
    return [TSCTableButtonViewCell class];
}

- (SEL)rowSelectionSelector
{
    return @selector(handleSelection:);
}

- (id)rowSelectionTarget
{
    return self.parentObject;
}

- (NSString *)rowTitle
{
    return self.title;
}

- (NSString *)rowSubtitle
{
    return self.subtitle;
}

- (UIImage *)rowImage
{
    return self.image;
}

- (TSCLink *)rowLink
{
    return self.link;
}

- (BOOL)cellContainsLink
{
    if (self.buttons.count > 0) {
        return NO;
    }
    
    if (self.link.linkClass.length > 0 && ![self.link.linkClass isEqualToString:@"InternalLink"] && ![self.link.linkClass isEqualToString:@"ExternalLink"]) {
        return YES;
    }
    
    if (!self.link.url || self.link.url.absoluteString.length == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)shouldDisplaySelectionCell
{
    return [self cellContainsLink];
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return [self cellContainsLink];
}

#pragma mark - TSCTableViewCellDelegate methods

- (void)button:(TSCInlineButtonView *)button wasTappedInCell:(TSCTableViewCell *)cell
{
    self.link = button.button.link;
    
    if ([self.link.linkClass isEqualToString:@"TimerLink"]) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *timingKey = [NSString stringWithFormat:@"__storm_CountdownTimer_%d", [self.link hash]];
        
        if ([userDefaults boolForKey:timingKey]) return; // Timer already running, do nothing.
        
        [userDefaults setBool:YES forKey:timingKey];
        [userDefaults synchronize];
        
        UIImage *backgroundTrackImage = [[UIImage imageNamed:@"trackImage"] stretchableImageWithLeftCapWidth:5 topCapHeight:6];
        UIImage *completionOverlayImage = [[UIImage imageNamed:@"progress"] stretchableImageWithLeftCapWidth:5 topCapHeight:6];
        
        UIImageView *progressView = [[UIImageView alloc] initWithImage:completionOverlayImage];
        button.layer.masksToBounds = YES;
        [UIView transitionWithView:button duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^ {
            [button setBackgroundImage:backgroundTrackImage forState:UIControlStateNormal];
        } completion:nil];
        
        [button addSubview:progressView];
        [button sendSubviewToBack:progressView];
        
        NSNumber *countdownFrom = self.link.duration;
        
        NSDictionary *initialData = @{@"progressView": progressView, @"button": button, @"timeRemaining": countdownFrom, @"timeLimit": countdownFrom, @"link":self.link, @"button":button};
        
        [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateTimerLink:) userInfo:initialData repeats:NO];

    }
    
    if ([self.parentObject respondsToSelector:@selector(handleSelection:)]) {
        [self.parentNavigationController pushLink:self.link];
    }
}

- (void)updateTimerLink:(NSTimer *)timer
{
    NSDictionary *userData = timer.userInfo;
    
    NSNumber *timeRemaining = [userData objectForKey:@"timeRemaining"];
    NSNumber *timeLimit = [userData objectForKey:@"timeLimit"];
    UIImageView *progressView = [userData objectForKey:@"progressView"];
    TSCInlineButtonView *button = [userData objectForKey:@"button"];
    TSCLink *link = [userData objectForKey:@"link"];
    
    if ([timeRemaining doubleValue] == 0) {
        [timer invalidate];
        timer = nil;
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate date];
        localNotification.alertBody = @"Countdown complete";
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        UIImage *backgroundImage = [[UIImage imageNamed:@"RCEmbeddedLink-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 18, 10, 18)];
        
        [UIView transitionWithView:button duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
            [progressView removeFromSuperview];
            button.titleLabel.text = @"Start timer";
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *timingKey = [NSString stringWithFormat:@"__storm_CountdownTimer_%d", [link hash]];
            
            [userDefaults setBool:NO forKey:timingKey];
            
        } completion:nil];
        return;
    }
    
    int mins = (int)floor([timeRemaining doubleValue] / 60);
    int secs = (int)round([timeRemaining doubleValue] - (mins * 60));
    
    button.titleLabel.text = [NSString stringWithFormat:@"%.2d:%.2d", mins, secs];
    
    CGFloat width = button.frame.size.width * (([timeLimit doubleValue] - [timeRemaining doubleValue]) / [timeLimit doubleValue]);
    
    progressView.frame = CGRectMake(0, 0, width, button.frame.size.height);
    
    timeRemaining = @([timeRemaining doubleValue] - 1);
    
    NSDictionary *data = @{@"progressView":progressView, @"button": button, @"timeRemaining": timeRemaining, @"timeLimit": timeLimit, @"link":link, @"button":button};
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerLink:) userInfo:data repeats:NO];
}

 */

@end
