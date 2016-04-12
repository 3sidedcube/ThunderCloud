//
//  TSCAccordionTabBarItem.m
//  ThunderStorm
//
//  Created by Andrew Hart on 20/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCAccordionTabBarItem.h"
#import "TSCDeveloperController.h"
#import "TSCStormLanguageController.h"
@import ThunderTable;
@import ThunderBasics;

@interface TSCAccordionTabBarItem ()

@property (nonatomic, strong) UIView *bottomBorder;
@property (nonatomic, strong) UIView *topShadow;
@property (nonatomic, strong) UIButton *button;

@end

@implementation TSCAccordionTabBarItem

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag
{
    if (self = [super init]) {
        
        self.title = title;
        self.image = image;
        self.tag = tag;
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        self.titleLabel.text = title;
        [self addSubview:_titleLabel];
        
        self.iconView = [[UIImageView alloc] initWithImage:self.image];
        self.iconView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.iconView];
        
        self.bottomBorder = [[UIView alloc] init];
        self.bottomBorder.backgroundColor = [[[TSCThemeManager sharedTheme] mainColor] colorWithAlphaComponent:0.2];
        
        self.topShadow = [[UIView alloc] init];
        self.topShadow.backgroundColor = [[[TSCThemeManager sharedTheme] mainColor] colorWithAlphaComponent:0.2];
        
        self.button = [[UIButton alloc] init];
        [self.button addTarget:self action:@selector(handleTap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        
        self.extraButton = [[UIButton alloc] init];
        [self addSubview:self.extraButton];
    }
    
    return self;
}

- (void)handleTap
{
    [self.delegate tabBarItemWasPressed:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.selected || self.isFirstItem) {
        
        UIColor *contrastColour = [[[TSCThemeManager sharedTheme] primaryLabelColor] contrastingColor];
        
        self.titleLabel.textColor = contrastColour;
        self.iconView.image = [self tintImageWithColor:contrastColour Image:self.iconView.image];
        
        if (self.contentView) {
            [self addSubview:self.contentView];
            [self.titleLabel removeFromSuperview];
            
        } else {
            [self addSubview:self.titleLabel];
            [self.contentView removeFromSuperview];
        }
    } else {
        [self.contentView removeFromSuperview];
        [self addSubview:self.titleLabel];
        
        UIColor *contrastColour = [[[TSCThemeManager sharedTheme] secondaryColor] contrastingColor];
        
        self.titleLabel.textColor = contrastColour;
        
        self.iconView.image = [self tintImageWithColor:contrastColour Image:self.iconView.image];
    }
    
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    self.iconView.frame = CGRectMake(10, 0, self.iconView.image.size.width*0.8, self.iconView.image.size.height*0.8);
    
    self.iconView.center = CGPointMake(self.iconView.center.x, self.frame.size.height / 2);
    
    float titleLabelX = 16;
    
    if (self.iconView.image) {
        titleLabelX = titleLabelX + self.iconView.image.size.width + 8;
    }
    
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(self.frame.size.width-6-titleLabelX, MAXFLOAT)];
    
    self.titleLabel.frame = CGRectMake(titleLabelX, 0, self.frame.size.width, titleLabelSize.height);
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(self.titleLabel.center.x, self.frame.size.height / 2);
    
    self.contentView.frame = CGRectMake(titleLabelX, 0, self.frame.size.width - titleLabelX - 10, ACCORDION_TAB_BAR_ITEM_HEIGHT);
    
    self.bottomBorder.frame = CGRectMake(0, self.frame.size.height - 1.0, self.frame.size.width, 1.0);
    if (self.isFirstItem) {
        self.bottomBorder.frame = CGRectMake(0, self.frame.size.height - 1.0, self.frame.size.width, 1.0);
    }
    self.topShadow.frame = CGRectMake(0, 0, self.frame.size.width, 1);
    
    if (self.selected || self.isFirstItem) {
        
        self.bottomBorder.backgroundColor = [[[[TSCThemeManager sharedTheme] mainColor] contrastingColor] colorWithAlphaComponent:0.5];
        self.topShadow.backgroundColor = [[[[TSCThemeManager sharedTheme] mainColor] contrastingColor] colorWithAlphaComponent:0.5];
    } else {
        
        self.topShadow.backgroundColor = [[[[TSCThemeManager sharedTheme] secondaryColor] contrastingColor] colorWithAlphaComponent:0.5];
        self.bottomBorder.backgroundColor = [[[[TSCThemeManager sharedTheme] secondaryColor] contrastingColor] colorWithAlphaComponent:0.5];
    }
    
    if (self.navigationLayer.superlayer) {
        [self.navigationLayer removeFromSuperlayer];
    }
    
    [self.bottomBorder removeFromSuperview];
    [self.topShadow removeFromSuperview];
    
    if (self.showTopBorder) {
        [self addSubview:self.topShadow];
    }
    
    UIColor *navigationColor;
    
    if (self.selected || self.isFirstItem) {
        
        if([TSCDeveloperController isDevMode]){
            navigationColor = [[TSCThemeManager sharedTheme] mainColor];
        } else {
            navigationColor = [[TSCThemeManager sharedTheme] mainColor];
            if (self.isFirstItem) {
                navigationColor = [UIColor clearColor];
            }
        }
        
        if (self.isFirstItem) {
            [self addSubview:self.bottomBorder];
        }
    } else {
        
        navigationColor = [[TSCThemeManager sharedTheme] secondaryColor];
        [self addSubview:self.bottomBorder];
    }
    
    self.navigationLayer = [CALayer layer];
    self.navigationLayer.backgroundColor = navigationColor.CGColor;
    [self.layer insertSublayer:self.navigationLayer atIndex:0];
    self.navigationLayer.frame = self.bounds;
    
    self.button.frame = self.bounds;
    
    [self bringSubviewToFront:self.contentView];
    
    CGSize extraButtonSize = [self.extraButton sizeThatFits:CGSizeMake(self.frame.size.width - (self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + 4), 44)];
    extraButtonSize.width = MIN((self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + 4),extraButtonSize.width);
    self.extraButton.frame = CGRectMake(self.frame.size.width - extraButtonSize.width - 4, 0, extraButtonSize.width, 44);
    
    [self bringSubviewToFront:self.extraButton];
    
    if ([[TSCStormLanguageController sharedController] isRightToLeft] && [self isMemberOfClass:[TSCAccordionTabBarItem class]]) {
        
        for (UIView *view in self.subviews) {
            
            view.frame = CGRectMake(self.frame.size.width - view.frame.origin.x - view.frame.size.width, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
            
            if ([view isKindOfClass:[UILabel class]]) {
                
                ((UILabel *)view).textAlignment = NSTextAlignmentRight;
            }
        }
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){});
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    [self layoutSubviews];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
    
    [self layoutSubviews];
}

- (void)setImage:(UIImage *)image
{
    if ([TSCThemeManager isOS7]) {
        _image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        _image = image;
    }
}

- (void)setContentView:(UIView *)contentView
{
    _contentView = contentView;
    
    [self layoutSubviews];
    _contentView.userInteractionEnabled = YES;
}

- (UIImage *)tintImageWithColor:(UIColor *)color Image:(UIImage *)image
{
    CGRect contextRect;
    contextRect.origin.x = 0.0f;
    contextRect.origin.y = 0.0f;
    contextRect.size = CGSizeMake(image.size.width, image.size.height);
    // Retrieve source image and begin image context
    CGSize itemImageSize = CGSizeMake(image.size.width, image.size.height);
    CGPoint itemImagePosition;
    itemImagePosition.x = ceilf((contextRect.size.width - itemImageSize.width) / 2);
    itemImagePosition.y = ceilf((contextRect.size.height - itemImageSize.height) );
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(contextRect.size, NO, [[UIScreen mainScreen] scale]); //Retina support
    else
        UIGraphicsBeginImageContext(contextRect.size);
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    // Setup shadow
    // Setup transparency layer and clip to mask
    CGContextBeginTransparencyLayer(c, NULL);
    CGContextScaleCTM(c, 1.0, -1.0);
    CGContextClipToMask(c, CGRectMake(itemImagePosition.x, -itemImagePosition.y, itemImageSize.width, -itemImageSize.height), [image CGImage]);
    
    // Fill and end the transparency layer
    color = [color colorWithAlphaComponent:1.0];
    
    CGContextSetFillColorWithColor(c, color.CGColor);
    
    contextRect.size.height = -contextRect.size.height;
    CGContextFillRect(c, contextRect);
    CGContextEndTransparencyLayer(c);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

@end
