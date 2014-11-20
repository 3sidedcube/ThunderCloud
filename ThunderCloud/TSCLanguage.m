//
//  TSCLanguage.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 18/02/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCLanguage.h"
#import "TSCStormLanguageController.h"

@implementation TSCLanguage

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        
        self.localisedLanguageName = [decoder decodeObjectForKey:@"TSCLanguageName"];
        self.languageIdentifier = [decoder decodeObjectForKey:@"TSCLanguageIdentifier"];
        
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.localisedLanguageName forKey:@"TSCLanguageName"];
    [coder encodeObject:self.languageIdentifier forKey:@"TSCLanguageIdentifier"];
}

- (NSString *)rowTitle
{
    return self.localisedLanguageName;
}

- (id)rowSelectionTarget
{
    return nil;
}

- (SEL)rowSelectionSelector
{
    return nil;
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell
{
    NSString *currentLanguage = [[TSCStormLanguageController sharedController] currentLanguage];
    NSString *overrideLanguage = [[TSCStormLanguageController sharedController] overrideLanguage].languageIdentifier;
    
    if(!overrideLanguage){
        if([self.languageIdentifier isEqualToString:currentLanguage])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else {
        if([self.languageIdentifier isEqualToString:overrideLanguage])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return NO;
}
@end
