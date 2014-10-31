//
//  TSCStandardListIem.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 28/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCStandardListItem.h"
#import "TSCLink.h"

@implementation TSCStandardListItem

- (BOOL)shouldDisplaySelectionIndicator
{
    if (self.link.url) {
        
        if ([self.link.url.absoluteString isEqualToString:@""]) {
            return false;
        } else {
            return true;
        }
    } else if ([self.link.linkClass isEqualToString:@"SmsLink"] || [self.link.linkClass isEqualToString:@"EmergencyLink"] || [self.link.linkClass isEqualToString:@"ShareLink"] || [self.link.linkClass isEqualToString:@"TimerLink"]) {
        return true;
    } else {
        return false;
    }
}

@end
