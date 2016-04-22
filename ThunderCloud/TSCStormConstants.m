//
//  TSCStormConstants.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 24/02/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

#import "TSCStormConstants.h"
@import UIKit;

@implementation TSCStormConstants

+ (NSString *)userAgent
{
    NSString *stormId = [[NSBundle mainBundle] infoDictionary][@"TSCTrackingId"];
    NSMutableString *userAgent = [@"" mutableCopy];

    if (stormId) {
        
        NSArray *components = [stormId componentsSeparatedByString:@"-"];
        if (components.count > 1) {
            [userAgent appendString:[components.firstObject stringByAppendingString:components.lastObject]];
        } else {
            [userAgent appendString:[[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleNameKey] stringByReplacingOccurrencesOfString:@" " withString:@""]];
        }
    } else {
        [userAgent appendString:[[[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleNameKey] stringByReplacingOccurrencesOfString:@" " withString:@""]];
    }

    if ([[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey]) {
        [userAgent appendFormat:@"/%@",[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]];
    }

    NSString *device = [UIDevice currentDevice].model;

    if ([[device lowercaseString] isEqualToString:@"ipad"]) {
        [userAgent appendFormat:@" (%@; CPU OS ", device];
    } else {
        [userAgent appendFormat:@" (%@; CPU %@ OS ", device, device];
    }

    NSArray <NSString *> *vComponents = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    [vComponents enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [userAgent appendFormat:@"%@", obj];
        if (idx != vComponents.count - 1) {
            [userAgent appendFormat:@"_"];
        } else {
            [userAgent appendFormat:@" like Mac OS X)"];
        }
    }];
    
    return userAgent;
    
}

@end
