//
//  TSCHeaderListItem.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 28/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCHeaderListItem.h"
#import "TSCTableHeaderListItemViewCell.h"

@implementation TSCHeaderListItem

- (Class)tableViewCellClass
{
    return [TSCTableHeaderListItemViewCell class];
}

- (UIImage *)rowImage
{
    UIImage *image = [super rowImage];
    
    if (!image) {
        image = [UIImage imageNamed:@"transparent" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
    }
    
    return image;
}

- (NSString *)rowTitle
{
    return self.title;
}

- (NSString *)rowSubtitle
{
    return self.subtitle;
}

- (TSCTableViewCell *)tableViewCell:(TSCTableViewCell *)cell
{
    cell = (TSCTableViewCell *)[super tableViewCell:cell];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.layer.masksToBounds = YES;
    
    return cell;
}

- (BOOL)shouldDisplaySelectionCell
{
    return NO;
}

- (CGFloat)tableViewCellHeightConstrainedToContentViewSize:(CGSize)contentViewSize tableViewSize:(CGSize)tableViewSize
{
    UIImage *image = [self rowImage];
    
    return image.size.height;
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return NO;
}


@end
