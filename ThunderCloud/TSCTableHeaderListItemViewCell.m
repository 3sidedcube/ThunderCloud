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
        
        self.textLabel.font = [UIFont systemFontOfSize:36];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:15];
        self.detailTextLabel.textColor = [UIColor whiteColor];
        self.detailTextLabel.numberOfLines = 0;
        self.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
        
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
    [self.contentView bringSubviewToFront:self.textLabel];
    [self.contentView bringSubviewToFront:self.detailTextLabel];
    
    self.darkOverlay.frame = self.contentView.bounds;
    
    CGSize constrainedSize = CGSizeMake(self.contentView.frame.size.width - 40, self.contentView.frame.size.height - 20);
    
    CGSize textLabelSize = [self.textLabel sizeThatFits:self.contentView.frame.size];
    CGSize detailTextLabelSize = [self.detailTextLabel sizeThatFits:CGSizeMake(constrainedSize.width, constrainedSize.height - textLabelSize.height - 10)];
    
    CGFloat totalHeight = textLabelSize.height + 10 + detailTextLabelSize.height;

    self.textLabel.frame = CGRectMake(self.contentView.frame.size.width/2 - textLabelSize.width/2, self.contentView.frame.size.height/2 - totalHeight/2, textLabelSize.width, textLabelSize.height);
    self.detailTextLabel.frame = CGRectMake(self.contentView.frame.size.width/2 - detailTextLabelSize.width/2, self.textLabel.frame.origin.y + self.textLabel.frame.size.height + 10, detailTextLabelSize.width, detailTextLabelSize.height);
    
}

@end
