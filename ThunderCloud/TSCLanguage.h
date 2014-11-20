//
//  TSCLanguage.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 18/02/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@import ThunderTable;
@import ThunderBasics;

@interface TSCLanguage : TSCObject <TSCTableRowDataSource, NSCoding>

@property (nonatomic, strong) NSString *localisedLanguageName;
@property (nonatomic, strong) NSString *languageIdentifier;

@end
