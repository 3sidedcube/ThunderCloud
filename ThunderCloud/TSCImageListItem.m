//
//  TSCImageListItemView.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCImageListItem.h"

@implementation TSCImageListItem

- (Class)tableViewCellClass
{
    return [TSCTableImageViewCell class];
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
    
    CGFloat aspectRatio = image.size.height/image.size.width;
    CGFloat height = aspectRatio*tableViewSize.width;
    
    return height;
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return NO;
}

@end
