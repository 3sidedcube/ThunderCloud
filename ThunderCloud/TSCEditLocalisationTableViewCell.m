//
//  TSCEditLocalisationTableViewCell.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 19/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import "TSCEditLocalisationTableViewCell.h"
#import "UIColor-Expanded.h"
#import "TSCEditLocalisationRow.h"
#import "TSCLocalisationLanguage.h"

@interface TSCEditLocalisationTableViewCell() <UITextViewDelegate>

@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation TSCEditLocalisationTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.textView = [[UITextView alloc] init];
        self.textView.textAlignment = NSTextAlignmentRight;
        self.textView.delegate = self;
        self.textView.textColor = [UIColor blackColor];
        self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        self.textView.returnKeyType = UIReturnKeyNext;
        
        [self.contentView addSubview:self.textView];
        
        self.backgroundView = [UIView new];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        self.backgroundView.layer.borderWidth = (double)1/[[UIScreen mainScreen] scale];
        self.backgroundView.layer.borderColor = [UIColor colorWithHexString:@"9B9B9B"].CGColor;
        self.backgroundView.layer.cornerRadius = 2.0;
        [self.contentView addSubview:self.backgroundView];
        [self.contentView sendSubviewToBack:self.backgroundView];
        
        self.separatorView = [UIView new];
        self.separatorView.backgroundColor = [UIColor colorWithHexString:@"9B9B9B"];
        [self.backgroundView addSubview:self.separatorView];
        
        self.textView.contentOffset = CGPointMake(0, 0);
        
        self.textView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.shouldDisplaySeparators = false;
    
    if ([self.inputRow isKindOfClass:[TSCEditLocalisationRow class]]) {
        
        TSCEditLocalisationRow *editRow = (TSCEditLocalisationRow *)self.inputRow;
        
        NSLocaleLanguageDirection languageDirection = [NSLocale characterDirectionForLanguage:editRow.language.languageCode];
        self.textView.textAlignment = languageDirection == NSLocaleLanguageDirectionRightToLeft ? NSTextAlignmentRight : NSTextAlignmentLeft;
    }
    
    self.backgroundView.frame = CGRectMake(8, 8, self.contentView.bounds.size.width - 16, self.contentView.bounds.size.height - 8);
    self.textLabel.frame = CGRectMake(16, 8, 83, self.backgroundView.frame.size.height);
    
    self.separatorView.frame = CGRectMake(CGRectGetMaxX(self.textLabel.frame), 0, (double)1/[[UIScreen mainScreen] scale], self.backgroundView.frame.size.height);
    self.textView.frame = CGRectMake(CGRectGetMaxX(self.textLabel.frame) + 12, 8, self.backgroundView.frame.size.width - CGRectGetMaxX(self.textLabel.frame) - 10, self.backgroundView.frame.size.height);
    self.textView.textAlignment = NSTextAlignmentLeft;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.inputRow.value = textView.text;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:false];
    self.textView.userInteractionEnabled = editing;
    
    if (!editing) {
        [self resignKeyboard];
    }
}

#pragma mark - Navigation handling

- (void)resignKeyboard
{
    [self.textView resignFirstResponder];
}

#pragma mark - Setter methods

- (BOOL)becomeFirstResponder
{
    return [self.textView becomeFirstResponder];
}

@end
