//
//  TSCAppViewController.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 23/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCAppViewController.h"
#import "TSCSplitViewController.h"
#import "TSCStormLanguageController.h"
#import "TSCStormObject.h"
#import "ThunderCloud/ThunderCloud-Swift.h"

@interface TSCAppViewController ()

@end

@implementation TSCAppViewController

- (instancetype)init
{
    TSCStormLanguageController *lang = [TSCStormLanguageController new];
    [lang reloadLanguagePack];
    
    NSURL *appPath = [[TSCContentController sharedController] fileUrlForResource:@"app" withExtension:@"json" inDirectory:nil];
    
    NSData *appData = [NSData dataWithContentsOfURL:appPath];
    
    if (appData) {
        
        NSDictionary *appDictionary = [NSJSONSerialization JSONObjectWithData:appData options:kNilOptions error:nil];
        NSURL *vectorPageURL = [NSURL URLWithString:appDictionary[@"vector"]];
        
        self = [super initWithURL:vectorPageURL];
        
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            return self;
        } else {
            
            Class splitViewControllerClass = [TSCStormObject classForClassKey:NSStringFromClass([TSCSplitViewController class])];
            
            [(TSCSplitViewController *)[splitViewControllerClass sharedController] resetSharedController];
            
            
            TSCSplitViewController *splitView = (TSCSplitViewController *)[splitViewControllerClass sharedController];
            [splitView setLeftViewController:self];
            splitView.delegate = splitView;
            
            return (id)splitView;
        }
        
        return self;
    }
    
    NSLog(@"<ThunderStorm> [CRITICAL ERROR] Initializing TSCAppViewController failed. app.json does not exist in Bundle. This is usually caused by a failed bundle download in your Xcode run script.");
    return nil;
}

@end
