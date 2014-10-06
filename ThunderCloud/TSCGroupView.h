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

@interface TSCGroupView : TSCStormObject <TSCTableSectionDataSource>

@property (nonatomic, strong) NSString *header;
@property (nonatomic, strong) NSString *footer;
@property (nonatomic, strong) NSArray *items;

@end
