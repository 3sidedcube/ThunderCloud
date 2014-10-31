//
//  TSCProgressListItemViewCell.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCProgressListItemViewCell.h"

@implementation TSCProgressListItemViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        
        //Label to say "Next" or complete
        self.nextLabel = [[UILabel alloc] init];
        self.nextLabel.backgroundColor = [UIColor clearColor];
        self.nextLabel.adjustsFontSizeToFitWidth = YES;
        self.nextLabel.font = [UIFont boldSystemFontOfSize:17];
        [self.contentView addSubview:self.nextLabel];

        //Label for next test
        self.testNameLabel = [[UILabel alloc] init];
        self.testNameLabel.textColor = [UIColor grayColor];
        self.testNameLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.testNameLabel];

        //Label for quiz count
        self.quizCountLabel = [[UILabel alloc] init];
        self.quizCountLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        self.quizCountLabel.textColor = [UIColor whiteColor];
        self.quizCountLabel.backgroundColor = [[TSCThemeManager sharedTheme] mainColor];
        [self.contentView addSubview:self.quizCountLabel];

        // Use example text to correctly round it.
        //self.quizCountLabel.layer.cornerRadius = [@" 1 / 1 " sizeWithFont:self.quizCountLabel.font].height / 2;
        self.quizCountLabel.layer.cornerRadius = [@" 1 / 1 " boundingRectWithSize:CGSizeMake(self.contentView.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.quizCountLabel.font} context:nil].size.height/2;
        
        [self.quizCountLabel sizeToFit];
        
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.nextLabel.frame = CGRectMake(15, 0, 50, 44);
    self.testNameLabel.frame = CGRectMake(self.nextLabel.frame.origin.x + self.nextLabel.frame.size.width + 10, 0, 150, 44);
    self.quizCountLabel.frame = CGRectMake(self.contentView.frame.size.width - 60, 13, 0, 0);
    [self.quizCountLabel sizeToFit];
}

@end
