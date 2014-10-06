//
//  TSCHUDButton.h
//  ThunderStorm
//
//  Created by Andrew Hart on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

#define HUD_BUTTON_HEIGHT 50

typedef enum {
    HUDButtonTypeBlue,
    HUDButtonTypeGreen,
    HUDButtonTypeRed,
    HUDButtonTypeWhite
} HUDButtonType;

@interface TSCHUDButton : UIButton

@property (nonatomic) HUDButtonType hudButtonType;
@property (nonatomic, strong) UIImage *supportingImage;

@end
