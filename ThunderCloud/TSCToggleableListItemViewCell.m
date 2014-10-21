//
//  TSCToggleableListItemViewCell.m
//  ThunderStorm
//
//  Created by Andrew Hart on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCToggleableListItemViewCell.h"

@interface TSCToggleableListItemViewCell ()

@property (nonatomic, strong) NSString *detailsText;

@end

@implementation TSCToggleableListItemViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
    }
    
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    UIView *sampleFrame = [[UIView alloc] initWithFrame:CGRectMake(-10, 15, 30, 30)];
    
    CGPoint textOffset = CGPointMake(sampleFrame.frame.size.width + sampleFrame.frame.origin.x, sampleFrame.frame.origin.y);
    CGSize textConstrainedSize = CGSizeMake(self.contentView.frame.size.width - textOffset.x - 10, MAXFLOAT);
    
    CGSize textLabelSize = [self.textLabel sizeThatFits:textConstrainedSize];
    CGSize detailLabelSize = [self.detailTextLabel sizeThatFits:textConstrainedSize];
    
    if([TSCThemeManager localisedTextDirectionForBaseDirection:NSTextAlignmentLeft] == NSTextAlignmentRight){
        
        self.textLabel.frame = CGRectMake(self.frame.size.width - textLabelSize.width - 15, textOffset.y - 8, textLabelSize.width, textLabelSize.height + 16);
        self.detailTextLabel.frame = CGRectMake(self.frame.size.width - detailLabelSize.width - 15, self.textLabel.frame.size.height + self.textLabel.frame.origin.y, detailLabelSize.width, detailLabelSize.height + 16);
        
    } else {
        
        self.textLabel.frame = CGRectMake(textOffset.x, textOffset.y - 8, textLabelSize.width, textLabelSize.height + 16);
        self.detailTextLabel.frame = CGRectMake(textOffset.x, self.textLabel.frame.size.height + self.textLabel.frame.origin.y, detailLabelSize.width, detailLabelSize.height + 16);
        
    }
    
    [self.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
}

@end
