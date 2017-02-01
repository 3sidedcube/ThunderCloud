  //
//  TSCContentController.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 10/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#define API_VERSION [[NSBundle mainBundle] infoDictionary][@"TSCAPIVersion"]
#define API_BASEURL [[NSBundle mainBundle] infoDictionary][@"TSCBaseURL"]
#define API_APPID [[NSBundle mainBundle] infoDictionary][@"TSCAppId"]
#define BUGS_VERSION [[NSBundle mainBundle] infoDictionary][@"TSCBugsVersion"]
#define BUILD_DATE [[NSBundle mainBundle] infoDictionary][@"TSCBuildDate"]
#define GOOGLE_TRACKING_ID [[NSBundle mainBundle] infoDictionary][@"TSCGoogleTrackingId"]
#define STATS_VERSION [[NSBundle mainBundle] infoDictionary][@"TSCStatsVersion"]
#define STORM_TRACKING_ID [[NSBundle mainBundle] infoDictionary][@"TSCTrackingId"]
#define DEVELOPER_MODE [[NSUserDefaults standardUserDefaults] boolForKey:@"developer_mode_enabled"]

#import "TSCContentController.h"
#import "untar.h"
#import "TSCDeveloperController.h"
#import "TSCStormLanguageController.h"
#import "TSCListPage.h"
#import "TSCStormObject.h"
#import "TSCStormViewController.h"
#import "TSCStormConstants.h"
@import ThunderRequest;
@import ThunderBasics;
@import CoreSpotlight;

static NSString *TSCCoreSpotlightStormContentDomainIdentifier = @"com.threesidedcube.addressbook";

@implementation TSCContentController

static TSCContentController *sharedController = nil;

+ (TSCContentController *)sharedController
{
    @synchronized(self) {
        
        if (sharedController == nil) {
            
            sharedController = [[self alloc] init];
            
            // This is called here, because if it is called in the init method of TSCContentController it will cause an infinite loop!
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"TSCIndexedInitialBundle"]) {
            
                [sharedController indexAppContentWithCompletion:^(NSError *error) {
                    
                    if (!error) {
                        
                        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"TSCIndexedInitialBundle"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }];
            }
        }
    }
    
    return sharedController;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        if (!API_BASEURL) {
            NSLog(@"<ThunderStorm> [CRITICAL ERROR] TSCBaseURL not defined in info plist");
        }
        
        if (!API_APPID) {
            NSLog(@"<ThunderStorm> [CRITICAL ERROR] TSCAppId not defined info plist");
        }
        
        if (!API_VERSION) {
            NSLog(@"<ThunderStorm> [CRITICAL ERROR] TSCAPIVersion not defined info plist");
        } else if ([API_VERSION isEqualToString:@"latest"]) {
            NSLog(@"<ThunderStorm> [CRITICAL ERROR] TSCAPIVersion is defined as \"Latest\". Please change to correct version before submission");
        } else {
            [self TSC_synchronizeObject:API_VERSION forKey:@"update_api_version"];
        }
        
        if (!BUGS_VERSION) {
            NSLog(@"<ThunderStorm> [CRITICAL ERROR] TSCBugsVersion not defined info plist");
        } else {
            [self TSC_synchronizeObject:BUGS_VERSION forKey:@"bugs_api_version"];
        }
        
        //BUILD DATE
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSString *path = [[NSBundle mainBundle] executablePath];
        NSDictionary *attrs = [fm attributesOfItemAtPath:path error:nil];
        NSDate *creationDate = attrs[NSFileCreationDate];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        
        [self TSC_synchronizeObject:[dateFormatter stringFromDate:creationDate] forKey:@"build_date"];
        //END BUILD DATE
        
        if (!GOOGLE_TRACKING_ID) {
            NSLog(@"<ThunderStorm> [CRITICAL ERROR] TSCGoogleTrackingId not defined info plist");
        }
        
        if(!STATS_VERSION){
            NSLog(@"<ThunderStorm> [CRITICAL ERROR] TSCStatsVersion not defined info plist");
        } else {
            [self TSC_synchronizeObject:STATS_VERSION forKey:@"stats_api_version"];
        }
        
        if(!STORM_TRACKING_ID){
            NSLog(@"<ThunderStorm> [CRITICAL ERROR] TSCTrackingId not defined info plist");
        }
        
        self.baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/apps/%@/update", API_BASEURL, API_VERSION, API_APPID]];
        
        //Setup request kit
        self.requestController = [[TSCRequestController alloc] initWithBaseURL:self.baseURL];
        self.downloadRequestController = [[TSCRequestController alloc] initWithBaseAddress:nil];
        
        //Identify folders for bundle
        self.cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
        self.bundleDirectory = [[NSBundle mainBundle] pathForResource:@"Bundle" ofType:@""];
        
        //Create application support directory
        [[NSFileManager defaultManager] createDirectoryAtPath:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        
        //Temporary cache folder for updates
        self.fileManager = [NSFileManager defaultManager];
        self.temporaryUpdateDirectory = [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/updateCache"];
        
        if (![self.fileManager fileExistsAtPath:self.temporaryUpdateDirectory]) {
            [self.fileManager createDirectoryAtPath:self.temporaryUpdateDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        self.languageController = [TSCStormLanguageController sharedController];
        
        [self TSC_checkForAppUpgrade];
        [self checkForUpdates];
    }
    
    return self;
}

#pragma mark - CoreSpotlight Indexing

- (void)indexAppContentWithCompletion:(TSCCoreSpotlightCompletion)completion
{
    if (NSStringFromClass([CSSearchableIndex class]) && [CSSearchableIndex isIndexingAvailable]) {
//        
        [[NSOperationQueue new] addOperationWithBlock:^{
        
            [self unIndexOldContentWithCompletion:^(NSError *error) {
                
                if (error) {
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        
                        if (completion) {
                            completion(error);
                        }
                    }];

                } else {
                    [self indexNewContentWithCompletion:completion];
                }
            }];
        }];
    }
}

- (void)unIndexOldContentWithCompletion:(TSCCoreSpotlightCompletion)completion
{
    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithDomainIdentifiers:@[TSCCoreSpotlightStormContentDomainIdentifier] completionHandler:^(NSError * _Nullable error) {
       
        if (completion) {
            completion(error);
        }
    }];
}

- (void)indexNewContentWithCompletion:(TSCCoreSpotlightCompletion)completion
{
    NSMutableArray *searchableItems = [NSMutableArray new];
    
    for (NSString *contentFile in [self filesInDirectory:@"pages"]) {
        
        if ([contentFile containsString:@".json"]) {
            
            NSString *pagePath = [self pathForCacheURL:[NSURL URLWithString:[NSString stringWithFormat:@"caches://pages/%@", contentFile]]];
            
            NSData *pageData = [NSData dataWithContentsOfFile:pagePath];
            NSDictionary *pageDictionary = [NSJSONSerialization JSONObjectWithData:pageData options:kNilOptions error:nil];
                        
            NSObject *spotlightObject;
            NSString *uniqueIdentifier = contentFile;
            
            
            if (![pageDictionary[@"class"] isEqualToString:@"TabbedPageCollection"] && ![pageDictionary[@"class"] isEqualToString:@"NativePage"]) {
                
                // Only try allocating because we're running on a background thread and don't want to crash the app if the init method of a storm object needs running on the main thread.
                @try {
                    spotlightObject = [TSCStormObject objectWithDictionary:pageDictionary parentObject:nil];
                }
                @catch (NSException *exception) {
                    NSLog(@"CoreSpotlight indexing tried to index a storm object of class %@ which cannot be allocated on the main thread.\nTo enable it for indexing please make sure any view code is moved out of the -initWithDictionary:parentObject: method", [NSString stringWithFormat:@"TSC%@", pageDictionary[@"class"]]);
                }
                
            } else if ([pageDictionary[@"class"] isEqualToString:@"NativePage"]) {
                
                @try {
                    spotlightObject = [TSCStormViewController viewControllerForNativePageName:pageDictionary[@"name"]];
                    uniqueIdentifier = pageDictionary[@"name"];
                }
                @catch (NSException *exception) {
                    NSLog(@"CoreSpotlight indexing tried to index a native page of name %@ which cannot be allocated on the main thread.\nTo enable it for indexing please make sure any view code is moved out of the -init method", pageDictionary[@"name"]);
                }

            }
            
            if (spotlightObject && [spotlightObject conformsToProtocol:@protocol(TSCCoreSpotlightIndexItem)]) {
                
                id <TSCCoreSpotlightIndexItem> indexableItem = (id <TSCCoreSpotlightIndexItem>)spotlightObject;
                
                if ([indexableItem searchableAttributeSet]) {
                    
                    CSSearchableItem *searchableItem = [[CSSearchableItem alloc] initWithUniqueIdentifier:uniqueIdentifier domainIdentifier:TSCCoreSpotlightStormContentDomainIdentifier attributeSet:indexableItem.searchableAttributeSet];
                    [searchableItems addObject:searchableItem];
                }
            }
            
        }
    }
    
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:searchableItems completionHandler:^(NSError * _Nullable error) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if (completion) {
                completion(error);
            }
        }];
    }];
}

#pragma mark - Bundle Dates

- (NSTimeInterval)originalBundleDate
{
    NSString *manifest = @"manifest.json";
    NSString *bundleManifest = [NSString stringWithFormat:@"%@/%@", self.bundleDirectory, manifest];
    
    if ([self.fileManager fileExistsAtPath:bundleManifest]) {
        
        NSData *data = [NSData dataWithContentsOfFile:bundleManifest];
        NSDictionary *manifest = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        return [manifest[@"timestamp"] doubleValue];
    }
    
    return 0;
}

- (NSTimeInterval)latestBundleDate
{
    NSString *manifest = @"manifest.json";
    NSString *bundleManifest = [NSString stringWithFormat:@"%@/%@", self.bundleDirectory, manifest];
    NSString *cacheManifest = [NSString stringWithFormat:@"%@/%@", self.cacheDirectory, manifest];
    
    if ([self.fileManager fileExistsAtPath:cacheManifest]) {
        
        NSData *data = [NSData dataWithContentsOfFile:cacheManifest];
        NSDictionary *manifest = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        return [manifest[@"timestamp"] doubleValue];
        
    } else if ([self.fileManager fileExistsAtPath:bundleManifest]) {
        
        NSData *data = [NSData dataWithContentsOfFile:bundleManifest];
        NSDictionary *manifest = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        return [manifest[@"timestamp"] doubleValue];
    }
    
    return 0;
}

- (void)TSC_updateSettingsBundle
{
    NSString *manifest = @"manifest.json";
    NSString *bundleManifest = [NSString stringWithFormat:@"%@/%@", self.bundleDirectory, manifest];
    NSString *cacheManifest = [NSString stringWithFormat:@"%@/%@", self.cacheDirectory, manifest];
    
    if ([self.fileManager fileExistsAtPath:cacheManifest]) {
        
        NSData *data = [NSData dataWithContentsOfFile:cacheManifest];
        NSDictionary *manifest = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        [self TSC_synchronizeObject:[manifest[@"timestamp"] stringValue] forKey:@"delta_timestamp"];
        
    } else {
        
        [self TSC_synchronizeObject:@"Unknown" forKey:@"delta_timestamp"];
    }
    
    if ([self.fileManager fileExistsAtPath:bundleManifest]) {
        
        NSData *data = [NSData dataWithContentsOfFile:bundleManifest];
        NSDictionary *manifest = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        [self TSC_synchronizeObject:[manifest[@"timestamp"] stringValue] forKey:@"bundle_timestamp"];
    }
}

- (void)TSC_synchronizeObject:(id)object forKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Update Checking

- (void)checkForUpdates
{
    [self TSC_updateSettingsBundle];
    [self checkForUpdatesWithDate:[self latestBundleDate]];
}

- (void)checkForUpdatesWithDate:(NSTimeInterval)date
{
    self.isCheckingForUpdates = YES;
    NSLog(@"<ThunderStorm> [Updates] Checking for updates with timestamp: %f", date);
    
    NSString *environment;
    
    if([TSCDeveloperController isDevMode]){
        environment = @"test";
    } else {
        environment = @"live";
    }
    
    [self.requestController get:[NSString stringWithFormat:@"?timestamp=%f&density=%@&environment=%@", date, [self isRetina] ? @"x2" : @"x1", environment] completion:^(TSCRequestResponse *response, NSError *error) {
        
        if (!error && response.status == TSCContentUpdatesAvailable) {
            
            if (response.dictionary) {
                
                [self downloadUpdatePackageFromURL:response.dictionary[@"file"]];
                return;
                
            } else if (response.data) {
                
                NSLog(@"<ThunderStorm> [Updates] Downloading update bundle: %@", response.HTTPResponse.URL.absoluteString);
                
                [response.data writeToFile:[self.cacheDirectory stringByAppendingString:@"/data.tar.gz"] atomically:YES];
                
                [self TSC_unpackBundleInDirectory:self.cacheDirectory toDirectory:self.temporaryUpdateDirectory];
                return;
            }
            
        } else if (response.status == TSCContentNoUpdatesAvailable || response.status == TSCContentNoUpdatesAvailableViaRedirect) {
            
            NSLog(@"<ThunderStorm> [Updates] No update found");
            
        } else {
            
            NSLog(@"<ThunderStorm> [Updates] Checking for updates failed (%ld): %@", (long)response.status, error.localizedDescription);
        }
        
        self.isCheckingForUpdates = NO;
    }];
}

- (void)downloadUpdatePackageFromURL:(NSString *)url
{
    if ([TSCDeveloperController isDevMode]) {
        self.downloadRequestController.sharedRequestHeaders[@"TSCAuthenticationToken"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"TSCAuthenticationToken"];
    }
    
    self.downloadRequestController.sharedRequestHeaders[@"User-Agent"] = [TSCStormConstants userAgent];
    
    [self.downloadRequestController get:url completion:^(TSCRequestResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error && response.status == 200) {
            
            [response.data writeToFile:[self.cacheDirectory stringByAppendingString:@"/data.tar.gz"] atomically:YES];
            
            [self TSC_unpackBundleInDirectory:self.cacheDirectory toDirectory:self.temporaryUpdateDirectory];
            
        } else {
            
            NSLog(@"<ThunderStorm> [Updates] Downloading update bundle failed (%li): %@", response.status, error.localizedDescription);
        }
    }];
}

#pragma mark - Update unpacking

- (void)TSC_unpackBundleInDirectory:(NSString *)fromDirectory toDirectory:(NSString *)toDirectory
{
    NSLog(@"<ThunderStorm> [Updates] Unpacking bundle...");
    
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0UL);
    
    dispatch_async(backgroundQueue, ^{
        
        //Delete any leftover files (Should never actually occur)
        [self TSC_removeBundleInDirectory:toDirectory];
        
        //Unpack
        NSError *unpackError = nil;
        NSData *data = [NSData dataWithContentsOfFile:[fromDirectory stringByAppendingString:@"/data.tar.gz"] options:NSDataReadingMappedIfSafe error:&unpackError];
        
        if (!unpackError) {
            
            NSString *archive = @"data.tar";
            
            inflatedData gunzipData = gunzip([data bytes], [data length]);
            NSData *cDecompressed = [NSData dataWithBytes:gunzipData.data length:gunzipData.length];
            
            [cDecompressed writeToFile:[toDirectory stringByAppendingPathComponent:archive] atomically:NO];
            
            FILE *arch = fopen([[toDirectory stringByAppendingPathComponent:archive] cStringUsingEncoding:NSUTF8StringEncoding], "r");
            
            untar(arch, [toDirectory cStringUsingEncoding:NSUTF8StringEncoding]);
            
            fclose(arch);
            
            //Verify
            [self TSC_verifyBundleInDirectory:toDirectory];
            
        } else {
            
            NSLog(@"<ThunderStorm> [Updates] Unpacking bundle failed :%@", unpackError.localizedDescription);
            
            [self TSC_removeCorruptDeltaBundle];
        }
    });
}

- (void)TSC_verifyBundleInDirectory:(NSString *)directory
{
    NSLog(@"<ThunderStorm> [Updates] Verifying bundle...");
    
    BOOL isValid = YES;
    NSString *temporaryUpdateManifestPath = [NSString stringWithFormat:@"%@/manifest.json", self.temporaryUpdateDirectory];
    
    NSError *error = nil;
    NSData *manifestData = [NSData dataWithContentsOfFile:temporaryUpdateManifestPath options:NSDataReadingMappedIfSafe error:&error];
    
    if (!error) {
        
        NSError *dictionaryError = nil;
        NSDictionary *manifest = [NSJSONSerialization JSONObjectWithData:manifestData options:NSJSONReadingMutableContainers error:&dictionaryError];
        
        if (!dictionaryError) {
            
            //Verify App JSON
            
            if (![self fileExistsInBundle:@"app.json"]) {
                
                NSLog(@"<ThunderStorm> [Updates] Missing app JSON");
                isValid = NO;
            }
            
            //Verify Manifest JSON
            
            if (![self fileExistsInBundle:@"manifest.json"]) {
                
                NSLog(@"<ThunderStorm> [Updates] Missing manifest");
                isValid = NO;
            }
            
            //Verify Pages
            
            for (NSDictionary *page in manifest[@"pages"]) {
                
                if (![self fileExistsInBundle:[NSString stringWithFormat:@"pages/%@", page[@"src"]]]) {
                    
                    NSLog(@"<ThunderStorm> [Updates] Missing page:%@", page);
                    isValid = NO;
                }
            }
            
            //Verify Languages
            
            for (NSDictionary *language in manifest[@"languages"]) {
                
                if (![self fileExistsInBundle:[NSString stringWithFormat:@"languages/%@", language[@"src"]]]) {
                    
                    NSLog(@"<ThunderStorm> [Updates] Missing language:%@", language);
                    isValid = NO;
                }
            }
            
            //Verify Content
            
            for (NSDictionary *content in manifest[@"content"]) {
                
                if (![self fileExistsInBundle:[NSString stringWithFormat:@"content/%@", content[@"src"]]]) {
                    
                    NSLog(@"<ThunderStorm> [Updates] Missing content:%@", content);
                    isValid = NO;
                }
            }
        } else {
            
            NSLog(@"<ThunderStorm> [Verification] Failed to parse JSON into dictionary: %@", error.localizedDescription);
            isValid = NO;
        }
    } else {
        
        NSLog(@"<ThunderStorm> [Verification] Failed to read manifest at path: %@\n Error:%@", temporaryUpdateManifestPath, error.localizedDescription);
        isValid = NO;
    }
    
    if (!isValid) {
        [self TSC_removeCorruptDeltaBundle];
    } else {
        
        [self.fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/data.tar.gz", self.cacheDirectory] error:nil];
        [self.fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/data.tar", self.cacheDirectory] error:nil];
        [self TSC_copyValidBundleFromDirectory:directory toDirectory:self.cacheDirectory];
    }
}

- (void)TSC_removeBundleInDirectory:(NSString *)directory
{
    NSError *error = nil;
    
    for (NSString *file in [self.fileManager contentsOfDirectoryAtPath:directory error:&error]) {
        
        BOOL success = [self.fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", directory, file] error:&error];
        
        if (!success || error) {
            NSLog(@"<ThunderStorm> [Updates] Failed to remove file at path: %@", [NSString stringWithFormat:@"%@/%@", directory, file]);
        }
    }
}

- (void)TSC_copyValidBundleFromDirectory:(NSString *)fromDirectory toDirectory:(NSString *)toDirectory
{
    NSError *error = nil;
    
    for (NSString *file in [self.fileManager contentsOfDirectoryAtPath:fromDirectory error:&error]) {
        
        //Check that the file is not a directory
        BOOL isDir;
        
        if ([self.fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", fromDirectory, file] isDirectory:&isDir] && !isDir) {
            
            //Remove file
            [self.fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", toDirectory, file] error:nil];
            
            //Copy new file
            BOOL success = [self.fileManager copyItemAtPath:[NSString stringWithFormat:@"%@/%@", fromDirectory, file] toPath:[NSString stringWithFormat:@"%@/%@", toDirectory, file] error:&error];
            
            if (!success || error) {
                NSLog(@"<ThunderStorm> [Updates] Failed to copy file into bundle:%@", error.localizedDescription);
            }
        } else {
            
            //Check the sub folder exists in cache
            
            if (![self.fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", toDirectory, file]]) {
                [self.fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", toDirectory, file] withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            //It's a directory, so lets loop that now
            
            for (NSString *subFile in [self.fileManager subpathsAtPath:[NSString stringWithFormat:@"%@/%@", fromDirectory, file]]) {
                
                //Remove file
                [self.fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@/%@", toDirectory, file, subFile] error:nil];
                
                //Copy new file
                BOOL success = [self.fileManager copyItemAtPath:[NSString stringWithFormat:@"%@/%@/%@", fromDirectory, file, subFile] toPath:[NSString stringWithFormat:@"%@/%@/%@", toDirectory, file, subFile] error:&error];
                
                if (!success || error) {
                    NSLog(@"<ThunderStorm> [Updates] Failed to copy file into bundle:%@", error.localizedDescription);
                }
            }
            
            [self TSC_addSkipBackupAttributeToItemsInDirectory:[NSString stringWithFormat:@"%@/%@", toDirectory, file]];
        }
    }
    
    [self TSC_addSkipBackupAttributeToItemsInDirectory:toDirectory];
    [self TSC_updateSettingsBundle];
    
    //Remove temporary cache
    [self TSC_removeBundleInDirectory:self.temporaryUpdateDirectory];
    
    //Remove leftover tar files
    [self.fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/data.tar", self.cacheDirectory] error:nil];
    
    NSLog(@"<ThunderStorm> [Updates] Update complete");
    NSLog(@"<ThunderStorm> [Updates] Refreshing language");
    self.isCheckingForUpdates = NO;
    
    [self indexAppContentWithCompletion:nil];
    
    [[TSCStormLanguageController sharedController] reloadLanguagePack];
    
    if ([TSCDeveloperController isDevMode]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCModeSwitchingComplete" object:nil];
    }
}

- (void)TSC_addSkipBackupAttributeToItemsInDirectory:(NSString *)directory
{
    NSLog(@"<ThunderStorm> [Updates] Begining protection of files in directory: %@", [directory lastPathComponent]);
    
    NSError *error = nil;
    
    for (NSString *file in [self.fileManager contentsOfDirectoryAtPath:directory error:&error]) {
        
        NSURL *fileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", directory, file]];
        assert([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]);
        
        NSError *error = nil;
        BOOL success = [fileURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        
        if (!success) {
            NSLog(@"<ThunderStorm> [Updates] Error excluding %@ from backup %@", [fileURL lastPathComponent], error);
        }
    }
    
    if (error) {
        NSLog(@"<ThunderStorm> [Updates] Failed to open directory to begin file protection:%@", error.localizedDescription);
    } else {
        NSLog(@"<ThunderStorm> [Updates] Completed protection of files in directory: %@", [directory lastPathComponent]);
    }
}

- (void)TSC_removeCorruptDeltaBundle
{
    //Get file size
    NSDictionary *attrs = [self.fileManager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/data.tar.gz", self.cacheDirectory] error:NULL];
    UInt64 result = [attrs fileSize];
    
    //Log removal
    NSLog(@"<ThunderStorm> [Updates] Removing corrupt delta bundle of size: %i bytes", (unsigned int)result);
    
    //Perform deletion
    [self.fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/data.tar.gz", self.cacheDirectory] error:nil];
    [self TSC_removeBundleInDirectory:self.temporaryUpdateDirectory];
}

#pragma mark - Upgrade handling
- (void)TSC_checkForAppUpgrade
{
    // App versioning
    NSString *currentAppVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSString *previousAppVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"TSCLastVersionNumber"];
    
    if (previousAppVersion && ![currentAppVersion isEqualToString:previousAppVersion]) {
        
        NSLog(@"<ThunderStorm> [Upgrades] Upgrade in progress...");
        [self TSC_cleanoutCache];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:@"TSCLastVersionNumber"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)TSC_cleanoutCache
{
    NSFileManager *fm = [NSFileManager defaultManager];
    
    [fm removeItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:@"app.json"] error:nil];
    [fm removeItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:@"manifest.json"] error:nil];
    [fm removeItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:@"pages"] error:nil];
    [fm removeItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:@"content"] error:nil];
    [fm removeItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:@"languages"] error:nil];
    [fm removeItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:@"data"] error:nil];
    
    // Mark the app as needing to re-index on next launch
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"TSCIndexedInitialBundle"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - File Handling

- (BOOL)fileExistsInBundle:(NSString *)file
{
    NSString *fileTemporaryCachePath = [NSString stringWithFormat:@"%@/%@", self.temporaryUpdateDirectory, file];
    NSString *fileCachePath = [NSString stringWithFormat:@"%@/%@", self.cacheDirectory, file];
    NSString *fileBundlePath = [NSString stringWithFormat:@"%@/%@", self.bundleDirectory, file];
    
    NSString *thinnedAssetName = file.lastPathComponent;
    NSString *lastUnderscoreComponent = [thinnedAssetName componentsSeparatedByString:@"_"].lastObject;
    
    if (![lastUnderscoreComponent isEqualToString:thinnedAssetName] && ([lastUnderscoreComponent containsString:@".png"] || [lastUnderscoreComponent containsString:@".jpg"])) {
        thinnedAssetName = [thinnedAssetName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"_%@",lastUnderscoreComponent] withString:@""];
    }
    
    if ([UIImage imageNamed:thinnedAssetName]) {
        return YES;
    }
    
    if (![self.fileManager fileExistsAtPath:fileTemporaryCachePath] && ![self.fileManager fileExistsAtPath:fileCachePath] && ![self.fileManager fileExistsAtPath:fileBundlePath]) {
        
        return NO;
    }
    
    return YES;
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)extension inDirectory:(NSString *)directory
{
    NSString *bundleFile = nil;
    NSString *cacheFile = nil;
    NSString *streamingFile = nil;
    
    if (directory) {
        bundleFile = [NSString stringWithFormat:@"%@/%@/%@.%@", self.bundleDirectory, directory, name, extension];
        cacheFile = [NSString stringWithFormat:@"%@/%@/%@.%@", self.cacheDirectory, directory, name, extension];
        streamingFile = [NSString stringWithFormat:@"%@/%@/%@/%@.%@", self.cacheDirectory, @"Streaming", directory, name, extension];
    } else {
        bundleFile = [NSString stringWithFormat:@"%@/%@.%@", self.bundleDirectory, name, extension];
        cacheFile = [NSString stringWithFormat:@"%@/%@.%@", self.cacheDirectory, name, extension];
        streamingFile = [NSString stringWithFormat:@"%@/%@/%@.%@", self.cacheDirectory, @"Streaming", name, extension];
    }
    
    if ([self.fileManager fileExistsAtPath:cacheFile]) {
        return cacheFile;
    } else if ([self.fileManager fileExistsAtPath:bundleFile]) {
        return bundleFile;
    } else if ([self.fileManager fileExistsAtPath:streamingFile]) {
        return streamingFile;
    }
    
    return nil;
}

- (NSArray *)filesInDirectory:(NSString *)directory
{
    NSMutableArray *files = [[NSMutableArray alloc] init];
    
    [files addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:[self.bundleDirectory stringByAppendingPathComponent:directory] error:nil]];
    [files addObjectsFromArray:[self.fileManager contentsOfDirectoryAtPath:[self.cacheDirectory stringByAppendingPathComponent:directory] error:nil]];
    
    return files;
}

- (NSString *)pathForCacheURL:(NSURL *)url
{
    NSString *lastPathComponent = url.lastPathComponent;
    NSString *extension = url.pathExtension;
    NSString *filename = [lastPathComponent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", extension] withString:@""];
    
    return [self pathForResource:filename ofType:extension inDirectory:url.host];
}

#pragma mark - Page/Stream handling

- (NSDictionary *)pageDictionaryWithURL:(NSURL *)pageURL
{
    NSString *filePath = [self pathForCacheURL:pageURL];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    if (data) {
        return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    } else {
        return nil;
    }
}

- (void)pageWithId:(NSString *)pageId completion:(TSCPageCompletion)completion
{
    NSString *pagePath = [self pathForResource:pageId ofType:@"json" inDirectory:@"pages"];
    TSCListPage *page = [[TSCListPage alloc] initWithContentsOfFile:pagePath];
    completion(page, nil);
}

- (void)pageWithURL:(NSURL *)url completion:(TSCPageCompletion)completion
{
    [self.requestController get:url.absoluteString completion:^(TSCRequestResponse *response, NSError *error) {
        
        if (!error && response.status == 200) {
            
            NSError *pageError = nil;
            NSDictionary *pageDictionary = [NSJSONSerialization JSONObjectWithData:response.data options:NSJSONReadingMutableContainers error:&pageError];
            
            if (!pageError) {
                
                TSCListPage *page = [[TSCListPage alloc] initWithDictionary:pageDictionary parentObject:nil];
                completion(page, nil);
                
            } else {
                
                NSLog(@"<ThunderStorm> [Streaming] Failed to access streamed page at :%@", url.absoluteString);
                
                completion(nil, pageError);
            }
        } else {
            
            completion(nil, error);
        }
    }];
    
    completion(nil, nil);
}

- (NSDictionary *)appDictionary
{
    if (!_appDictionary) {
        
        NSString *appFile = [self pathForResource:@"app" ofType:@"json" inDirectory:nil];
        NSData *data = [NSData dataWithContentsOfFile:appFile];
        NSDictionary *appDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        _appDictionary = appDictionary;
    }
    
    return _appDictionary;
}

- (NSDictionary *)metadataForPageId:(NSString *)pageId
{
    NSArray *map = self.appDictionary[@"map"];
    
    if (!map || ![map isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    __block NSDictionary *metadata = nil;
    
    [map enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (![obj isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        NSDictionary *item = (NSDictionary *)obj;
        
        if (item[@"id"] && [item[@"id"] isKindOfClass:[NSString class]]) {
            
            NSString *identifier = item[@"id"];
            if ([identifier isEqualToString:pageId]) {
                
                metadata = item;
                *stop = true;
            }
        }
    }];

    return metadata;
}

- (NSDictionary *)metadataForPageName:(NSString *)pageName
{
    NSArray *map = self.appDictionary[@"map"];
    
    if (!map || ![map isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    __block NSDictionary *metadata = nil;
    
    [map enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (![obj isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        NSDictionary *item = (NSDictionary *)obj;
        
        if (item[@"name"] && [item[@"name"] isKindOfClass:[NSString class]]) {
            
            NSString *name = item[@"name"];
            if ([name isEqualToString:pageName]) {
                
                metadata = item;
                *stop = true;
            }
        }
    }];
    
    return metadata;
}

#pragma mark - Helper methods

- (BOOL)isRetina
{
    return [[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0);
}

@end
