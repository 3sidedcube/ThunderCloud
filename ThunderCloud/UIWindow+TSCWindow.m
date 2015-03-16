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
        
        // Attempt to disable editing localisations for app store releases.
        NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:@"iTunesMetadata.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
            [[TSCLocalisationController sharedController] toggleEditing];
        }
    }
}

@end
