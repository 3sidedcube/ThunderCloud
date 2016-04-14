//
//  RCHSplitSponsorBoostView.m
//  ARC Hazards
//
//  Created by Sam Houghton on 22/10/2015.
//  Copyright © 2015 3 SIDED CUBE Design Ltd. All rights reserved.
//

#import "RCHSplitSponsorBoostView.h"
#import "RCHSponsorBoostView.h"
@import ThunderBasics;
@import ThunderCloud;

@interface RCHSplitSponsorBoostView ()

@property (nonatomic, strong) RCHSponsorBoostView *leftView;
@property (nonatomic, strong) RCHSponsorBoostView *centerView;
@property (nonatomic, strong) RCHSponsorBoostView *rightView;
@property (nonatomic, strong) UILabel *sponsorLabel;

@end

@implementation RCHSplitSponsorBoostView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.sponsorLabel.text = [NSString stringWithLocalisationKey:@"" fallbackString:@"Sponsored By"];
        self.sponsorLabel.text = [NSString stringWithLocalisationKey:@"_OBJC_LOCALISATION_NO_FALLBACK"];
        self.sponsorLabel.text = [NSString stringWithLocalisationKey:@"_OBJC_LOCALISATION_FALLBACK" fallbackString:@"FALLBACK STRING \"HEY HUN\""];
        self.sponsorLabel.text = [NSString stringWithLocalisationKey:@"_OBJC_LOCALISATION_PARAMS_NIL_NO_FALLBACK" params:nil];
        self.sponsorLabel.text = [NSString stringWithLocalisationKey:@"_OBJC_LOCALISATION_PARAMS_NO_FALLBACK" params:@{@"HEY":@"SUCKER"} fallbackString:@"HEY {NAME}"];
        
        self.sponsorLabel.attributedText = [NSString attributedStringWithLocalisationKey:@"" fallbackString:@"Sponsored By"];
        self.sponsorLabel.text = [NSString attributedStringWithLocalisationKey:@"_OBJC_ATTR_LOCALISATION_NO_FALLBACK"];
        self.sponsorLabel.text = [NSString attributedStringWithLocalisationKey:@"_OBJC_ATTR_LOCALISATION_FALLBACK" fallbackString:@"FALLBACK STRING \"HEY HUN\""];
        self.sponsorLabel.text = [NSString attributedStringWithLocalisationKey:@"_OBJC_ATTR_LOCALISATION_PARAMS_NIL_NO_FALLBACK" params:nil];
        self.sponsorLabel.text = [NSString attributedStringWithLocalisationKey:@"_OBJC_ATTR_LOCALISATION_PARAMS_FALLBACK" params:@{@"HEY":@"SUCKER"} fallbackString:@"HEY {NAME}"];
        
        self.sponsorLabel.text = [@"Hey Sucker" stringWithLocalisationKey:@"_OBJC_LOCALISATION_FUNC"];
        self.sponsorLabel.text = [[NSString stringWithFormat:@"Hey Son %@", name] stringWithLocalisationKey:@"_OBJC_LOCALISATION_FUNC_2"];
    }
    
    return self;
}

@end
