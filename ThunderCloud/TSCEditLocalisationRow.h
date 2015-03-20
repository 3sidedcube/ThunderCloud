//
//  TSCEditLocalisationRow.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 19/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import <ThunderTable/ThunderTable.h>

@class TSCLocalisationLanguage, TSCLocalisationKeyValue;

/**
 A table view row for allowing a user to edit a localisation for a specific language
 */
@interface TSCEditLocalisationRow : TSCTableInputTextViewRow

/**
 Initializes a new row for eding the localisation for a given language
 @param localisation The localisation key value pair for a certain localisation that this row is allowing the user to edit
 */
+ (instancetype)rowWithLocalisationKeyValue:(TSCLocalisationKeyValue *)localisation;

/**
 @abstract The language for which the user is editing the localisation
 */
@property (nonatomic, strong) TSCLocalisationLanguage *language;

@end
