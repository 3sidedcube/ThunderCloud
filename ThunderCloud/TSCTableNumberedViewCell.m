//
//  TSCTableNumberedViewCell.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCTableNumberedViewCell.h"

@implementation TSCTableNumberedViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.numberLabel = [[UILabel alloc] init];
        self.numberLabel.textColor = [[TSCThemeManager sharedTheme] mainColor];
        self.numberLabel.font = [UIFont systemFontOfSize:32];
        self.numberLabel.backgroundColor = [UIColor clearColor];
        self.numberLabel.adjustsFontSizeToFitWidth = YES;
        
        if (![TSCThemeManager isOS7]) {
            self.numberLabel.backgroundColor = [UIColor clearColor];
        }
//        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.numberLabel];
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Needed it working quickly. Sorry Matt!
    #warning Temporarily disabled localised text direction.
    
    self.numberLabel.frame = CGRectMake(15, 10, 30, 30);
    
    CGPoint textOffset = CGPointMake(self.numberLabel.frame.size.width + self.numberLabel.frame.origin.x, 10);
    CGSize constainedSize = CGSizeMake(self.contentView.frame.size.width - textOffset.x, MAXFLOAT);
    
    CGSize textLabelSize = [self.textLabel sizeThatFits:constainedSize];
    CGSize detailTextLabelSize = [self.detailTextLabel sizeThatFits:constainedSize];
    
    self.textLabel.frame = CGRectMake(textOffset.x, textOffset.y, textLabelSize.width, textLabelSize.height);
    self.detailTextLabel.frame = CGRectMake(textOffset.x, self.textLabel.frame.size.height + self.textLabel.frame.origin.y + 5, detailTextLabelSize.width, detailTextLabelSize.height);
    
    /*
    self.numberLabel.frame = CGRectMake(15, 15, 35, 30);
    
    CGPoint textOffset = CGPointMake(self.numberLabel.frame.size.width + self.numberLabel.frame.origin.x, self.numberLabel.frame.origin.y);
    CGSize textConstrainedSize = CGSizeMake(self.contentView.frame.size.width - textOffset.x - 10, MAXFLOAT);
    
    CGSize textLabelSize = [self.textLabel.text sizeWithFont:self.textLabel.font constrainedToSize:textConstrainedSize lineBreakMode:NSLineBreakByWordWrapping];
    CGSize detailLabelSize = [self.detailTextLabel.text sizeWithFont:self.detailTextLabel.font constrainedToSize:textConstrainedSize lineBreakMode:NSLineBreakByWordWrapping];
    
    if([TSCThemeManager localisedTextDirectionForBaseDirection:NSTextAlignmentLeft] == NSTextAlignmentRight){
        
        self.textLabel.frame = CGRectMake(self.frame.size.width - textLabelSize.width - textOffset.x, textOffset.y, textLabelSize.width, textLabelSize.height + 16);
        self.detailTextLabel.frame = CGRectMake(self.frame.size.width - detailLabelSize.width - textOffset.x, self.textLabel.frame.size.height + self.textLabel.frame.origin.y, detailLabelSize.width, detailLabelSize.height + 16);
        self.numberLabel.frame = CGRectMake(self.contentView.bounds.size.width - 40, 15, 35, 30);


    } else {
        
        self.textLabel.frame = CGRectMake(textOffset.x, textOffset.y, textLabelSize.width, textLabelSize.height + 16);
        self.detailTextLabel.frame = CGRectMake(textOffset.x, self.textLabel.frame.size.height + self.textLabel.frame.origin.y, detailLabelSize.width, detailLabelSize.height + 16);
        self.numberLabel.frame = CGRectMake(15, 15, 35, 30);

    }
    [self.detailTextLabel setFont:[UIFont systemFontOfSize:14]];
    
    [self layoutButtons];*/
    
}

@end
