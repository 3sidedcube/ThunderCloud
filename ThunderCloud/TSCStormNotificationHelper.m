//
//  TSCStormNotificationHelper.m
//  ThunderCloud
//
//  Created by Matt Cheetham on 05/11/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

@import UIKit;
@import ThunderRequest;
@import ThunderBasics;
@import MapKit;
#import "TSCStormNotificationHelper.h"

@implementation TSCStormNotificationHelper

+ (void)registerPushToken:(NSData *)pushTokenData
{
    [self registerPushToken:pushTokenData geoTargeted:false];
}

+ (void)registerPushToken:(NSData *)pushTokenData geoTargeted:(BOOL)geoTargeted
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *token = [TSCStormNotificationHelper stringForPushTokenData:pushTokenData];
    
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    body[@"appId"] = [[NSBundle mainBundle] infoDictionary][@"TSCAppId"];
    body[@"token"] = token;
    body[@"idiom"] = @"ios";
    
    // If we're geotargeted lets resend the push token every time
    BOOL shouldResendPush = ![[defaults objectForKey:@"TSCPushToken"] isEqualToString:token] || geoTargeted;
    
    // If we should resend send that token!
    if (shouldResendPush) {
        
        if (geoTargeted) {
            
            // Let's pull the user's location
            [[TSCSingleRequestLocationManager sharedLocationManager] requestCurrentLocationWithAuthorizationType:TSCAuthorizationTypeWhenInUse completion:^(CLLocation *location, NSError *error) {
               
                // If we get a location then we want to always send the push token again to the CMS
                if (location) {
                    
                    body[@"location"] = @{@"type":@"Point",@"coordinates":@[@(location.coordinate.longitude),@(location.coordinate.latitude)]};
                    [self registerPushPayload:body];
                } else {
                    
                    // Otherwise we only want to send it if it has changed
                    if (![[defaults objectForKey:@"TSCPushToken"] isEqualToString:token]) {
                        [self registerPushPayload:body];
                    }
                }
            }];
        } else {
         
            // Only sent if their token has changed since the last time it was registered
            [self registerPushPayload:body];
        }
    }
}

+ (void)registerPushPayload:(NSDictionary *)payload
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *stormBaseURL = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] infoDictionary][@"TSCBaseURL"], [[NSBundle mainBundle] infoDictionary][@"TSCAPIVersion"]];
    
    TSCRequestController *requestController = [[TSCRequestController alloc] initWithBaseAddress:stormBaseURL];
    
    [requestController post:@"push/token" bodyParams:payload completion:^(TSCRequestResponse *response, NSError *error) {
        
        if (error) {
            return;
        }
        
        [defaults setObject:payload[@"token"] forKey:@"TSCPushToken"];
        [defaults synchronize];
    }];
}

+ (NSString *)stringForPushTokenData:(NSData *)pushTokenData
{
    NSString *pushToken = [TSCStormNotificationHelper hexadecimalStringForData:pushTokenData];
    
    NSString *token = [pushToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];

    return token;
}

+ (NSString *)hexadecimalStringForData:(NSData *)data
{
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

@end
