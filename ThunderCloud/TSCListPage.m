//
//  TSCPage.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCListPage.h"
#import "UINavigationController+TSCNavigationController.h"
#import "TSCStormStyler.h"  
#import "TSCStormObject.h"
@import ThunderBasics;

@implementation TSCListPage

- (id)initWithContentsOfFile:(NSString *)filePath
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *pageDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    self = [self initWithDictionary:pageDictionary parentObject:nil styler:nil];
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject styler:(TSCStormStyler *)styler
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        
        // We use the attributes as a temporary work around for stylings
        self.styler = styler;
        self.attributes = dictionary[@"attributes"];
        self.parentObject = parentObject;
        self.title = TSCLanguageString(dictionary[@"title"][@"content"]);
        self.pageId = [dictionary[@"id"] integerValue];
        
        NSMutableArray *sections = [NSMutableArray array];
        
        for (NSDictionary *child in dictionary[@"children"]) {
            
            id object = [TSCStormObject objectWithDictionary:child parentObject:self];
            if (object) {
                [sections addObject:object];
            }
        }
        
        self.dataSource = sections;
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        
        // We use the attributes as a temporary work around for stylings
        self.attributes = dictionary[@"attributes"];
        self.parentObject = parentObject;
        self.title = TSCLanguageString(dictionary[@"title"][@"content"]);
        self.pageId = [dictionary[@"id"] integerValue];
        
        NSMutableArray *sections = [NSMutableArray array];
        
        for (NSDictionary *child in dictionary[@"children"]) {
            
            id object = [TSCStormObject objectWithDictionary:child parentObject:self];
            if (object) {
                [sections addObject:object];
            }
        }
        
        self.dataSource = sections;
    }
    
    return self;
}


- (void)handleSelection:(TSCTableSelection *)selection
{
    TSCLink *link = [selection.object rowLink];
    [self.navigationController pushLink:link];
}

#pragma mark - Storm object data source

- (NSArray *)stormAttributes
{
    return self.attributes;
}

- (TSCStormStyler *)stormStyler
{
    return self.styler;
}

- (id)stormParentObject
{
    return self.parentObject;
}

- (void)setStormParentObject:(id)parentObject
{
    self.parentObject = parentObject;
}

@end