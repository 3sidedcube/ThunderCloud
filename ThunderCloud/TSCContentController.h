//
//  TSCContentController.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@class TSCStormLanguageController;
@class TSCListPage;
@class TSCRequestController;

#import <Foundation/Foundation.h>

/** A list of HTTP response codes returned when checking for bundle updates with the Storm Server */
typedef NS_ENUM(NSInteger, TSCContentUpdate) {
    /** A new bundle is available to be downloaded */
    TSCContentUpdatesAvailable = 200,
    /** No new content is available */
    TSCContentNoUpdatesAvailable = 204,
    /** A new bundle is available, after a redirect */
    TSCContentUpdatesAvailableViaRedirect = 303,
    /** No new content is available, after a redirect */
    TSCContentNoUpdatesAvailableViaRedirect = 304
};

/**
 `TSCContentController` is a core piece in ThunderCloud that handles delta updates, loading page data and implements the language controller for Storm.
 */
@interface TSCContentController : NSObject

///---------------------------------------------------------------------------------------
/// @name Initializing a TSCContentController
///---------------------------------------------------------------------------------------

/**
 @abstract The shared instance responsible for serving pages and content throughout a storm app
 */
+ (TSCContentController *)sharedController;

/**
 @abstract The path for the bundle directory bundled with the app at compile time
 */
@property (nonatomic, copy) NSString *bundleDirectory;

/**
 @abstract The path for the directory containing files from any delta updates applied after the app has been launched
 */
@property (nonatomic, copy) NSString *cacheDirectory;

/**
 @abstract The path for the directory that is used for temporary storage when unpacking delta updates
 */
@property (nonatomic, copy) NSString *temporaryUpdateDirectory;

/**
 @abstract The base URL for the app. Typically the address of the storm server
 */
@property (nonatomic, strong) NSURL *baseURL;

/**
 @abstract A dictionary detailing the contents of the app bundle
 */
@property (nonatomic, strong) NSDictionary *appDictionary;

/**
 @abstract A shared file manager for use throughout the content controller for accessing files
 */
@property (nonatomic, strong) NSFileManager *fileManager;

/**
 @abstract A shared request controller for making requests throughout the content controller
 */
@property (nonatomic, strong) TSCRequestController *requestController;

/**
 @abstract The shared language controller used to access localisations throughout the app
 */
@property (nonatomic, strong) TSCStormLanguageController *languageController;

///---------------------------------------------------------------------------------------
/// @name Checking for updates
///---------------------------------------------------------------------------------------

/**
 Asks the content controller to check with the Storm server for updates
 @discussion The timestamp used to check will be taken from the bundle or delta bundle inside of the app
 */
- (void)checkForUpdates;

/**
 Asks the content controller to check with the Storm server for updates
 @param date The NSDate to send to the server as the current bundle version
 @discussion Use this method if you need to request the bundle for a specific timestamp
 */
- (void)checkForUpdatesWithDate:(NSTimeInterval)date;

/**
 @abstract A boolean indicating whether or not the content controller is currently in the process of checking for an update
 */
@property (nonatomic) BOOL isCheckingForUpdates;

///---------------------------------------------------------------------------------------
/// @name Streaming pages
///---------------------------------------------------------------------------------------

typedef void (^TSCPageCompletion)(TSCListPage *page, NSError *error);
typedef void (^TSCFileCompletion)(NSString *filePath, NSError *error);

/**
 @abstract Requests a storm page from the server, as opposed to the apps internal bundle
 @param pageId An NSString of the ID for the page you wish to request
 @param completion The block to fire once the page download is completed
 @warning This feature is unfinished and may have undefined results when used
 */
- (void)pageWithId:(NSString *)pageId completion:(TSCPageCompletion)completion;

/**
 @abstract Requests a storm page from the server, as opposed to the apps internal bundle
 @param url The url of the JSON file that contains storm page information
 @param completion The block to fire once the page download is completed
 @warning This feature is unfinished and may have undefined results when used
 */
- (void)pageWithURL:(NSURL *)url completion:(TSCPageCompletion)completion;

///---------------------------------------------------------------------------------------
/// @name Loading pages and page information
///---------------------------------------------------------------------------------------

/**
 @abstract Requests a page dictionary for a given path
 @param pageURL A NSURL of the page to be loaded
 */
- (NSDictionary *)pageDictionaryWithURL:(NSURL *)pageURL;

/**
 @abstract Requests metadata information for a storm page
 @param pageId The unique identifier of the page to lookup in the bundle
 */
- (NSDictionary *)metadataForPageId:(NSString *)pageId;

///---------------------------------------------------------------------------------------
/// @name Looking up file paths
///---------------------------------------------------------------------------------------

/**
 @abstract Returns the url of a file in the storm bundle
 @param name The name of the file, excluding it's file extension
 @param extension The file extension to look up
 @param directory A specific directory inside of the storm bundle to lookup
 */
- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)extension inDirectory:(NSString *)directory;

/**
 @abstract Returns a file path from a storm cache link
 @param url The storm cache URL to convert
 */
- (NSString *)pathForCacheURL:(NSURL *)url;

/**
 @abstract Used for looking up files in the Storm bundle directory
 @param directory The name of the directory to look source the file list from
 @return An NSArray of file names for files in the given directory
 */
- (NSArray *)filesInDirectory:(NSString *)directory;

/**
 @abstract Cleans out the cache directory of files, causing the controller to fall back to the main bundle
 */
- (void)TSC_cleanoutCache;

/**
 @abstract Starts a downloaad of an update package from the given URL
 @param url The url of the delta bundle
 */
- (void)downloadUpdatePackageFromURL:(NSString *)url;

/**
 @return The timestamp of the bundle contained in the app
 */
- (NSTimeInterval)originalBundleDate;

/**
 @abstract Updates the details of delta bundle timestamps in the settings bundle
 */
- (void)TSC_updateSettingsBundle;

/**
 @abstract This should be called to re-index the application in CoreSpotlight
 */
- (void)indexAppContent;

@end
