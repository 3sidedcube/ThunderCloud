//
//  UIWindow+TSCWindow.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 17/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "UIWindow+TSCWindow.h"
#import "TSCLocalisationController.h"

@implementation UIWindow (TSCWindow)

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake)
    {

        [[TSCLocalisationController sharedController] toggleEditing];
    }
}

@end
