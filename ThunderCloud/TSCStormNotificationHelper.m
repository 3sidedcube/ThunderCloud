//
//  TSCStormNotificationHelper.m
//  ThunderCloud
//
//  Created by Matt Cheetham on 05/11/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

@import UIKit;
@import ThunderRequest;
#import "TSCStormNotificationHelper.h"

@implementation TSCStormNotificationHelper

+ (void)registerPushToken:(NSData *)pushTokenData
{
    NSString *pushToken = [TSCStormNotificationHelper hexadecimalStringForData:pushTokenData];
    NSLog(@"Converted token:%@", pushToken);
    
    
    NSString *token = [pushToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"TSCPushToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *stormBaseURL = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] infoDictionary][@"TSCBaseURL"], [[NSBundle mainBundle] infoDictionary][@"TSCAPIVersion"]];
    
    TSCRequestController *requestController = [[TSCRequestController alloc] initWithBaseAddress:stormBaseURL];
    
    NSMutableDictionary *body = [[NSMutableDictionary alloc] init];
    body[@"appId"] = [[NSBundle mainBundle] infoDictionary][@"TSCAppId"];
    body[@"token"] = token;
    body[@"idiom"] = @"ios";
    
    [requestController post:@"push/token" bodyParams:body completion:^(TSCRequestResponse *response, NSError *error) {
                
    }];
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
