//
//  TSCHUDButton.m
//  ThunderStorm
//
//  Created by Andrew Hart on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCHUDButton.h"
#import "CAGradientLayer+AutoGradient.h"
#import "UIColor-Expanded.h"

#define BUTTON_CORNER_RADIUS 5

@interface TSCHUDButton ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) UIImageView *supportingImageView;

@end

@implementation TSCHUDButton

- (id)init
{
    if (self = [super init]) {
        [self initialSetupHUDButton];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialSetupHUDButton];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialSetupHUDButton];
    }
    
    return self;
}

- (void)initialSetupHUDButton
{
    self.gradientLayer = [[CAGradientLayer alloc] init];
    
    self.layer.cornerRadius = BUTTON_CORNER_RADIUS;
    self.layer.masksToBounds = YES;
    
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    
    self.supportingImageView = [[UIImageView alloc] init];
    [self addSubview:self.supportingImageView];
    
    [self addTarget:self action:@selector(resetAppearanceToPressedDown) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
    [self addTarget:self action:@selector(resetAppearanceToUnpressed) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel | UIControlEventTouchDragExit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.supportingImageView.frame = CGRectMake(10, 10, self.frame.size.height - 20, self.frame.size.height - 20);
    self.gradientLayer.frame = self.bounds;
}

#pragma mark - Appearance methods

- (void)resetAppearanceToUnpressed
{
    [self.gradientLayer removeFromSuperlayer];
    
    if (self.hudButtonType == HUDButtonTypeBlue) {
        self.gradientLayer = [CAGradientLayer generateGradientLayerWithTopColor:[UIColor colorWithHexString:@"18bbe9"] bottomColor:[UIColor colorWithHexString:@"0982cb"]];
    } else if (self.hudButtonType == HUDButtonTypeGreen) {
        self.gradientLayer = [CAGradientLayer generateGradientLayerWithTopColor:[UIColor colorWithHexString:@"82de00"] bottomColor:[UIColor colorWithHexString:@"49b800"]];
    } else if (self.hudButtonType == HUDButtonTypeRed) {
        self.gradientLayer = [CAGradientLayer generateGradientLayerWithTopColor:[UIColor colorWithHexString:@"e00005"] bottomColor:[UIColor colorWithHexString:@"b90000"]];
    } else {
        self.backgroundColor = [UIColor whiteColor];
        [self setTitleColor:[UIColor colorWithHexString:@"898989"] forState:UIControlStateNormal];
    }
    
    [self resetAppearance];
}

- (void)resetAppearanceToPressedDown
{
    [self.gradientLayer removeFromSuperlayer];
    
    if (self.hudButtonType == HUDButtonTypeBlue) {
        self.gradientLayer = [CAGradientLayer generateGradientLayerWithTopColor:[UIColor colorWithHexString:@"0982cb"] bottomColor:[UIColor colorWithHexString:@"0982cb"]];
    } else if (self.hudButtonType == HUDButtonTypeGreen) {
        self.gradientLayer = [CAGradientLayer generateGradientLayerWithTopColor:[UIColor colorWithHexString:@"49b800"] bottomColor:[UIColor colorWithHexString:@"49b800"]];
    } else if (self.hudButtonType == HUDButtonTypeRed) {
        self.gradientLayer = [CAGradientLayer generateGradientLayerWithTopColor:[UIColor colorWithHexString:@"b90000"] bottomColor:[UIColor colorWithHexString:@"b90000"]];
    } else if (self.hudButtonType == HUDButtonTypeWhite) {
        self.backgroundColor = [UIColor colorWithHexString:@"898989"];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    [self resetAppearance];
}

- (void)resetAppearance
{
    if (self.hudButtonType == HUDButtonTypeWhite) {
        [self.gradientLayer removeFromSuperlayer];
        
        self.layer.borderColor = [UIColor colorWithHexString:@"898989"].CGColor;
        self.layer.borderWidth = 1;
    } else {
        self.gradientLayer.cornerRadius = BUTTON_CORNER_RADIUS;
        
        if (!self.gradientLayer.superlayer) {
            [self.layer insertSublayer:self.gradientLayer atIndex:0];
        }
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0;
        
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

#pragma mark - Setter methods

- (void)setHudButtonType:(HUDButtonType)hudButtonType
{
    _hudButtonType = hudButtonType;
    
    [self resetAppearanceToUnpressed];
}

- (void)setSupportingImage:(UIImage *)supportingImage
{
    _supportingImage = supportingImage;
    
    self.supportingImageView.image = supportingImage;
}

@end
