//
//  TSCCheckView.m
// ThunderTable
//
//  Created by Phillip Caudell on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCCheckView.h"
@import ThunderTable;

@implementation TSCCheckView

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
		[self setup];
    }
    
    return self;
}

- (void)setup
{
	if (!self.onTintColor) {
		self.onTintColor = [TSCThemeManager shared].theme.mainColor;
	}
	
	if (!self.tintColor) {
		self.tintColor = [UIColor colorWithRed:0.90f green:0.90f blue:0.90f alpha:1.00f];
	}
	
	self.outerView = [[UIView alloc] initWithFrame:self.bounds];
	self.outerView.layer.cornerRadius = self.outerView.bounds.size.height/2;
	[self addSubview:self.outerView];
	
	self.innerView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 1.5, 1.5)];
	self.innerView.layer.cornerRadius = self.innerView.bounds.size.height/2;
	self.innerView.backgroundColor = [UIColor whiteColor];
	[self addSubview:self.innerView];
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[self addGestureRecognizer:tapGesture];
	
	[self setOn:NO animated:NO];
}

- (void)setCheckIdentifier:(NSNumber *)checkIdentifier
{
    _checkIdentifier = checkIdentifier;
    BOOL isOn = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"TSCCheckItem%@", self.checkIdentifier]];
    [self setOn:isOn animated:NO saveState:NO];
}

- (void)setOn:(BOOL)on animated:(BOOL)animated saveState:(BOOL)save
{
    self.on = on;
    
    CGFloat duration = 0.0;
    
    if (animated) {
        duration = 0.25;
    }
    
    if (on) {
        
        [UIView animateWithDuration:duration animations:^{
            self.outerView.backgroundColor = [TSCThemeManager shared].theme.mainColor;
            self.innerView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        }];
        
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
    } else {
        
		[UIView animateWithDuration:duration * 2 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.5 options:kNilOptions animations:^{
			self.outerView.backgroundColor = self.tintColor;
			self.innerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
		} completion:nil];

        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
    }
    
    if (self.checkIdentifier && save) {
        [[NSUserDefaults standardUserDefaults] setBool:on forKey:[NSString stringWithFormat:@"TSCCheckItem%@", self.checkIdentifier]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)setOn:(BOOL)on animated:(BOOL)animated
{
    [self setOn:on animated:animated saveState:NO];
}

- (void)handleTap:(id)sender
{
    [self setOn:!self.isOn animated:YES saveState:YES];
}

- (void)setOnTintColor:(UIColor *)onTintColor
{
    _onTintColor = onTintColor;
    
    if (self.isOn) {
        self.outerView.backgroundColor = onTintColor;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.allowsUserInteraction) {
        return [super pointInside:point withEvent:event];
    } else {
        return false;
    }
}

@end
