//
//  TSCStandardListItemView.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCListItem.h"
#import "TSCInlineButtonView.h"
#import "TSCLink.h"
#import "TSCImage.h"
#import "UINavigationController+TSCNavigationController.h"
#import "TSCStormTableViewCell.h"
#import "ThunderCloud/ThunderCloud-Swift.h"
@import ThunderBasics;

@interface TSCListItem ()

@end

@implementation TSCListItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super initWithDictionary:dictionary parentObject:parentObject]) {
        
        self.title = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"title"])];
        self.subtitle = [[TSCStormLanguageController sharedController] stringForDictionary:(dictionary[@"description"])];
        self.link = [[TSCLink alloc] initWithDictionary:dictionary[@"link"]];
        self.image = [TSCImage imageWithJSONObject:dictionary[@"image"]];
    }
    
    return self;
}

- (TSCTableViewCell *)tableViewCell:(TSCTableViewCell *)cell
{
    self.parentNavigationController = cell.parentViewController.navigationController;
    
    if (!self.link) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (Class)tableViewCellClass
{
    return [TSCStormTableViewCell class];
}

- (SEL)rowSelectionSelector
{
    return NSSelectorFromString(@"handleSelection:");
}

- (id)rowSelectionTarget
{
    return [self stormParentObject];
}

- (NSString *)rowTitle
{
    return self.title;
}

- (NSString *)rowSubtitle
{
    return self.subtitle;
}

- (UIImage *)rowImage
{
    return self.image;
}

- (TSCLink *)rowLink
{
    return self.link;
}

- (float)rowPadding
{
    return 12.0;
}

@end
