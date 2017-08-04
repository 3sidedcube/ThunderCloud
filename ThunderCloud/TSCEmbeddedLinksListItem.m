//
//  TSCEmbeddedLinksListItem.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 28/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCEmbeddedLinksListItem.h"
#import "TSCLink.h"
#import "UINavigationController+TSCNavigationController.h"

@interface TSCEmbeddedLinksListItem ()

@end

@implementation TSCEmbeddedLinksListItem

- (Class)tableViewCellClass
{
    return [TSCEmbeddedLinksListItemCell class];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super initWithDictionary:dictionary parentObject:parentObject]) {
        
        NSMutableArray *links = [NSMutableArray array];
        
        if (dictionary[@"embeddedLinks"]) {
            
            for (NSDictionary *embeddedLink in dictionary[@"embeddedLinks"]) {
                
                TSCLink *link = [[TSCLink alloc] initWithDictionary:embeddedLink];
                if (link) {
                    [links addObject:link];
                }
            }
        }
        
        self.embeddedLinks = links;
    }
    
    return self;
}

- (TSCEmbeddedLinksListItemCell *)tableViewCell:(TSCEmbeddedLinksListItemCell *)cell
{
    cell = (TSCEmbeddedLinksListItemCell *)[super tableViewCell:cell];
    cell.links = self.embeddedLinks;

    return cell;
}

@end