//
//  TSCVideo.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 16/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@import Foundation;
@import ThunderTable;

@interface TSCVideo : NSObject <TSCTableRowDataSource>

@property (nonatomic, copy) NSString *videoLocaleString;
@property (nonatomic, strong) NSLocale *videoLocale;
@property (nonatomic, strong) TSCLink *videoLink;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
