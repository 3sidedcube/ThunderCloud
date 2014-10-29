//
//  TSCPage.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSCStormObjectDataSource.h"
#import "TSCNavigationBarDataSource.h"
@import ThunderTable;

@class TSCListPage;
@class TSCTableSelection;
@class TSCLink;

@interface TSCListPage : TSCTableViewController <TSCStormObjectDataSource, TSCNavigationBarDataSource>

@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic, strong) id parentObject;
@property (nonatomic, assign) NSInteger pageId;

- (id)initWithContentsOfFile:(NSString *)filePath;
- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject;
- (void)handleSelection:(TSCTableSelection *)selection;

@end
