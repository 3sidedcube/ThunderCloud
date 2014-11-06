//
//  TSCAppViewController.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 23/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCAppViewController.h"
#import "TSCContentController.h"
#import "TSCSplitViewController.h"
#import "TSCStormLanguageController.h"

@interface TSCAppViewController ()

@end

@implementation TSCAppViewController

- (id)init
{
    TSCStormLanguageController *lang = [TSCStormLanguageController new];
    [lang reloadLanguagePack];
    NSString *appPath = [[TSCContentController sharedController] pathForResource:@"app" ofType:@"json" inDirectory:nil];
    NSDictionary *appDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:appPath] options:kNilOptions error:nil];
    NSURL *vectorPageURL = [NSURL URLWithString:appDictionary[@"vector"]];
    
    self = [super initWithURL:vectorPageURL];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        return self;
    } else {
        
        [[TSCSplitViewController sharedController] resetSharedController];
        TSCSplitViewController *splitView = [TSCSplitViewController sharedController];
        [splitView setLeftViewController:self];
        splitView.delegate = splitView;
        
        return (id)splitView;
    }

    
    return self;
}

@end
