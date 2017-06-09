//
//  TSCLogoListItemView.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCLogoListItem.h"
#import "TSCLogoListItemViewCell.h"
#import "ThunderCloud/ThunderCloud-Swift.h"

@import ThunderBasics;

@implementation TSCLogoListItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super initWithDictionary:dictionary parentObject:parentObject]) {
        
        if (dictionary[@"link"] && [dictionary[@"link"] isKindOfClass:[NSDictionary class]]) {
            self.title = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"link"][@"title"])];
        }
    }
    
    return self;
}

- (NSString *)rowTitle
{
    return self.title;
}

#pragma mark Row data source

- (Class)tableViewCellClass
{
    return [TSCLogoListItemViewCell class];
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell
{
    TSCLogoListItemViewCell *logoCell = (TSCLogoListItemViewCell *)cell;
    
    return logoCell;
}

- (CGFloat)tableViewCellHeightConstrainedToSize:(CGSize)contrainedSize;
{
    
    UIImage *image = [self rowImage];
    
    if (image) {
        
        CGFloat aspectRatio = image.size.height/image.size.width;
        CGFloat height = aspectRatio*MIN(contrainedSize.width-30,image.size.width);
        
        return height + 52;
    }
    
    return 32;
}

- (BOOL)shouldDisplaySeperator
{
    return NO;
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return NO;
}

@end
