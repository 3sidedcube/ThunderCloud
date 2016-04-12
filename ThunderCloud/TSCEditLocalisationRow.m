//
//  TSCEditLocalisationRow.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 19/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCEditLocalisationRow.h"
#import "TSCLocalisationLanguage.h"
#import "TSCLocalisationKeyValue.h"
#import "TSCLocalisationController.h"
#import "TSCEditLocalisationTableViewCell.h"

@interface TSCEditLocalisationRow ()

@property (nonatomic, strong) TSCLocalisationKeyValue *localisationKeyValue;

@end

@implementation TSCEditLocalisationRow

+ (instancetype)rowWithLocalisationKeyValue:(TSCLocalisationKeyValue *)localisation
{
    
    TSCEditLocalisationRow *row = [TSCEditLocalisationRow new];
    row.language = localisation.language;
    row.inputId = localisation.languageCode;
    row.required = true;
    row.cellHeight = 89;
    row.title = [[TSCLocalisationController sharedController] localisedLanguageNameForLanguageKey:localisation.languageCode];
    row.value = localisation.localisedString;
    
    return row;
}

- (NSString *)rowTitle
{
    return self.title;
}

- (Class)tableViewCellClass
{
    return [TSCEditLocalisationTableViewCell class];
}

- (UIColor *)rowBackgroundColor
{
    return [UIColor clearColor];
}

@end
