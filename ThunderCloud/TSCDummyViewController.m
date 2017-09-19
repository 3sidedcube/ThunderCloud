//
//  TSCDummyViewController.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 18/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCDummyViewController.h"
@import ThunderTable;

@interface TSCDummyViewController ()

@end

@implementation TSCDummyViewController

- (id)init
{
    if (self = [super init]) {
        self.view.backgroundColor = [TSCThemeManager sharedManager].theme.backgroundColor;
    }
    
    return self;
}

@end
