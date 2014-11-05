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
        self.checkView.frame = CGRectMake(self.checkView.frame.origin.x, self.textLabel.center.y - (self.checkView.frame.size.height/2), self.checkView.frame.size.width, self.checkView.frame.size.height);
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [self layoutLinks];
}

- (void)setLinks:(NSArray *)links
{
    _links = links;
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
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.backgroundColor = [[TSCThemeManager sharedTheme] mainColor].CGColor;
        
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
