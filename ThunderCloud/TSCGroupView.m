//
//  TSCGroupView.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCGroupView.h"
#import "TSCListPage.h"
@import ThunderBasics;

@implementation TSCGroupView

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject styler:(TSCStormStyler *)styler
{
    self = [super initWithDictionary:dictionary parentObject:parentObject styler:styler];
    
    if (self) {
    
        self.header = TSCLanguageDictionary(dictionary[@"header"]);
        self.footer = TSCLanguageDictionary(dictionary[@"footer"]);
        
        NSMutableArray *items = [NSMutableArray array];
        
        for (NSDictionary *child in dictionary[@"children"]) {
                        
            id item = [TSCStormObject objectWithDictionary:child parentObject:self];
            
            if (item) {
                [items addObject:item];
            }
        }
    
        self.items = items;
    }
    
    return self;
}

- (void)handleSelection:(TSCTableSelection *)selection
{
    TSCListPage *listPage = (TSCListPage *)[self stormParentObject];
    [listPage handleSelection:selection];
}

#pragma mark Section data source

- (NSString *)sectionHeader
{
    return self.header;
}

- (NSString *)sectionFooter
{
    return self.footer;
}

- (NSArray *)sectionItems
{
    return self.items;
}

- (SEL)sectionSelector
{
    return nil;
}

- (id)sectionTarget
{
    return nil;
}


@end
