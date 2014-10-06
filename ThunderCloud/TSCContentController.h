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

typedef enum {
    TSCContentUpdatesAvailable = 200,
    TSCContentNoUpdatesAvailable = 204,
    TSCContentUpdatesAvailableViaRedirect = 303,
    TSCContentNoUpdatesAvailableViaRedirect = 304
} TSCContentUpdate;

@interface TSCContentController : NSObject

@property (nonatomic, strong) NSString *bundleDirectory;
@property (nonatomic, strong) NSString *cacheDirectory;
@property (nonatomic, strong) NSString *temporaryUpdateDirectory;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) NSDictionary *appDictionary;

@property (nonatomic, strong) NSFileManager *fileManager;

@property (nonatomic, strong) TSCRequestController *requestController;
@property (nonatomic, strong) TSCStormLanguageController *languageController;

@property (nonatomic) BOOL isCheckingForUpdates;

typedef void (^TSCPageCompletion)(TSCListPage *page, NSError *error);
typedef void (^TSCFileCompletion)(NSString *filePath, NSError *error);

- (void)pageWithId:(NSString *)pageId completion:(TSCPageCompletion)completion;
- (void)pageWithURL:(NSURL *)url completion:(TSCPageCompletion)completion;
- (NSDictionary *)pageDictionaryWithURL:(NSURL *)pageURL;
- (NSDictionary *)metadataForPageId:(NSInteger)pageId;

+ (TSCContentController *)sharedController;

- (void)checkForUpdates;
- (void)checkForUpdatesWithDate:(NSTimeInterval)date;

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)extension inDirectory:(NSString *)directory;
- (NSString *)pathForCacheURL:(NSURL *)url;
- (NSArray *)filesInDirectory:(NSString *)directory;
- (void)TSC_cleanoutCache;
- (void)downloadUpdatePackageFromURL:(NSString *)url;
- (NSTimeInterval)originalBundleDate;
- (void)TSC_updateSettingsBundle;

@end
