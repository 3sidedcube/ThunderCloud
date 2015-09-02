//
//  TSCAnimatedImageListItemView.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 29/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCAnimatedImageListItem.h"
#import "TSCImage.h"

@interface TSCImageListItem ()

@end

@implementation TSCAnimatedImageListItem

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super initWithDictionary:dictionary parentObject:parentObject]) {
        
        self.images = [NSMutableArray array];
        self.delays = [NSMutableArray array];
        
        for (NSDictionary *animatedImageDictionary in dictionary[@"images"]) {
            UIImage *animationImage = [TSCImage imageWithJSONObject:animatedImageDictionary];
            
            if (animationImage) {
                [self.images addObject:animationImage];
            }
            
            [self.delays addObject:[NSNumber numberWithInteger:[animatedImageDictionary[@"delay"] integerValue]]];
        }
    }
    
    return self;
}

- (UIImage *)rowImage
{
    return [self.images firstObject];
}

- (Class)tableViewCellClass
{
    return [TSCAnimatedTableImageViewCell class];
}

- (TSCAnimatedTableImageViewCell *)tableViewCell:(TSCAnimatedTableImageViewCell *)cell
{
    cell.images = self.images;
    cell.delays = self.delays;
    [cell resetAnimations];
    
    return cell;
}

- (CGFloat)tableViewCellHeightConstrainedToContentViewSize:(CGSize)contentViewSize tableViewSize:(CGSize)tableViewSize
{
    UIImage *image = [[self images] firstObject];
    
    if (image) {
        
        CGFloat aspectRatio = image.size.height/image.size.width;
        CGFloat height = aspectRatio*tableViewSize.width;
        
        return height;
    }
    
    return 0;
}

@end