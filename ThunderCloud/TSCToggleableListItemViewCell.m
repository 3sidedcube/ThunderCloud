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
        
        self.toggleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 14, 16, 11)];
        [self.toggleContainerView addSubview:self.toggleButton];
        
<<<<<<< ours
        [self.cellDetailTextLabel setFont:[[TSCThemeManager sharedTheme] detailLabelFont]];
=======
        [self.contentView addSubview:self.toggleContainerView];
        
        [self.cellDetailTextLabel setFont:[UIFont systemFontOfSize:14]];
>>>>>>> theirs
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.accessoryView = self.toggleContainerView;
    
    float rightSideInset = 20.0;
    float topSideInset = 15.0;
    
    CGSize cellLabelSize = [self.cellTextLabel sizeThatFits:CGSizeMake(self.frame.size.width - (TEXT_LIST_ITEM_VIEW_TEXT_INSET * 2) - rightSideInset - 5, MAXFLOAT)];

    CGSize cellDetailLabelSize = [self.cellDetailTextLabel sizeThatFits:CGSizeMake(self.frame.size.width - (TEXT_LIST_ITEM_VIEW_TEXT_INSET * 2), MAXFLOAT)];
    
    self.toggleContainerView.frame = CGRectMake(self.contentView.frame.size.width - self.toggleContainerView.frame.size.width - rightSideInset, topSideInset, 16, 11);
    
    self.cellTextLabel.frame = CGRectMake(TEXT_LIST_ITEM_VIEW_TEXT_INSET, 10, cellLabelSize.width, cellLabelSize.height);
    
    if (self.isFullyVisible) {
        self.cellDetailTextLabel.frame = CGRectMake(TEXT_LIST_ITEM_VIEW_TEXT_INSET, self.cellTextLabel.frame.size.height + self.cellTextLabel.frame.origin.y, cellDetailLabelSize.width, cellDetailLabelSize.height + 10);
    }
    
    if ([[TSCStormLanguageController sharedController] isRightToLeft] && [self isMemberOfClass:[TSCToggleableListItemViewCell class]]) {
        
        for (UIView *view in self.contentView.subviews) {
            
            view.frame = CGRectMake(self.frame.size.width - view.frame.origin.x - view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
            
            if ([view isKindOfClass:[UILabel class]]) {
                
                ((UILabel *)view).textAlignment = NSTextAlignmentRight;
            }
        }
        
        self.toggleContainerView.frame = CGRectMake(self.frame.size.width - self.toggleContainerView.frame.origin.x - self.toggleContainerView.frame.size.width, self.toggleContainerView.frame.origin.y, self.toggleContainerView.frame.size.width, self.toggleContainerView.frame.size.height);
    }
}

- (void)setIsFullyVisible:(BOOL)isFullyVisible
{
    _isFullyVisible = isFullyVisible;
    if (!_isFullyVisible) {
        
        self.cellDetailTextLabel.text = @"";
        [self.toggleButton setImage:[UIImage imageNamed:@"chevron-down" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    } else {
        [self.toggleButton setImage:[UIImage imageNamed:@"chevron-up" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    }
}

@end
