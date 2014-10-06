//
//  TSCDummyViewController.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 18/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCDummyViewController.h"

@interface TSCDummyViewController ()

@end

@implementation TSCDummyViewController

- (id)init
{
    self = [super init];
    
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor colorWithRed:0.610 green:1.000 blue:0.237 alpha:1.000];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end