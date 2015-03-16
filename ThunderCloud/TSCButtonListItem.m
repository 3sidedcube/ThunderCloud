//
//  TSCButtonListItemView.m
//  ThunderStorm
//
//  Created by Simon Mitchell on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCButtonListItem.h"
#import "TSCLink.h"
@import ThunderBasics;

@interface TSCButtonListItem ()

@property (nonatomic, assign) TSCLink *mainLink;

@end

@implementation TSCButtonListItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject
{
    if (self = [super initWithDictionary:dictionary parentObject:parentObject]) {
        
        NSMutableArray *links = [NSMutableArray arrayWithArray:self.embeddedLinks];
        
        if (dictionary[@"button"]) {
            
            TSCLink *link = [[TSCLink alloc] initWithDictionary:dictionary[@"button"][@"link"]];
            
            if (!link.title) {
                link.title = TSCLanguageDictionary(dictionary[@"button"][@"title"]);
            }
            
            if (link) {
                [links insertObject:link atIndex:0];
            }
        }
        
        self.embeddedLinks = links;
    }
    
    return self;
}

- (TSCEmbeddedLinksListItemCell *)tableViewCell:(TSCEmbeddedLinksListItemCell *)cell
{
    cell.hideUnavailableLinks = false;
    cell = (TSCEmbeddedLinksListItemCell *)[super tableViewCell:cell];
    
    if (self.embeddedLinks.count == 1) {
        
        cell.target = self.target;
        cell.selector = self.selector;
    }
    
    return cell;
}

- (Class)tableViewCellClass
{
    return [TSCEmbeddedLinksListItemCell class];
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return false;
}

- (instancetype)initWithTarget:(id)target selector:(SEL)aSelector
{
    if (self = [super init]) {
        
        self.target = target;
        self.selector = aSelector;
    }
    return self;
}

+ (instancetype)itemWithTitle:(NSString *)title buttonTitle:(NSString *)buttonTitle target:(id)target selector:(SEL)aSeclector
{
    TSCButtonListItem *buttonListItem = [[TSCButtonListItem alloc] initWithTarget:target selector:aSeclector];
    buttonListItem.title = title;
    
    TSCLink *link = [TSCLink new];
    link.title = buttonTitle;
    buttonListItem.embeddedLinks = @[link];
    
    return buttonListItem;
}

- (id)rowSelectionTarget
{
    return self.target;
}

- (SEL)rowSelectionSelector
{
    return self.selector;
}


@end