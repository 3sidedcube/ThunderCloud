//
//  TSCStormTableViewCell.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/01/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

#import "TSCStormTableViewCell.h"

@implementation TSCStormTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.cellDetailTextLabel.text && ![[self.cellDetailTextLabel.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        
        // Center labels
        CGRect textLabelFrame = self.cellTextLabel.frame;
        CGRect detailLabelFrame = self.cellDetailTextLabel.frame;
        
        // The required compound rect of both the text + detail text labels
        CGRect compoundRect = CGRectMake(textLabelFrame.origin.x, 0, textLabelFrame.size.width, CGRectGetMaxY(detailLabelFrame) - CGRectGetMinY(textLabelFrame));
        compoundRect.origin.y = self.contentView.frame.size.height / 2 - compoundRect.size.height / 2;
        
        textLabelFrame.origin.y = compoundRect.origin.y;
        detailLabelFrame.origin.y = CGRectGetMaxY(textLabelFrame);
        
        self.cellTextLabel.frame = textLabelFrame;
        self.cellDetailTextLabel.frame = detailLabelFrame;
    }

}

@end
