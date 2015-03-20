//
//  TSCTextField.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 18/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A subclass of `UITextField` which allows for easy customisation of the text insets for the text fields currently displayed text
 */
@interface TSCTextField : UITextField

/**
 @abstract The amount to offset the text by within the field (In comparison to iOS defaults)
 @discussion By default this is (8,0)
 */
@property (nonatomic, assign) CGSize textInsets;

@end
