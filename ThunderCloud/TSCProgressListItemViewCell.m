//
//  TSCProgressListItemViewCell.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCProgressListItemViewCell.h"
#import "TSCStormLanguageController.h"

@implementation TSCProgressListItemViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
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
        self.quizCountLabel.clipsToBounds = true;
        self.quizCountLabel.text = @" 1 / 1 ";
        [self.contentView addSubview:self.quizCountLabel];
        
        // Use example text to correctly round it.
        self.quizCountLabel.layer.cornerRadius = [self.quizCountLabel sizeThatFits:CGSizeMake(self.contentView.frame.size.width, MAXFLOAT)].height/2;
        
        [self.quizCountLabel sizeToFit];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (![self.nextLabel.text isEqualToString:@""]) {
        self.nextLabel.frame = CGRectMake(15, 0, 50, 44);
    } else {
        self.nextLabel.frame = CGRectMake(15, 0, 0, 0);
    }
    
    self.testNameLabel.frame = CGRectMake(self.nextLabel.frame.origin.x + self.nextLabel.frame.size.width + 10, 0, 150, 44);
    self.quizCountLabel.frame = CGRectMake(self.contentView.frame.size.width - 60, 13, 0, 0);
    
    if (self.accessoryType != UITableViewCellAccessoryDisclosureIndicator) {
        self.quizCountLabel.center = CGPointMake(self.quizCountLabel.center.x - 20, self.quizCountLabel.center.y);
    }
    
    [self.quizCountLabel sizeToFit];
    self.quizCountLabel.layer.cornerRadius = self.quizCountLabel.frame.size.height/2;
    
    if ([[TSCStormLanguageController sharedController] isRightToLeft] && [self isMemberOfClass:[TSCProgressListItemViewCell class]]) {
        
        for (UIView *view in self.contentView.subviews) {
            
            if ([view isKindOfClass:[UILabel class]]) {
                
                if (self.accessoryType != UITableViewCellAccessoryNone) {
                    
                    view.frame = CGRectMake(self.frame.size.width - view.frame.origin.x - view.frame.size.width - 20, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                    
                } else {
                    
                    view.frame = CGRectMake(self.frame.size.width - view.frame.origin.x - view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                }
                
                if (view == self.quizCountLabel) {
                    
                    view.frame = CGRectMake(view.frame.origin.x - 20, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
                }
                
                ((UILabel *)view).textAlignment = NSTextAlignmentRight;
            }
        }
    }
    
    self.quizCountLabel.textAlignment = NSTextAlignmentCenter;
}

@end
