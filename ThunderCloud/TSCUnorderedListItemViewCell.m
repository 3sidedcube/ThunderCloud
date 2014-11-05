//
//  TSCBulletListItemViewCell.m
//  ThunderCloud
//
//  Created by Phillip Caudell on 09/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCUnorderedListItemViewCell.h"

@implementation TSCUnorderedListItemViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.bulletView = [UIView new];
        self.bulletView.backgroundColor = [[TSCThemeManager sharedTheme] mainColor];
        [self.contentView addSubview:self.bulletView];
        self.indentationWidth = 5;
        self.indentationLevel = 1;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bulletView.frame = CGRectMake(15, 5, 5, self.contentView.bounds.size.height - 10);
    self.textLabel.frame = CGRectMake(self.bulletView.frame.origin.x + self.bulletView.frame.size.width + 12, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
    self.detailTextLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.detailTextLabel.frame.origin.y, self.detailTextLabel.frame.size.width, self.detailTextLabel.frame.size.height);
}

@end
