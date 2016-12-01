//
//  TSCAppLinkController.m
//  ThunderStorm
//
//  Created by Sam Houghton on 29/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCAppLinkController.h"
#import "TSCBadgeController.h"
#import "ThunderCloud/ThunderCloud-Swift.h"

@implementation TSCAppLinkController

static TSCBadgeController *sharedController = nil;

+ (TSCBadgeController *)sharedController
{
    @synchronized(self) {
        
        if (sharedController == nil) {
            sharedController = [[self alloc] init];
        }
    }
    
    return sharedController;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        //Ready for badges
        self.identifiers = [NSMutableArray array];
        
        //Load up badges JSON
        NSURL *identityJSON = [[TSCContentController shared] fileUrlForResource:@"identifiers" withExtension:@"json" inDirectory:@"data"];
        
        if (identityJSON) {
            
            NSData *data = [NSData dataWithContentsOfURL:identityJSON];
            NSDictionary *identitiesJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if ([identitiesJSON isKindOfClass:[NSDictionary class]]) {
                
                for (NSString *appKey in [identitiesJSON allKeys]) {
                    
                    NSMutableDictionary *appInformationJson = [NSMutableDictionary dictionaryWithDictionary:identitiesJSON[appKey]];
                    [appInformationJson setObject:appKey forKey:@"appIdentifier"];
                    TSCAppIdentity *identity = [[TSCAppIdentity alloc] initWithDictionary:appInformationJson];
                    
                    [self.identifiers addObject:identity];
                }
            }
        }
    }
    
    return self;
}

- (TSCAppIdentity *)appForId:(NSString *)appId
{
    if (appId) {
        for (TSCAppIdentity *app in self.identifiers) {
            if ([app.appIdentifier isEqualToString:appId]) {
                return app;
            }
        }
    }
    
    return [[TSCAppIdentity alloc] init];
}

@end
