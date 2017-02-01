//
//  TSCStormViewController.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 23/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCStormViewController.h"
#import "TSCContentController.h"
#import "TSCStormObject.h"

static NSString *const TSCStormNativePageStoryboardName =  @"storyboardName";
static NSString *const TSCStormNativePageStoryboardIdentifier =  @"interfaceIdentifier";
static NSString *const TSCStormNativePageStoryboardBundleIdentifier =  @"bundleId";

@interface TSCStormViewController ()

@end

@implementation TSCStormViewController

static TSCStormViewController *sharedController = nil;

+ (TSCStormViewController *)sharedController
{
    @synchronized(self) {
        
        if (sharedController == nil) {
            sharedController = [[self alloc] init];
            sharedController.nativePageLookupDictionary = [[NSMutableDictionary alloc] init];
        }
    }
    
    return sharedController;
}

- (instancetype)initWithURL:(NSURL *)url
{
    NSString *type = url.host;
    
    if ([type isEqualToString:@"native"]) {
        
        NSString *nativePageName = url.lastPathComponent;
        
        id viewController = [TSCStormViewController viewControllerForNativePageName:nativePageName];
        
        return viewController;
    }
    
    if ([type isEqualToString:@"pages"]) {
        
        NSString *pagePath = [[TSCContentController sharedController] pathForCacheURL:url];
        NSData *pageData = [NSData dataWithContentsOfFile:pagePath];
        
        if (!pageData) {
            NSLog(@"No page data for page path: %@", pagePath);
            
            return nil;
        }
        
        NSDictionary *pageDictionary = [NSJSONSerialization JSONObjectWithData:pageData options:kNilOptions error:nil];
        
        TSCStormObject *object = [TSCStormObject objectWithDictionary:pageDictionary parentObject:nil];
        
        return (TSCStormViewController * )object;
    }
    
    return nil;
}

- (TSCStormViewController *)initWithDictionary:(nonnull NSDictionary *)dictionary
{
    TSCStormObject *object = [TSCStormObject objectWithDictionary:dictionary parentObject:nil];
    
    return (TSCStormViewController * )object;
}

- (id)initWithId:(NSString *)identifier
{
    NSURL *url;
    NSDictionary *metadata = [[TSCContentController sharedController] metadataForPageId:identifier];
    
    if (metadata && metadata[@"src"] && [metadata[@"src"] isKindOfClass:[NSString class]]) {
        
        NSString *src = metadata[@"src"];
        url = [NSURL URLWithString:src];
        
        if (url) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"cache://pages/%@.json", identifier]];
        }
        
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"cache://pages/%@.json", identifier]];
    }
    
    if (!url) {
        return nil;
    }
    
    self = [super init];
    return [self initWithURL:url];
}

- (instancetype)initWithName:(NSString *)name
{
    NSURL *url;
    NSDictionary *metadata = [[TSCContentController sharedController] metadataForPageName:name];
    
    if (metadata && metadata[@"src"] && [metadata[@"src"] isKindOfClass:[NSString class]]) {
        
        NSString *src = metadata[@"src"];
        url = [NSURL URLWithString:src];
    }
    
    if (!url) {
        return nil;
    }
    
    self = [super init];
    return [self initWithURL:url];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

+ (void)registerNativePageName:(NSString *)nativePageName toViewControllerClass:(Class)viewControllerClass
{
    NSMutableDictionary *lookupDictionary = [[TSCStormViewController sharedController] nativePageLookupDictionary];
    lookupDictionary[nativePageName] = NSStringFromClass(viewControllerClass);
}

+ (void)registerNativePageName:(NSString *)nativePageName inStoryBoardNamed:(NSString *)storyboardName inBundle:(NSBundle *)bundle withInterfaceIdentifier:(NSString *)interfaceIdentifier
{
    NSMutableDictionary *lookupDictionary = [[TSCStormViewController sharedController] nativePageLookupDictionary];
    lookupDictionary[nativePageName] = @{TSCStormNativePageStoryboardName: storyboardName, TSCStormNativePageStoryboardIdentifier: interfaceIdentifier, TSCStormNativePageStoryboardBundleIdentifier:bundle.bundleIdentifier};
}

+ (UIViewController *)viewControllerForNativePageName:(NSString *)nativePageName
{
    NSMutableDictionary *lookupDictionary = [[TSCStormViewController sharedController] nativePageLookupDictionary];
    
    if ([lookupDictionary[nativePageName] isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *interfaceDictionary = lookupDictionary[nativePageName];
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:interfaceDictionary[TSCStormNativePageStoryboardName] bundle:[NSBundle bundleWithIdentifier:interfaceDictionary[TSCStormNativePageStoryboardBundleIdentifier]]];
        
        return [storyBoard instantiateViewControllerWithIdentifier:interfaceDictionary[TSCStormNativePageStoryboardIdentifier]];
    }
    
    NSString *nativePageClassName = lookupDictionary[nativePageName];
    
    Class class = NSClassFromString(nativePageClassName);
    
    return [[class alloc] init];
}

+ (Class)classForNativePageName:(NSString *)nativePageName
{
    NSMutableDictionary *lookupDictionary = [[TSCStormViewController sharedController] nativePageLookupDictionary];
    NSString *nativePageClassName = lookupDictionary[nativePageName];
    
    Class class = NSClassFromString(nativePageClassName);
    
    return class;
}

@end
