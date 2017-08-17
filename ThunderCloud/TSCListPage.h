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
@import ThunderBasics;
@import ThunderTable;

@class TSCListPage;
@class TSCTableSelection;
@class TSCLink;

/**
 `TSCListPage` is a subclass of `TSCTableViewController` that lays out storm table view content
 */
@interface TSCListPage : TSCTableViewController <TSCStormObjectDataSource, TSCNavigationBarDataSource, TSCCoreSpotlightIndexItem>

/**
 @abstract An array of dictionarys that contain custom attributes for the `TSCStormObject`
 */
@property (nullable, nonatomic, strong) NSArray *attributes;

/**
 @abstract The object that the `TSCListPgae` is contained in
 */
@property (nullable, nonatomic, strong) id parentObject;

/**
 @abstract The unique identifier for the storm page
 */
@property (nullable, nonatomic, copy) NSString *pageId;

/**
 @abstract The internal name for this page. Named pages can be used for native overrides and for identifying pages that may change with delta publishes. By default pages do not have names but they can be added in the CMS
 */
@property (nullable, nonatomic, copy) NSString *pageName;

/**
 Initalizes the page with the contents of a file path
 @param filePath The system file path of which to extract the contents
 @discussion The contents of the file path has to be a json representation of a `TSCListPage` for the page to render correctly
 */
- (instancetype _Nullable)initWithContentsOfFile:(NSString * _Nonnull)filePath;

/**
 Initalizes the page with a dictionary representation of a `TSCListPage`
 @param dictionary A dictionary representation of a `TSCListPage`
 @param parentObject The parent object of the `TSCListPage`
 @discussion The dictionary must be a correct representation of a `TSCListPage` for the page to render correctly
 */
- (instancetype _Nonnull)initWithDictionary:(NSDictionary * _Nonnull)dictionary parentObject:(id _Nullable)parentObject;

/**
 Handle Selection is called when an item in the table view is selected. An action is performed based on the `TSCLink` which is parsed in with the selection.
 @param selection A `TSCTableSelection` object which contains the `TSCLink` to perform an action
 */
- (void)handleSelection:(TSCTableSelection * _Nonnull)selection;

@end