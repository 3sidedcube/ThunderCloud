//
//  TSCQuizResponseTextOption.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizResponseTextOption.h"
@import ThunderBasics;

@interface TSCQuizResponseTextOption () <UIGestureRecognizerDelegate>

@end

@implementation TSCQuizResponseTextOption

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        self.title = TSCLanguageDictionary(dictionary);
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
    for (UITapGestureRecognizer *tapGesture in cell.contentView.gestureRecognizers) {
        
        [cell.contentView removeGestureRecognizer:tapGesture];
    }
    
    return cell;
}

- (BOOL)shouldDisplaySelectionIndicator;
{
    return NO;
}

@end
