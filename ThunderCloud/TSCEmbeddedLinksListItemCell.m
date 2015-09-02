//
//  TSCTableButtonViewCell.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 04/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCEmbeddedLinksListItemCell.h"
#import "TSCInlineButtonView.h"
#import "TSCEmbeddedLinksListItem.h"
#import "UINavigationController+TSCNavigationController.h"
#import "TSCLink.h"
#import "TSCStormLanguageController.h"

@interface TSCEmbeddedLinksListItemCell ()

@property NSArray *unavailableLinks;

@end

@implementation TSCEmbeddedLinksListItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.hideUnavailableLinks = false;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.links.count > 0) {
        float textLabelWidth = self.bounds.size.width - 30;
        float detailTextLabelWidth = self.bounds.size.width - 30 - self.imageView.frame.size.width;
        
        if (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
            textLabelWidth = self.bounds.size.width - self.imageView.frame.size.width - 60;
            detailTextLabelWidth = self.bounds.size.width - self.imageView.frame.size.width - 60;
        }
        
        self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 12, textLabelWidth, self.textLabel.frame.size.height);
        
        float detailTextLabelY = 12;
        
        if (self.textLabel.text.length > 0) {
            detailTextLabelY = self.textLabel.frame.origin.y + self.textLabel.frame.size.height + 4;
        }
        
        self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x, detailTextLabelY, detailTextLabelWidth, self.detailTextLabel.frame.size.height);
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [self layoutLinks];

    if([[TSCStormLanguageController sharedController] isRightToLeft] && [self isMemberOfClass:[TSCEmbeddedLinksListItemCell class]]) {
        
        for (UIView *view in self.contentView.subviews) {
            
            if([view isKindOfClass:[UILabel class]]) {
                
                if (self.imageView.image) {
                    
                    view.frame = CGRectMake(self.frame.size.width - view.frame.origin.x - view.frame.size.width + 20, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                    
                } else {
                    
                    if (self.accessoryType != UITableViewCellAccessoryNone) {
                        
                        view.frame = CGRectMake(self.frame.size.width - view.frame.origin.x - view.frame.size.width - 20, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                        
                    } else {
                        
                        view.frame = CGRectMake(self.frame.size.width - view.frame.origin.x - view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                        
                    }
                    
                }
                
                ((UILabel *)view).textAlignment = NSTextAlignmentRight;

            }
            
        }
        
    }
    
}

- (void)setLinks:(NSArray *)links
{
    NSMutableArray *sortedLinks = [NSMutableArray arrayWithArray:links];
    NSMutableArray *unavailableLinks = [NSMutableArray array];
    
    for (TSCLink *link in links) {
        
        if ([link isKindOfClass:[TSCLink class]]) {
            
            if ([link.url.scheme isEqualToString:@"tel"]) {
                
                NSURL *telephone = [NSURL URLWithString:[link.url.absoluteString stringByReplacingOccurrencesOfString:@"tel" withString:@"telprompt"]];
                
                if (![[UIApplication sharedApplication] canOpenURL:telephone] || isPad()) {
                    
                    if (self.hideUnavailableLinks) {
                        [sortedLinks removeObjectAtIndex:[sortedLinks indexOfObject:link]];
                    } else {
                        [unavailableLinks addObject:link];
                    }
                }
            }
            
            if ([link.linkClass isEqualToString:@"EmergencyLink"]) {
                
                NSString *emergencyNumber = [[NSUserDefaults standardUserDefaults] stringForKey:@"emergency_number"];
                NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", emergencyNumber]];
                
                if (![[UIApplication sharedApplication] canOpenURL:telURL] || isPad()) {
                    
                    if (self.hideUnavailableLinks) {
                        [sortedLinks removeObjectAtIndex:[links indexOfObject:link]];
                    } else {
                        [unavailableLinks addObject:link];
                    }
                }
            }
        }
    }
    
    self.unavailableLinks = unavailableLinks;
    _links = sortedLinks;
}

- (void)layoutLinks {
    
    float buttonY = 12;
    
    float buttonOffset = 15;
    
    //Remove all previous buttons:
    
    for (UIView *subView in self.contentView.subviews) {
        
        if ([subView isKindOfClass:[TSCInlineButtonView class]]) {
            
            [subView removeFromSuperview];
        }
    }
    
    if (self.textLabel.text.length > 0) {
        buttonY = MAX(buttonY, self.textLabel.frame.origin.y + self.textLabel.frame.size.height + buttonOffset);
    }
    
    if (self.detailTextLabel.text.length > 0) {
        buttonY = MAX(buttonY, self.detailTextLabel.frame.origin.y + self.detailTextLabel.frame.size.height + buttonOffset);
    }
    
    for (id obj in self.links) {
        
        TSCLink *link;
        UIButton *embeddedButton;
        
        if ([obj isKindOfClass:[TSCLink class]]) {
            link = (TSCLink *)obj;
        } else if ([obj isKindOfClass:[UIButton class]]) {
            embeddedButton = (UIButton *)obj;
        }
        
        TSCInlineButtonView *button = [[TSCInlineButtonView alloc] init];
        
        if (link) {
            
            button.link = link;
            [button setTitle:link.title forState:UIControlStateNormal];
        } else if (embeddedButton) {
            
            for (id target in embeddedButton.allTargets) {
                
                NSArray *actions = [embeddedButton actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
                
                for (NSString *action in actions) {
                    [button addTarget:target action:NSSelectorFromString(action) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            
            [button setTitle:[embeddedButton titleForState:UIControlStateNormal] forState:UIControlStateNormal];
        }
        
        [button setTitleColor:[[TSCThemeManager sharedTheme] mainColor] forState:UIControlStateNormal];
        button.layer.borderColor = [[TSCThemeManager sharedTheme] mainColor].CGColor;
        button.layer.borderWidth = 1.0f;
        
        if ([self.unavailableLinks containsObject:link]) {
            
            button.layer.borderColor = [[[TSCThemeManager sharedTheme] mainColor] colorWithAlphaComponent:0.2].CGColor;
            [button setTitleColor:[[[TSCThemeManager sharedTheme] mainColor] colorWithAlphaComponent:0.2] forState:UIControlStateNormal];
            button.userInteractionEnabled = false;
        }
        
        if (self.target && self.selector && !embeddedButton) {
            [button addTarget:self.target action:self.selector forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button addTarget:self action:@selector(handleEmbeddedLink:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        float x = self.textLabel.frame.origin.x;
        
        if (self.detailTextLabel.frame.origin.x > self.textLabel.frame.origin.x && self.detailTextLabel.text.length > 0) {
            x = self.detailTextLabel.frame.origin.x;
        }
        
        if (x == 0) {
            x = 15;
        }
        
        float width = self.contentView.frame.size.width;
        
        if (isPad()) {
            x = 13;
        }
        
        button.frame = CGRectMake(x, buttonY, width - 15 - x, 46);
        buttonY = buttonY + 60;
        
        [self.contentView addSubview:button];
    }
}

- (void)handleEmbeddedLink:(TSCInlineButtonView *)sender
{
    if ([sender.link.linkClass isEqualToString:@"TimerLink"]) {
        
        [self handleTimerLinkWithButtonView:sender];
        return;
    }
    
    [self.parentViewController.navigationController pushLink:sender.link];
}

#pragma mark - Timer Link Handling

- (void)handleTimerLinkWithButtonView:(TSCInlineButtonView *)sender
{
    //Setup defaults for monitoring timing
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *timingKey = [NSString stringWithFormat:@"__storm_CountdownTimer_%lu", (unsigned long)[sender.link hash]];
    
    //Check if timer is already running
    if ([userDefaults boolForKey:timingKey]) {
        
        //Already running
        return;
    }
    
    //Set the timer as running in the defaults
    [userDefaults setBool:YES forKey:timingKey];
    [userDefaults synchronize];
    
    UIImage *backgroundTrackImage = [[UIImage imageNamed:@"trackImage" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] stretchableImageWithLeftCapWidth:5 topCapHeight:6];
    UIImage *completionOverlayImage = [[UIImage imageNamed:@"progress" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] stretchableImageWithLeftCapWidth:5 topCapHeight:6];
    
    UIImageView *progressView = [[UIImageView alloc] initWithImage:completionOverlayImage];
    sender.layer.masksToBounds = YES;
    [UIView transitionWithView:sender duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^ {
        [sender setBackgroundImage:backgroundTrackImage forState:UIControlStateNormal];
    } completion:nil];
    
    [sender addSubview:progressView];
    [sender sendSubviewToBack:progressView];
    
    NSNumber *countdownFrom = sender.link.duration;
    
    NSDictionary *initialData = @{@"progressView": progressView, @"button": sender, @"timeRemaining": countdownFrom, @"timeLimit": countdownFrom, @"link":sender.link, @"button":sender};
    
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateTimerLink:) userInfo:initialData repeats:NO];
}

- (void)updateTimerLink:(NSTimer *)timer
{
    //Retrieve user data from the timer
    NSDictionary *userData = timer.userInfo;
    
    NSNumber *timeRemaining = [userData objectForKey:@"timeRemaining"];
    NSNumber *timeLimit = [userData objectForKey:@"timeLimit"];
    UIImageView *progressView = [userData objectForKey:@"progressView"];
    TSCInlineButtonView *button = [userData objectForKey:@"button"];
    TSCLink *link = [userData objectForKey:@"link"];
    
    //Time has expired
    if ([timeRemaining isEqualToNumber:@(0)]) {
        
        [button setTitleColor:[UIColor colorWithCGColor:button.layer.borderColor] forState:UIControlStateNormal];
        [timer invalidate];
        timer = nil;
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = @"Countdown complete";
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        
        [UIView transitionWithView:button duration:0.15 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [progressView removeFromSuperview];
            
            [button setTitle:@"Start timer" forState:UIControlStateNormal];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *timingKey = [NSString stringWithFormat:@"__storm_CountdownTimer_%lu", (unsigned long)[link hash]];
            
            [userDefaults setBool:NO forKey:timingKey];
            
        } completion:nil];
        
        return;
    }
    
    //Update progress of track image
    int mins = (int)floor([timeRemaining doubleValue] / 60);
    int secs = (int)round([timeRemaining doubleValue] - (mins * 60));
    
    [button setTitle:[NSString stringWithFormat:@"%.2d:%.2d", mins, secs] forState:UIControlStateNormal];
    
    CGFloat width = button.frame.size.width * (([timeLimit doubleValue] - [timeRemaining doubleValue]) / [timeLimit doubleValue]);
    
    progressView.frame = CGRectMake(0, 0, width, button.frame.size.height);
    
    if(width >= button.titleLabel.frame.origin.x) {
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    timeRemaining = @([timeRemaining doubleValue] - 1);
    
    NSDictionary *data = @{@"progressView":progressView, @"button": button, @"timeRemaining": timeRemaining, @"timeLimit": timeLimit, @"link":link, @"button":button};
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimerLink:) userInfo:data repeats:NO];
}

@end
