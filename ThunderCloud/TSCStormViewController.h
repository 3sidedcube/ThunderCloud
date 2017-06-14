//
//  TSCStormViewController.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 23/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import UIKit;

/**
 `TSCStormViewController` can be given a cache URL, in the context of Storm that references a storm page. This class will read out the data at the given file path and run it through storm generation.
 
 This is particularly useful if you want to push to a Storm page from your native pages at any point in the app
 */
@interface TSCStormViewController : UIViewController

///---------------------------------------------------------------------------------------
/// @name Initializing a TSCStormViewController
///---------------------------------------------------------------------------------------
@property (nonatomic, strong, nonnull) NSMutableDictionary *nativePageLookupDictionary;

/**
 Initializes a TSCStormViewController
 @param url The cache URL that points at a JSON file
 @discussion Generally this should be a ListPage in the CMS that you can push to once the object is returned
 */
- (nullable id)initWithURL:(nonnull NSURL *)url;

/**
 Initializes a TSCStormViewController
 @param pageId The page id to initialise the view controller from
 @discussion Generally this should be a ListPage in the CMS that you can push to once the object is returned
 */
- (nullable id)initWithId:(nonnull NSString *)identifier;

/**
 Initializes a TSCStormViewController
 @param name The name of the page in the CMS
 @discussion Generally this should be a ListPage in the CMS that you can push to once the object is returned
 */
- (nullable id)initWithName:(nonnull NSString *)name;

- (nullable TSCStormViewController *)initWithDictionary:(nonnull NSDictionary *)dictionary;

///---------------------------------------------------------------------------------------
/// @name Overriding classes
///---------------------------------------------------------------------------------------

/**
 @abstract The shared instance of a storm view used to register overrides
 */
+ (nonnull TSCStormViewController *)sharedController;

/**
 @abstract To ensure that storm pushes to the native page that you have configured in the CMS. Register it using this method before creating the `TSCAppViewController`
 @param nativePageName The name given to your native page in the CMS
 @param viewControllerClass The class to push to when a link to this page is triggered
 */
+ (void)registerNativePageName:(nonnull NSString *)nativePageName toViewControllerClass:(nonnull Class)viewControllerClass;

/**
 @abstract To ensure that storm pushes to the native page that you have configured in the CMS. Register it using this method before creating the `TSCAppViewController`
 @param nativePageName The name given to your native page in the CMS
 @param storyboardName The storyboard file name that your interface is contained in
 @param bundle The bundle which the storyboard is in
 @param interfaceIdentifier The identifier for the interface file inside your the give storyboard
 */
+ (void)registerNativePageName:(nonnull NSString *)nativePageName inStoryBoardNamed:(nonnull NSString *)storyboardName inBundle:(nullable NSBundle *)bundle withInterfaceIdentifier:(nonnull NSString *)interfaceIdentifier;

/**
 @abstract Look up the view controller for a registered native page name
 @param nativePageName The string of the native page name previously registered
 @discussion Generally this method is used internally by storm but may be useful in the future for other purposes
 */
+ (nullable UIViewController *)viewControllerForNativePageName:(nonnull NSString *)nativePageName;

/**
 @abstract Look up class for a registered native page name
 @param nativePageName The string of the native page name previously registered
 @discussion Generally this method is used internally by storm but may be useful in the future for other purposes
 */
+ (nullable Class)classForNativePageName:(nonnull NSString *)nativePageName;

@end
