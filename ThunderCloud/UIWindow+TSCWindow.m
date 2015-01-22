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
    if (event.type == UIEventSubtypeMotionShake) {
        
        id shakeToEdit = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"TSCDisableShakeToEdit"];
        if (shakeToEdit) {
            
            if ([shakeToEdit isKindOfClass:[NSNumber class]]) {
                
                if (![shakeToEdit boolValue]) {
                    [[TSCLocalisationController sharedController] toggleEditing];
                }
            }
        } else {
            [[TSCLocalisationController sharedController] toggleEditing];
        }
    }
}

@end
