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
        self.bulletView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.bulletView];
        self.indentationWidth = 5;
        self.indentationLevel = 1;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bulletView.frame = CGRectMake(5, 5, 5, self.contentView.bounds.size.height - 10);
}

@end
