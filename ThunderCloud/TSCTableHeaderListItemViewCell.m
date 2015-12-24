//
//  TSCTableHeaderListItemViewCell.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 28/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCTableHeaderListItemViewCell.h"

@interface TSCTableHeaderListItemViewCell ()

@property (nonatomic, strong) UIView *darkOverlay;

@end

@implementation TSCTableHeaderListItemViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.cellTextLabel.font = [[TSCThemeManager sharedTheme] fontOfSize:36];
        self.cellTextLabel.numberOfLines = 0;
        self.cellTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.cellTextLabel.textAlignment = NSTextAlignmentCenter;
        
        self.cellDetailTextLabel.font = [[TSCThemeManager sharedTheme] fontOfSize:15];
        self.cellDetailTextLabel.numberOfLines = 0;
        self.cellDetailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.cellDetailTextLabel.textAlignment = NSTextAlignmentCenter;
        
        self.darkOverlay = [UIView new];
        self.darkOverlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        [self.contentView addSubview:self.darkOverlay];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView addSubview:self.darkOverlay];
    [self.contentView bringSubviewToFront:self.cellTextLabel];
    [self.contentView bringSubviewToFront:self.cellDetailTextLabel];
    
    self.darkOverlay.frame = self.contentView.bounds;
    
    CGSize constrainedSize = CGSizeMake(self.contentView.frame.size.width - 40, self.contentView.frame.size.height - 20);
    
    CGSize textLabelSize = [self.cellTextLabel sizeThatFits:self.contentView.frame.size];
    CGSize detailTextLabelSize = [self.cellDetailTextLabel sizeThatFits:CGSizeMake(constrainedSize.width, constrainedSize.height - textLabelSize.height - 10)];
    
    CGFloat totalHeight = textLabelSize.height + 10 + detailTextLabelSize.height;
    
    self.cellTextLabel.frame = CGRectMake(self.contentView.frame.size.width/2 - textLabelSize.width/2, self.contentView.frame.size.height/2 - totalHeight/2, textLabelSize.width, textLabelSize.height);
    self.cellDetailTextLabel.frame = CGRectMake(self.contentView.frame.size.width/2 - detailTextLabelSize.width/2, self.cellTextLabel.frame.origin.y + self.cellTextLabel.frame.size.height + 10, detailTextLabelSize.width, detailTextLabelSize.height);
}

@end
