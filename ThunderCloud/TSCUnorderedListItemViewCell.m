//
//  TSCBulletListItemViewCell.m
//  ThunderCloud
//
//  Created by Phillip Caudell on 09/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCUnorderedListItemViewCell.h"
@import ThunderBasics;

@implementation TSCUnorderedListItemViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.bulletView = [UIView new];
        self.bulletView.backgroundColor = [[TSCThemeManager sharedTheme] mainColor];
        [self.contentView addSubview:self.bulletView];
        self.indentationWidth = 5;
        self.indentationLevel = 1;        
        self.bulletView.layer.cornerRadius = 5;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bulletView.frame = CGRectMake(34, 16, 10, 10);
    
    CGPoint textOffset = CGPointMake(self.bulletView.frame.size.width + self.bulletView.frame.origin.x + 22, 10);
    CGSize constainedSize = CGSizeMake(self.contentView.frame.size.width - textOffset.x - 12, MAXFLOAT);
    
    CGSize textLabelSize = [self.textLabel sizeThatFits:constainedSize];
    CGSize detailTextLabelSize = [self.detailTextLabel sizeThatFits:constainedSize];
    
    self.textLabel.frame = CGRectMake(textOffset.x, textOffset.y, textLabelSize.width, textLabelSize.height);
    self.detailTextLabel.frame = CGRectMake(textOffset.x, self.textLabel.frame.size.height + self.textLabel.frame.origin.y + 5, detailTextLabelSize.width, detailTextLabelSize.height);
    
    [self.bulletView setCenterY:self.textLabel.frame.origin.y + self.textLabel.frame.size.height/2];
    
    if (!self.detailTextLabel.text) {
        [self.textLabel setCenterY:self.contentView.frame.size.height/2];
        [self.bulletView setCenterY:self.contentView.frame.size.height/2];
    }
}

@end
