//
//  TSCEmbeddedLinksListInputItemCell.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 29/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCEmbeddedLinksInputCheckItemCell.h"
#import "TSCLink.h"
#import "TSCInlineButtonView.h"
#import "UINavigationController+TSCNavigationController.h"
#import "TSCStormLanguageController.h"

@interface TSCEmbeddedLinksInputCheckItemCell ()

@property NSArray *unavailableLinks;

@end

@implementation TSCEmbeddedLinksInputCheckItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
        if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
            [self setLayoutMargins:UIEdgeInsetsZero];
            self.preservesSuperviewLayoutMargins = NO;
        }
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.links.count < 1) {
        self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, (self.contentView.frame.size.height/2) - (self.textLabel.frame.size.height/2), self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    } else {
        self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 10, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
        self.checkView.frame = CGRectMake(self.checkView.frame.origin.x, self.textLabel.center.y - (self.checkView.frame.size.height/2), self.checkView.frame.size.width, self.checkView.frame.size.height);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [self layoutLinks];
    
    if([[TSCStormLanguageController sharedController] isRightToLeft] && [self isMemberOfClass:[TSCEmbeddedLinksInputCheckItemCell class]]) {
        
        for (UIView *view in self.contentView.subviews) {
            
            //            NSLog(@"View:%@", view);
            view.frame = CGRectMake(self.frame.size.width - view.frame.origin.x - view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
            if([view isKindOfClass:[UILabel class]]) {
                
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
        
        if ([link.url.scheme isEqualToString:@"tel"]) {
            
            NSURL *telephone = [NSURL URLWithString:[link.url.absoluteString stringByReplacingOccurrencesOfString:@"tel" withString:@"telprompt"]];
            
            if (![[UIApplication sharedApplication] canOpenURL:telephone] || isPad()) {
                
                if (self.hideUnavailableLinks) {
                    [sortedLinks removeObjectAtIndex:[links indexOfObject:link]];
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
    
    self.unavailableLinks = unavailableLinks;
    _links = sortedLinks;
}

- (void)setSelected:(BOOL)selected
{
    return;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    return;
}

- (void)layoutLinks {
    
    float buttonY = 22;
    
    //Remove all previous buttons:
    
    for (UIView *subView in self.contentView.subviews) {
        
        if ([subView isKindOfClass:[TSCInlineButtonView class]]) {
            
            [subView removeFromSuperview];
        }
    }
    
    if (self.textLabel.text.length > 0) {
        buttonY = MAX(buttonY, self.textLabel.frame.origin.y + self.textLabel.frame.size.height + 8);
    }
    
    if (self.detailTextLabel.text.length > 0) {
        buttonY = MAX(buttonY, self.detailTextLabel.frame.origin.y + self.detailTextLabel.frame.size.height + 8);
    }
    
    for (TSCLink *link in self.links) {
        
        TSCInlineButtonView *button = [[TSCInlineButtonView alloc] init];
        button.link = link;
        [button setTitle:link.title forState:UIControlStateNormal];
        [button setTitleColor:[[TSCThemeManager sharedTheme] mainColor] forState:UIControlStateNormal];
        button.layer.backgroundColor = [UIColor whiteColor].CGColor;
        button.layer.borderColor = [[TSCThemeManager sharedTheme] mainColor].CGColor;
        button.layer.borderWidth = 1.0f;
        
        if ([self.unavailableLinks containsObject:link]) {
            
            button.layer.borderColor = [[[TSCThemeManager sharedTheme] mainColor] colorWithAlphaComponent:0.2].CGColor;
            [button setTitleColor:[[[TSCThemeManager sharedTheme] mainColor] colorWithAlphaComponent:0.2] forState:UIControlStateNormal];
            button.userInteractionEnabled = false;
        }
        
        
        [button addTarget:self action:@selector(handleEmbeddedLink:) forControlEvents:UIControlEventTouchUpInside];
        
        float x = self.textLabel.frame.origin.x;
        
        if (self.detailTextLabel.frame.origin.x > self.textLabel.frame.origin.x && self.detailTextLabel.text.length > 0) {
            x = self.detailTextLabel.frame.origin.x;
        }
        
        float width = self.contentView.frame.size.width;
        
        if (isPad()) {
            width = width - 70;
        }
        
        button.frame = CGRectMake(x, buttonY, width - 15 - x, 46);
        
        buttonY = buttonY + 60;
        
        [self.contentView addSubview:button];
    }
}

- (void)handleEmbeddedLink:(TSCInlineButtonView *)sender
{
    [self.parentViewController.navigationController pushLink:sender.link];
}

@end
