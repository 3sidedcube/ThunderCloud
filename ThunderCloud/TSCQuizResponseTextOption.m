//
//  TSCQuizResponseTextOption.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizResponseTextOption.h"
@import ThunderBasics;

@implementation TSCQuizResponseTextOption

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        
        self.title = TSCLanguageDictionary(dictionary);
        self.checkBoxSelected = [NSNumber numberWithBool:NO];
        
    }
    
    return self;
}

#pragma mark Row data source

- (NSString *)rowTitle
{
    return self.title;
}

- (NSString *)rowSubtitle
{
    return nil;
}

- (BOOL)canEditRow
{
    return NO;
}

- (UIImage *)rowImage
{
    return nil;
}

- (NSURL *)rowImageURL
{
    return nil;
}

- (id)rowSelectionTarget
{
    return nil;
}

- (SEL)rowSelectionSelector
{
    return nil;
}

- (TSCLink *)rowLink
{
    return nil;
}

- (Class)tableViewCellClass;
{
    return [TSCTableInputCheckViewCell class];
}

- (TSCTableInputCheckViewCell *)tableViewCell:(TSCTableInputCheckViewCell *)cell
{
    [cell.checkView setOn:[self.checkBoxSelected boolValue] animated:NO];
    [cell.checkView addTarget:self action:@selector(toggleCheckState:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (BOOL)shouldDisplaySelectionIndicator;
{
    return NO;
}

- (void)toggleCheckState:(TSCCheckView *)sender
{
    [sender removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
    [sender setOn:sender.isOn animated:NO];
    self.checkBoxSelected = [NSNumber numberWithBool:sender.isOn];
    [sender addTarget:self action:@selector(toggleCheckState:) forControlEvents:UIControlEventValueChanged];
}

@end
