//
//  TSCImageListItemView.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCImageListItemView.h"

@implementation TSCImageListItemView

- (Class)tableViewCellClass
{
    return [TSCTableImageViewCell class];
}

- (UIImage *)rowImage
{
    UIImage *image = [super rowImage];
    
    if (!image) {
        image = [UIImage imageNamed:@"transparent"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeTile];
    }
    
    return image;
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
