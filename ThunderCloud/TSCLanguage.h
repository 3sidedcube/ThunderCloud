//
//  TSCLanguage.h
//  ThunderCloud
//
//  Created by Sam Houghton on 16/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

@import ThunderBasics;
@import ThunderTable;

/**
 An object representation of a language
 
 This conforms to `TSCTableRowDataSource` and `NSCoding` and so can easily be displayed in a table view (will just display the localised language name) and encoded for storing in `NSUserDefaults`
 */
@interface TSCLanguage : TSCObject <TSCTableRowDataSource, NSCoding>

/**
 @abstract The localised readable name of the language
 */
@property (nonatomic, copy) NSString *localisedLanguageName;

/**
 @abstract The unique identifier of the language
 */
@property (nonatomic, copy) NSString *languageIdentifier;

@end
