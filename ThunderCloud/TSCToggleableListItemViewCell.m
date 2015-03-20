//
//  TSCToggleableListItemViewCell.m
//  ThunderStorm
//
//  Created by Simon Mitchell on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCToggleableListItemViewCell.h"
#import "TSCStormLanguageController.h"

#define TEXT_LIST_ITEM_VIEW_TEXT_INSET 16

@interface TSCToggleableListItemViewCell ()

@property (nonatomic, copy) NSString *detailsText;
@property UIButton *toggleButton;
@property UIView *toggleContainerView;

@end

@implementation TSCToggleableListItemViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        
        self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.toggleButton.frame = CGRectMake(0, 0, 16, 11);
        
        self.toggleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 14, 11, self.frame.size.height - 28)];
        [self.toggleContainerView addSubview:self.toggleButton];
        
        [self.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.accessoryView = self.toggleContainerView;
    self.toggleContainerView.frame = CGRectMake(self.toggleContainerView.frame.origin.x, self.toggleContainerView.frame.origin.y, self.toggleContainerView.frame.size.width, self.frame.size.height - 28);
    
    CGSize size = [self.detailTextLabel sizeThatFits:CGSizeMake(self.frame.size.width - (TEXT_LIST_ITEM_VIEW_TEXT_INSET * 2), MAXFLOAT)];
    
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 10, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    
    if (self.isFullyVisible) {
        self.detailTextLabel.frame = CGRectMake(TEXT_LIST_ITEM_VIEW_TEXT_INSET, self.textLabel.frame.size.height + self.textLabel.frame.origin.y, self.frame.size.width - (TEXT_LIST_ITEM_VIEW_TEXT_INSET * 2), size.height + TEXT_LIST_ITEM_VIEW_TEXT_INSET);
    }
    
    if ([[TSCStormLanguageController sharedController] isRightToLeft] && [self isMemberOfClass:[TSCToggleableListItemViewCell class]]) {
        
        for (UIView *view in self.contentView.subviews) {
            
            view.frame = CGRectMake(self.frame.size.width - view.frame.origin.x - view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
            
            if ([view isKindOfClass:[UILabel class]]) {
                
                ((UILabel *)view).textAlignment = NSTextAlignmentRight;
            }
        }
        
        self.accessoryView.frame = CGRectMake(self.frame.size.width - self.accessoryView.frame.origin.x - self.accessoryView.frame.size.width, self.accessoryView.frame.origin.y, self.accessoryView.frame.size.width, self.accessoryView.frame.size.height);
    }
}

- (void)setIsFullyVisible:(BOOL)isFullyVisible
{
    _isFullyVisible = isFullyVisible;
    if (!_isFullyVisible) {
        
        self.detailTextLabel.text = @"";
        [self.toggleButton setImage:[UIImage imageNamed:@"chevron-down" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    } else {
        [self.toggleButton setImage:[UIImage imageNamed:@"chevron-up" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    }
}

@end
