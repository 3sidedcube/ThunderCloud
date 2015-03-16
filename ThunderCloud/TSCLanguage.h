//
//  TSCLanguage.h
//  ThunderCloud
//
//  Created by Sam Houghton on 16/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

@import ThunderBasics;
@import ThunderTable;

@interface TSCLanguage : TSCObject <TSCTableRowDataSource, NSCoding>

@property (nonatomic, copy) NSString *localisedLanguageName;
@property (nonatomic, copy) NSString *languageIdentifier;

@end
