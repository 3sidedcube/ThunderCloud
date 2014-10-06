//
//  TSCQuizResponseTextOption.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import Foundation;
@import ThunderTable;

@interface TSCQuizResponseTextOption : NSObject <TSCTableRowDataSource>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *checkBoxSelected;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
