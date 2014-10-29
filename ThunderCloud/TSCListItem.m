//
//  TSCStandardListItemView.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCListItem.h"
#import "TSCInlineButton.h"
#import "TSCInlineButtonView.h"
#import "TSCLink.h"
#import "TSCImage.h"
#import "UINavigationController+TSCNavigationController.h"

@interface TSCListItem ()

@end

@implementation TSCListItem

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject styler:(TSCStormStyler *)styler
{
    if (self = [super initWithDictionary:dictionary parentObject:parentObject styler:styler]) {
        
        self.title = TSCLanguageDictionary(dictionary[@"title"]);
        self.subtitle = TSCLanguageDictionary(dictionary[@"description"]);
        self.link = [[TSCLink alloc] initWithDictionary:dictionary[@"link"]];
        self.image = [TSCImage imageWithDictionary:dictionary[@"image"]];
    }
    
    return self;
}

- (TSCTableViewCell *)tableViewCell:(TSCTableViewCell *)cell
{
    self.parentNavigationController = cell.parentViewController.navigationController;
    
    return cell;
}

- (Class)tableViewCellClass
{
    return [TSCTableViewCell class];
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

@end
