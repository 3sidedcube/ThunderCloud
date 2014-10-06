//
//  TSCInlineButton.m
//  ThunderStorm
//
//  Created by Andrew Hart on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCInlineButton.h"
#import "TSCLink.h"

@implementation TSCInlineButton

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    
    if (self) {
        self.title = TSCLanguageDictionary(dictionary[@"title"]);
        
        if (dictionary[@"link"]) {
            self.link = [[TSCLink alloc] initWithDictionary:dictionary[@"link"]];
        } else {
            self.link = [[TSCLink alloc] init];
            self.link.url = [NSURL URLWithString:dictionary[@"destination"]];
            self.link.linkClass = dictionary[@"class"];
            self.link.recipients = dictionary[@"recipients"];
            self.link.body = TSCLanguageDictionary(dictionary[@"body"]);
            if (dictionary[@"duration"] && [dictionary[@"duration"] isKindOfClass:[NSNumber class]]) {
                self.link.duration = [NSNumber numberWithInt:[dictionary[@"duration"] intValue] / 1000];
            }
        }
        /*
        self.bodyText = TSCLanguageDictionary(dictionary[@"body"]);
        NSMutableArray *recipients = [NSMutableArray new];
        
        for (NSString *recipient in dictionary[@"recipients"]) {
            [recipients addObject:recipient];
        }
        
        self.recipients = recipients;*/
    }
    
    return self;
}

@end
