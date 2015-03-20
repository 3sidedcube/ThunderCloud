//
//  TSCAnimationListItem.m
//  ThunderCloud
//
//  Created by Matthew Cheetham on 20/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCAnimationListItem.h"
#import "TSCAnimationTableViewCell.h"
#import "TSCAnimationFrame.h"

@implementation TSCAnimationListItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    self = [super initWithDictionary:dictionary parentObject:parentObject];
    if (self) {
        
        self.animation = [[TSCAnimation alloc] initWithDictionary:dictionary[@"animation"]];
        
    }
    return self;
}

- (Class)tableViewCellClass
{
    return [TSCAnimationTableViewCell class];
}

- (TSCAnimationTableViewCell *)tableViewCell:(TSCAnimationTableViewCell *)cell
{
    cell.animation = self.animation;
    
    [cell resetAnimations];
    
    return cell;
}

- (CGFloat)tableViewCellHeightConstrainedToContentViewSize:(CGSize)contentViewSize tableViewSize:(CGSize)tableViewSize
{
    TSCAnimationFrame *animationFrame = self.animation.animationFrames.firstObject;
    UIImage *image = animationFrame.image;
    
    if (image) {
        
        CGFloat aspectRatio = image.size.height/image.size.width;
        CGFloat height = aspectRatio*tableViewSize.width;
        
        return height;
    }
    
    return 0;
}

@end
