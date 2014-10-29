//
//  TSCButtonListItemView.m
//  ThunderStorm
//
//  Created by Simon Mitchell on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCButtonListItem.h"
#import "TSCLink.h"
@import ThunderBasics;

@interface TSCButtonListItem ()

@end

@implementation TSCButtonListItem

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject styler:(TSCStormStyler *)styler
{
    self = [super initWithDictionary:dictionary parentObject:parentObject styler:styler];
    
    if (self) {
        
        NSMutableArray *links = [NSMutableArray arrayWithArray:self.embeddedLinks];
        
        if (dictionary[@"button"]) {
            
            TSCLink *link = [[TSCLink alloc] initWithDictionary:dictionary[@"button"][@"link"]];
            
            if (!link.title) {
                link.title = TSCLanguageDictionary(dictionary[@"button"][@"title"]);
            }
            [links insertObject:link atIndex:0];
        }
        
        self.embeddedLinks = links;
    }
    
    return self;
}

- (Class)tableViewCellClass
{
    return [TSCEmbeddedLinksListItemCell class];
}

@end