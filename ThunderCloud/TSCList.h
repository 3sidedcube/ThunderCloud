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

@interface TSCList : TSCStormObject <TSCTableSectionDataSource>

@property (nonatomic, copy) NSString *header;
@property (nonatomic, copy) NSString *footer;
@property (nonatomic, strong) NSArray *items;

@end
