//
//  TSCLink.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCLink.h"
@import ThunderBasics;

@implementation TSCLink

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {

        if ([dictionary class] != [NSNull class]) {
            
            self.title = dictionary[@"title"];
            self.title = TSCLanguageDictionary(dictionary[@"title"]);
            self.url = [NSURL URLWithString:dictionary[@"destination"]];
            self.linkClass = dictionary[@"class"];
            self.attributes = [NSMutableArray array];
            
            if ([self.linkClass isEqualToString:@"SmsLink"]) {
                self.body = TSCLanguageString(dictionary[@"body"][@"content"]);
                self.recipients = [NSMutableArray array];
                
                for (NSString *recipient in dictionary[@"recipients"]) {
                    [self.recipients addObject:recipient];
                }
            }
            
            if ([self.linkClass isEqualToString:@"ShareLink"]) {
                
                self.body = TSCLanguageDictionary(dictionary[@"body"]);
            }
            
            if ([self.linkClass isEqualToString:@"AppLink"]) {
                
                self.identifier = dictionary[@"identifier"];
                self.destination = dictionary[@"destination"];
            }
            
            if ([self.linkClass isEqualToString:@"TimerLink"]) {
                if (dictionary[@"duration"] && [dictionary[@"duration"] isKindOfClass:[NSNumber class]]) {
                    
                    self.duration = [NSNumber numberWithInt:[dictionary[@"duration"] intValue] / 1000];
                }
            }
            
            if ([self.linkClass isEqualToString:@"NativeLink"]) {
                
                self.destination = [[dictionary[@"destination"] componentsSeparatedByString:@"/"] lastObject];
            }
            
            if (self.url || [self.linkClass isEqualToString:@"SmsLink"] || [self.linkClass isEqualToString:@"EmergencyLink"] || [self.linkClass isEqualToString:@"ShareLink"] || [self.linkClass isEqualToString:@"TimerLink"] || [self.linkClass isEqualToString:@"UriLink"]) {
                
                return self;
                
            } else {
                
                return nil;
            }
        }
    }
    
    return nil;
}

- (id)initWithURL:(NSURL *)URL
{
    if (self = [super init]) {
        
        self.title = @"Link";
        self.url = URL;
    
        if (self.url) {
            return self;
        }
    }
    
    return nil;
}

@end
