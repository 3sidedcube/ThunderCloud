//
//  CAGradientLayer+AutoGradient.h
//  ThunderStorm
//
//  Created by Andrew Hart on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import QuartzCore;
@import UIKit;

@interface CAGradientLayer (AutoGradient)

+ (CAGradientLayer *)generateGradientLayerWithTopColor:(UIColor *)topColor bottomColor:(UIColor *)bottomColor;

@end
