//
//  TSCStormViewController.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 23/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import UIKit;

@interface TSCStormViewController : UIViewController

@property (nonatomic, strong) NSMutableDictionary *nativePageLookupDictionary;

- (id)initWithURL:(NSURL *)url;

+ (TSCStormViewController *)sharedController;
+ (void)registerNativePageName:(NSString *)nativePageName toViewControllerClass:(Class)viewControllerClass;
+ (Class)classForNativePageName:(NSString *)nativePageName;

@end
