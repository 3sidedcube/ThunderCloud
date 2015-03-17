//
//  TSCQuizResponseTextOption.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizResponseTextOption.h"
@import ThunderBasics;

@interface TSCQuizResponseTextOption () <UIGestureRecognizerDelegate>

@end

@implementation TSCQuizResponseTextOption

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        
        self.title = TSCLanguageDictionary(dictionary);
    }
    
    return self;
}

@end
