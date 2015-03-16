//
//  TSCStormTableRow.m
//  ThunderCloud
//
//  Created by Sam Houghton on 16/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCStormTableRow.h"
#import "TSCEmbeddedLinksListItem.h"
#import "TSCStormLanguageController.h"

@implementation TSCStormTableRow

- (id)init
{
    if (self = [super init]) {
        self.shouldCenterText = NO;
        self.shouldDisplaySelectionIndicator = YES;
    }
    
    return self;
}

+ (id)rowWithTitle:(NSString *)title
{
    TSCStormTableRow *row = [[TSCStormTableRow alloc] init];
    row.title = title;
    
    return row;
}

+ (id)rowWithTitle:(NSString *)title textColor:(UIColor *)textColor
{
    TSCStormTableRow *row = [[TSCStormTableRow alloc] init];
    row.title = title;
    row.textColor = textColor;
    
    return row;
}

+ (id)rowWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image
{
    TSCStormTableRow *row = [[TSCStormTableRow alloc] init];
    row.title = title;
    row.subtitle = subtitle;
    row.image = image;
    
    return row;
}

+ (id)rowWithTitle:(NSString *)title subtitle:(NSString *)subtitle imageURL:(NSURL *)imageURL
{
    TSCStormTableRow *row = [[TSCStormTableRow alloc] init];
    row.title = title;
    row.subtitle = subtitle;
    row.imageURL = imageURL;
    
    return row;
}

- (void)addTarget:(id)target selector:(SEL)selector
{
    self.target = target;
    self.selector = selector;
}

#pragma Table Row Data Source

- (NSString *)rowTitle
{
    return self.title;
}

- (NSString *)rowSubtitle
{
    return self.subtitle;
}

- (UIImage *)rowImage
{
    return self.image;
}

- (NSURL *)rowImageURL
{
    return self.imageURL;
}

- (UIImage *)rowImagePlaceholder
{
    return self.imagePlaceholder;
}

- (Class)tableViewCellClass
{
    return [TSCEmbeddedLinksListItemCell class];
}

- (id)rowSelectionTarget
{
    return self.target;
}

- (SEL)rowSelectionSelector
{
    return self.selector;
}

- (TSCLink *)rowLink
{
    return self.link;
}

- (BOOL)shouldDisplaySelectionCell
{
    return YES;
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell;
{
    TSCTableViewCell *standardCell = (TSCTableViewCell *)cell;
    
    if (self.textColor) {
        standardCell.textLabel.textColor = self.textColor;
    }
    
    if (self.accessoryType) {
        standardCell.accessoryType = self.accessoryType;
    }
    
    if ([[TSCStormLanguageController sharedController] isRightToLeft] && [self isMemberOfClass:[TSCEmbeddedLinksListItemCell class]]) {
        
        for (UIView *view in cell.contentView.subviews) {
            
            if([view isKindOfClass:[UILabel class]]) {
                
                if (cell.imageView.image) {
                    
                    view.frame = CGRectMake(cell.frame.size.width - view.frame.origin.x - view.frame.size.width + 20, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                    
                } else {
                    
                    if (self.accessoryType != UITableViewCellAccessoryNone) {
                        
                        view.frame = CGRectMake(cell.frame.size.width - view.frame.origin.x - view.frame.size.width - 20, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                        
                    } else {
                        
                        view.frame = CGRectMake(cell.frame.size.width - view.frame.origin.x - view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                    }
                }
                
                ((UILabel *)view).textAlignment = NSTextAlignmentRight;
                
            }
        }
    }
    
    return standardCell;
}

@end
