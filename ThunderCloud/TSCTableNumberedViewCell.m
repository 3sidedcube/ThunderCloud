//
//  TSCTableNumberedViewCell.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCTableNumberedViewCell.h"
#import "TSCStormLanguageController.h"

@implementation TSCTableNumberedViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.numberLabel = [[UILabel alloc] init];
        self.numberLabel.textColor = [[TSCThemeManager sharedTheme] freeTextColor];
        self.numberLabel.font = [UIFont systemFontOfSize:32];
        self.numberLabel.backgroundColor = [UIColor clearColor];
        self.numberLabel.adjustsFontSizeToFitWidth = YES;
        
        if (![TSCThemeManager isOS7]) {
            self.numberLabel.backgroundColor = [UIColor clearColor];
        }
        
        [self.contentView addSubview:self.numberLabel];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.numberLabel.frame = CGRectMake(22, 6, 36, 36);
    
    CGPoint textOffset = CGPointMake(self.numberLabel.frame.size.width + self.numberLabel.frame.origin.x, 10);
    CGSize constainedSize = CGSizeMake(self.contentView.frame.size.width - textOffset.x - 12, MAXFLOAT);
    
    CGSize textLabelSize = [self.textLabel sizeThatFits:constainedSize];
    CGSize detailTextLabelSize = [self.detailTextLabel sizeThatFits:constainedSize];
    
    self.textLabel.frame = CGRectMake(textOffset.x, textOffset.y, textLabelSize.width, textLabelSize.height);
    self.detailTextLabel.frame = CGRectMake(textOffset.x, self.textLabel.frame.size.height + self.textLabel.frame.origin.y + 5, detailTextLabelSize.width, detailTextLabelSize.height);
    
    [self layoutLinks];
    
    if ([[TSCStormLanguageController sharedController] isRightToLeft] && [self isMemberOfClass:[TSCTableNumberedViewCell class]]) {
        
        for (UIView *view in self.contentView.subviews) {
            
            view.frame = CGRectMake(self.frame.size.width - view.frame.origin.x - view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
            if ([view isKindOfClass:[UILabel class]]) {
                
                ((UILabel *)view).textAlignment = NSTextAlignmentRight;
            }
        }
    }
}

@end
