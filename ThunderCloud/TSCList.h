//
//  TSCGroupView.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderTable;
#import "TSCStormObjectDataSource.h"
#import "TSCStormObject.h"

/**
 `TSCList` is a `TSCStormObject` that represents a `TSCTableSection` and conforms to `TSCTableSectionDataSource`. Each section in a storm generated table view will be represented as a `TSCList`
 */
@interface TSCList : TSCStormObject /*<TSCTableSectionDataSource>*/

/**
 @abstract The `TSCTableSection` header title
 */
@property (nonatomic, copy) NSString *header;

/**
 @abstract The `TSCTableSection` footer title
 */
@property (nonatomic, copy) NSString *footer;

/**
 @abstract An array of `TSCStormObject`s that comply to `TSCTableRowDataSource`
 */
@property (nonatomic, strong) NSArray *items;

@end
