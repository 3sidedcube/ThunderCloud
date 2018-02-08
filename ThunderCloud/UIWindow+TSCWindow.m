//
//  UIWindow+TSCWindow.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 17/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "UIWindow+TSCWindow.h"
#import <ThunderCloud/ThunderCloud-Swift.h>

@implementation UIWindow (TSCWindow)

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ([[NSBundle mainBundle] infoDictionary][@"TSCStormLoginDisabled"]) {
        return;
    }
    
    if (event.type == UIEventSubtypeMotionShake) {
        
        // Attempt to disable editing localisations for app store releases.
        
#ifdef DEBUG
        
        [[TSCLocalisationController sharedController] toggleEditing];

#else
        NSString *provisionPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
        if (provisionPath) {
            [[TSCLocalisationController sharedController] toggleEditing];
        }
#endif
    }
}

@end
