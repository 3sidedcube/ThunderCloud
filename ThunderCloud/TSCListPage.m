//
//  TSCPage.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCListPage.h"
#import "UINavigationController+TSCNavigationController.h"
#import "TSCStormObject.h"
@import ThunderBasics;
@import MobileCoreServices;

@interface TSCListPage ()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation TSCListPage

- (instancetype)initWithContentsOfFile:(NSString *)filePath
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *pageDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    self = [self initWithDictionary:pageDictionary parentObject:nil];
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
        self.attributes = dictionary[@"attributes"];
        self.parentObject = parentObject;
        self.title = TSCLanguageString(dictionary[@"title"][@"content"]);
        
        if ([dictionary[@"id"] isKindOfClass:[NSNumber class]]) {
            self.pageId = [NSString stringWithFormat:@"%@",dictionary[@"id"]];
        } else {
            self.pageId = dictionary[@"id"];
        }
        
        self.dictionary = dictionary;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[TSCThemeManager sharedTheme] backgroundColor];
    
    NSMutableArray *sections = [NSMutableArray array];
    
    for (NSDictionary *child in self.dictionary[@"children"]) {
        
        id object = [TSCStormObject objectWithDictionary:child parentObject:self];
        if (object) {
            [sections addObject:object];
        }
    }
    
    self.dataSource = sections;
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

- (instancetype)stormParentObject
{
    return self.parentObject;
}

- (void)setStormParentObject:(id)parentObject
{
    self.parentObject = parentObject;
}

- (CSSearchableItemAttributeSet *)searchableAttributeSet
{
    NSMutableArray *sections = [NSMutableArray array];
    
    for (NSDictionary *child in self.dictionary[@"children"]) {
        
        id object = [TSCStormObject objectWithDictionary:child parentObject:self];
        if (object) {
            [sections addObject:object];
        }
    }
    
    if (sections.count > 0) {

        __block CSSearchableItemAttributeSet *searchableAttributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeData];
        searchableAttributeSet.title = self.title;
        
        [sections enumerateObjectsUsingBlock:^(TSCTableSection *section, NSUInteger sectionIndex, BOOL *stopSection) {
            
            [section.sectionItems enumerateObjectsUsingBlock:^(TSCTableRow *row, NSUInteger rowIndex, BOOL *stopRow) {

                if (row.rowTitle && !searchableAttributeSet.contentDescription) {
                    searchableAttributeSet.contentDescription = row.rowSubtitle ? [row.rowTitle stringByAppendingFormat:@"\n\n%@", row.rowSubtitle] : row.rowTitle;
                }
                
                if (row.rowImage && !searchableAttributeSet.thumbnailData) {
                    searchableAttributeSet.thumbnailData = UIImageJPEGRepresentation(row.rowImage, 0.1);
                }
                
                if (searchableAttributeSet.contentDescription && searchableAttributeSet.thumbnailData) {
                    *stopRow = true;
                    *stopSection = true;
                }
            }];
        }];
        
        return searchableAttributeSet;
    }
  
    return nil;
}

@end