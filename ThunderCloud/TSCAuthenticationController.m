//
//  TSCAuthenticationController.m
//  App Loader
//
//  Created by Matt Cheetham on 15/08/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCAuthenticationController.h"
#import "TSCDeveloperController.h"
@import ThunderRequest;

@implementation TSCAuthenticationController

static id sharedInstance = nil;


- (id)init{
    self = [super init];
    if (self){
        
        [TSCDeveloperController sharedController];
        
        self.requestController = [[TSCRequestController alloc] initWithBaseAddress:@"http://auth.cubeapis.com/v1.5"];
                
    }
    
    return self;
}

/**
 Overiding initialize to make thread safe for shared instance...
 */
+ (void)initialize{
    if (self == [TSCAuthenticationController class]) {
        sharedInstance = [[self alloc] init];
    }
}

/**
 Return a shared controller instance.
 */
+ (TSCAuthenticationController *)sharedInstance{
    return sharedInstance;
}

- (void)authenticateUsername:(NSString *)username password:(NSString *)password
{
    [self.requestController post:@"authentication" bodyParams:@{@"username": username, @"password": password} completion:^(TSCRequestResponse *response, NSError *error) {
        
        if(response.status == 200){
            [[NSUserDefaults standardUserDefaults] setObject:response.dictionary[@"token"] forKey:@"TSCAuthenticationToken"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCAuthenticationCredentialsSet" object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCAuthenticationFailed" object:nil];
        }
        
    }];
}
@end
