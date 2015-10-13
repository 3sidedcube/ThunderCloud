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

- (instancetype)init
{
    if (self = [super init]) {
        
        [TSCDeveloperController sharedController];
        self.requestController = [[TSCRequestController alloc] initWithBaseAddress:@"https://auth.cubeapis.com/v1.5"];
    }
    
    return self;
}

/**
 Overiding initialize to make thread safe for shared instance...
 */
+ (void)initialize
{
    if (self == [TSCAuthenticationController class]) {
        sharedInstance = [[self alloc] init];
    }
}

/**
 Return a shared controller instance.
 */
+ (TSCAuthenticationController *)sharedInstance
{
    return sharedInstance;
}

- (void)authenticateUsername:(NSString *)username password:(NSString *)password
{
    [self.requestController post:@"authentication" bodyParams:@{@"username": username, @"password": password} completion:^(TSCRequestResponse *response, NSError *error) {
        
        if(response.status == 200){
            [[NSUserDefaults standardUserDefaults] setObject:response.dictionary[@"token"] forKey:@"TSCAuthenticationToken"];
            [[NSUserDefaults standardUserDefaults] setDouble:[response.dictionary[@"expires"][@"timeout"] doubleValue] forKey:@"TSCAuthenticationTimeout"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCAuthenticationCredentialsSet" object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCAuthenticationFailed" object:nil];
        }
    }];
}

- (void)authenticateUsername:(NSString *)username password:(NSString *)password completion:(TSCAuthenticationRequestCompletion)completion
{
    [self.requestController post:@"authentication" bodyParams:@{@"username":username,@"password":password} completion:^(TSCRequestResponse *response, NSError *error) {
        
        if (error) {
            
            completion(NO,error);
            return;
        }
        
        if(response.status == 200){
            
            [[NSUserDefaults standardUserDefaults] setObject:response.dictionary[@"token"] forKey:@"TSCAuthenticationToken"];
            [[NSUserDefaults standardUserDefaults] setDouble:[response.dictionary[@"expires"][@"timeout"] doubleValue] forKey:@"TSCAuthenticationTimeout"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            completion(YES,nil);
        } else {
            completion(NO,nil);
        }
    }];
}

- (BOOL)isAuthenticated
{
    double expiryTimestamp = [[NSUserDefaults standardUserDefaults] doubleForKey:@"TSCAuthenticationTimeout"];
    NSDate *expiryDate = [NSDate dateWithTimeIntervalSince1970:expiryTimestamp];
    
    if ([expiryDate timeIntervalSinceNow] < 0) {
        
        return NO;
    }
    
    return YES;
}

@end

