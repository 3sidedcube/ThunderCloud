//
//  UINavigationController+TSCNavigationController.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 11/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "UINavigationController+TSCNavigationController.h"
#import "TSCMediaPlayerViewController.h"
#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>
#import "TSCMultiVideoPlayerViewController.h"
#import "TSCAppLinkController.h"
#import "TSCLink.h"
#import "TSCSplitViewController.h"
#import "TSCStormViewController.h"
#import "TSCContentController.h"
#import "TSCNavigationBarDataSource.h"
#import "NSString+LocalisedString.h"
#import "TSCTabbedPageCollection.h"
#import "TSCNavigationTabBarViewController.h"
#import "TSCImage.h"
#import "TSCQuizPage.h"
#import "TSCStormObject.h"

@import ThunderTable;
@import ThunderBasics;
@import SafariServices;

@interface UINavigationController () <SKStoreProductViewControllerDelegate, MFMessageComposeViewControllerDelegate, TSCNavigationBarDataSource, UINavigationControllerDelegate, SFSafariViewControllerDelegate>

@end

@implementation UINavigationController (TSCNavigationController)

static UINavigationController *sharedController = nil;
static NSMutableDictionary *nativePageLookupDictionary = nil;
static NSString *disclaimerPageId = nil;

+ (UINavigationController *)sharedController
{
    @synchronized(self) {
        
        if (sharedController == nil) {
            sharedController = [[self alloc] init];
        }
    }
    
    return sharedController;
}

- (void)setNeedsNavigationBarAppearanceUpdateWithViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController respondsToSelector:@selector(shouldHideNavigationBar)]) {
        
        id <TSCNavigationBarDataSource> dataSource = (id)viewController;
        
        BOOL hidden = [dataSource shouldHideNavigationBar];
        
        float duration = 0.25;
        
        if (!animated) {
            duration = 0.0;
        }
        
        [UIView animateWithDuration:duration animations:^{
            
            CGFloat alpha = 0;
            
            if (hidden) {
                alpha = 0.0;
            } else {
                alpha = 1.0;
            }
            
            UIView *navigationBarBackgroundView = [self.navigationBar.subviews firstObject];
            navigationBarBackgroundView.alpha = alpha;
            
        } completion:nil];
    }
}

- (void)setNeedsNavigationBarAppearanceUpdateAnimated:(BOOL)animated
{
    [self setNeedsNavigationBarAppearanceUpdateWithViewController:self.topViewController animated:animated];
}

#pragma mark - Ahh push it

- (void)pushVideos:(NSArray *)videos
{
    TSCMultiVideoPlayerViewController *videoPlayer = [[TSCMultiVideoPlayerViewController alloc] initWithVideos:videos];
    UINavigationController *videoPlayerNav = [[UINavigationController alloc] initWithRootViewController:videoPlayer];
    [self presentViewController:videoPlayerNav animated:YES completion:nil];
}

- (void)pushLink:(TSCLink *)link
{
    NSString *extension = link.url.pathExtension;
    NSString *scheme = link.url.scheme;
    NSString *host = link.url.host;
    
    
    if ([scheme isEqualToString:@"mailto"]) {
        if ([[UIApplication sharedApplication] canOpenURL: link.url]) {
            [[UIApplication sharedApplication] openURL:link.url];
        }
    }
    
    if ([scheme isEqualToString:@"itunes"]) {
        [self TSC_handleITunes:link];
    }
    
    if (([extension isEqualToString:@"json"] || [scheme isEqualToString:@"app"]) && ![link.linkClass isEqualToString:@"NativeLink"]) {
        [self TSC_handlePage:link];
    }
    
    if ([extension isEqualToString:@"mp4"]) {
        [self TSC_handleVideo:link];
    }
    
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"] || [link.url.absoluteString hasPrefix:@"www"]) {
        
        if ([host isEqualToString:@"www.youtube.com"]) {
            [self TSC_handleYouTubeVideo:link];
        } else {
            [self TSC_handleWeb:link];
        }
    }
    
    if ([link.linkClass isEqualToString:@"SmsLink"]) {
        [self TSC_handleSMS:link];
    }
    
    if (!nativePageLookupDictionary) {
        nativePageLookupDictionary = [NSMutableDictionary dictionary];
    }
    
    for (NSString *key in [[TSCStormViewController sharedController] nativePageLookupDictionary].allKeys) {
        nativePageLookupDictionary[key] = [[TSCStormViewController sharedController] nativePageLookupDictionary][key];
    }
    
    for (id key in nativePageLookupDictionary) {
        if ([key isEqualToString:link.destination]) {
            [self TSC_handleNativeLinkWithClassName:nativePageLookupDictionary[key]];
        }
    }
    
    if ([scheme isEqualToString:@"tel"]) {
        
        NSURL *telephone = [NSURL URLWithString:[link.url.absoluteString stringByReplacingOccurrencesOfString:@"tel" withString:@"telprompt"]];
        
        if ([[UIApplication sharedApplication] canOpenURL:telephone]) {
            [[UIApplication sharedApplication] openURL:telephone];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"Event", @"category":@"Call", @"action":link.url.absoluteString}];
    }
    
    if ([link.linkClass isEqualToString:@"ShareLink"]) {
        [self TSC_handleShare:link];
    }
    
    if ([link.linkClass isEqualToString:@"EmergencyLink"]) {
        [self TSC_handleEmergencyLink];
    }
    
    if ([link.linkClass isEqualToString:@"AppLink"]) {
        [self TSC_handleAppLink:link];
    }
    
}

- (void)pushNativeViewController:(UIViewController *)nativeViewController animated:(BOOL)animated
{
    [self pushViewController:nativeViewController animated:YES];
}

+ (void)registerNativeLink:(NSString *)nativeLinkName toViewControllerClass:(Class)viewControllerClass
{
    if (!nativePageLookupDictionary) {
        nativePageLookupDictionary = [[TSCStormViewController sharedController] nativePageLookupDictionary];
    }
    NSMutableDictionary *lookupDictionary = nativePageLookupDictionary;
    lookupDictionary[nativeLinkName] = NSStringFromClass(viewControllerClass);
}

- (void)TSC_handleNativeLinkWithClassName:(NSString *)className
{
    Class controllerClass = NSClassFromString(className);
    
    if ([[[[UIApplication sharedApplication] keyWindow] rootViewController] isKindOfClass:[TSCSplitViewController class]]) {
        
        [[TSCSplitViewController sharedController] setRightViewController:[controllerClass new] fromNavigationController:self];
        
    } else {
        
        [self.navigationController pushViewController:[controllerClass new] animated:true];
        
    }
}

- (void)TSC_handleITunes:(TSCLink *)link
{
    NSString *iTunesIdentifier = [[link.url absoluteString] substringFromIndex:9];
    
    int itunesIdentifierInt = [iTunesIdentifier intValue];
    
    [[UINavigationBar appearance] setTintColor:[[TSCThemeManager sharedTheme] primaryLabelColor]];
    
    SKStoreProductViewController *viewController = [[SKStoreProductViewController alloc] init];
    
    viewController.delegate = self;
    [viewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:[NSNumber numberWithInt:itunesIdentifierInt]} completionBlock:^(BOOL result, NSError *error) {
        NSLog(@"result: %i", result);
        NSLog(@"error: %@", error);
    }];
    
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)TSC_handleWeb:(TSCLink *)link
{
    if ([link.linkClass isEqualToString:@"UriLink"]) {
        
        [[UIApplication sharedApplication] openURL:link.url];
        
    } else {
        
        NSOperatingSystemVersion iOS9 = (NSOperatingSystemVersion){9, 0, 0};
        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:iOS9]) {
            
            NSURL *url;;
            
            if (link.url.absoluteString && ([link.url.absoluteString hasPrefix:@"http://"] || [link.url.absoluteString hasPrefix:@"https://"])) {
                url = link.url;
            } else  if (link.url.absoluteString) {
                url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", link.url.absoluteString]];
            }
            
            if (url) {
                
                SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url];
                safariViewController.delegate = self;
                safariViewController.view.tintColor = [[TSCThemeManager sharedTheme] mainColor];
                
                NSOperatingSystemVersion iOS10 = (NSOperatingSystemVersion){10, 0, 0};
                if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:iOS10]) {
                    safariViewController.preferredControlTintColor = [[TSCThemeManager sharedTheme] titleTextColor];
                    safariViewController.preferredBarTintColor = [[TSCThemeManager sharedTheme] mainColor];
                }
                
                [self presentViewController:safariViewController animated:true completion:nil];
            }
            
        } else {
            
            TSCWebViewController *viewController = [[TSCWebViewController alloc] initWithURL:link.url];
            viewController.hidesBottomBarWhenPushed = YES;
            
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            if ([[window rootViewController] isKindOfClass:[TSCSplitViewController class]]) {
                
                if (window.visibleViewController.presentingViewController) {
                    [self pushViewController:viewController animated:true];
                } else {
                    [[TSCSplitViewController sharedController] setRightViewController:viewController fromNavigationController:self];
                }
                
            } else {
                
                [self pushViewController:viewController animated:YES];
                
            }
            
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Visit URL", @"action":link.url.absoluteString}];
    
}

//- (UINavigationController *)navigationController
//{
//    return self;
//}

- (void)TSC_handlePage:(TSCLink *)link
{
    TSCStormViewController *viewController = [[TSCStormViewController alloc] initWithURL:link.url];
    viewController.hidesBottomBarWhenPushed = YES;
    
    //Workaround for tabednavigationnesting
    if([viewController isKindOfClass:[TSCTabbedPageCollection class]] && [self.navigationController.parentViewController isKindOfClass:[TSCTabbedPageCollection class]]) {
        
        TSCTabbedPageCollection *collection = (TSCTabbedPageCollection *)viewController;
        
        NSMutableArray *viewArray = [NSMutableArray array];
        
        for (id viewController in collection.viewControllers) {
            
            if([viewController isKindOfClass:[UINavigationController class]]) {
                
                [viewArray addObject:((UINavigationController *)viewController).viewControllers.firstObject];
                
            }
            
        }
        
        Class tabViewControllerClass = [TSCStormObject classForClassKey:NSStringFromClass([TSCNavigationTabBarViewController class])];
        TSCNavigationTabBarViewController *tabBarView = [[tabViewControllerClass alloc] initWithViewControllers:viewArray];
        tabBarView.viewStyle = TSCNavigationTabBarViewStyleBelowNavigationBar;
        
        [self.navigationController pushViewController:tabBarView animated:true];
        
        return;
        
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if ([NSStringFromClass(viewController.class) isEqualToString:@"TSCQuizPage"]) {
            
            TSCQuizPage *quizPage = (TSCQuizPage *)viewController;
            
            if(quizPage.title) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Quiz", @"action":[NSString stringWithFormat:@"Start %@ quiz", quizPage.title]}];
            }
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            
            UIViewController *visibleViewController = [[[UIApplication sharedApplication] keyWindow] visibleViewController];
            
            if (visibleViewController.navigationController && visibleViewController.presentingViewController) {
                
                UINavigationController *navController = visibleViewController.navigationController;
                [navController pushViewController:viewController animated:true];
                
            } else if ([[[[UIApplication sharedApplication] keyWindow] rootViewController] isKindOfClass:[TSCSplitViewController class]]) {
                
                [[TSCSplitViewController sharedController] setRightViewController:viewController fromNavigationController:self];
                
            } else {
                
                [self.navigationController presentViewController:navController animated:YES completion:nil];
                
            }
            
        } else {
            
            UIViewController *visibleViewController = [[[UIApplication sharedApplication] keyWindow] visibleViewController];
            
            if (visibleViewController.navigationController && visibleViewController.presentingViewController) {
                
                UINavigationController *navController = visibleViewController.navigationController;
                [navController pushViewController:viewController animated:true];
                
            } else if ([[[[UIApplication sharedApplication] keyWindow] rootViewController] isKindOfClass:[TSCSplitViewController class]]) {
                
                [[TSCSplitViewController sharedController] setRightViewController:viewController fromNavigationController:self];
                
            } else {
                
                [self.navigationController pushViewController:viewController animated:YES];
                
            }

        }
    } else {
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)TSC_handleShare:(TSCLink *)link
{
    if (!link.body) {
        return;
    }
    
    UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:@[link.body] applicationActivities:nil];
    [shareController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        if (completed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"App", @"action":[NSString stringWithFormat:@"Share to %@", activityType]}];
            
        }
    }];
    
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if ([shareController respondsToSelector:@selector(popoverPresentationController)]) {
        
        shareController.popoverPresentationController.sourceView = keyWindow;
        shareController.popoverPresentationController.sourceRect = CGRectMake(keyWindow.center.x, CGRectGetMaxY(keyWindow.frame), 100, 100);
        shareController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
        
    }
    
    if ([[[[UIApplication sharedApplication] keyWindow] rootViewController] isKindOfClass:[TSCSplitViewController class]]) {
        
        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            
            [[TSCSplitViewController sharedController] presentViewController:shareController animated:YES completion:nil];
        } else {
            
            [[TSCSplitViewController sharedController].primaryViewController presentViewController:shareController animated:YES completion:nil];
        }
    } else {
        [self presentViewController:shareController animated:YES completion:nil];
    }
}

- (void)TSC_handleYouTubeVideo:(TSCLink *)link
{
    //Extract video ID
    NSString *youtubeId = [link.url.absoluteString componentsSeparatedByString:@"?v="][1];
    
    //Download the file
    NSURLRequest *fileDownload = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/get_video_info?video_id=%@", youtubeId]] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    
    [NSURLConnection sendAsynchronousRequest:fileDownload queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (data.length < 200) {
            
            UIAlertController *unableToPlayAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_YOUTUBEERROR_TITLE" fallbackString:@"An error has occured"] message: [NSString stringWithLocalisationKey:@"_ALERT_YOUTUBEERROR_MESSAGE" fallbackString:@"Sorry, we are unable to play this video. Please try again"] preferredStyle:UIAlertControllerStyleAlert];
            
            [unableToPlayAlert addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_YOUTUBEERROR_BUTTON_OKAY" fallbackString:@"Okay"] style:UIAlertActionStyleCancel handler:nil]];
            [unableToPlayAlert addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_YOUTUBEERROR_BUTTON_RETRY" fallbackString:@"Retry"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self TSC_handleYouTubeVideo:link];
            }]];
            
            [self presentViewController:unableToPlayAlert animated:true completion:nil];
            return;
        }
        
        //Convert data to response string
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        //Break the response into an array by ampersand
        NSArray *parts = [responseString componentsSeparatedByString:@"&"];
        
        //Search for the string that contains video info
        
        BOOL foundStream = NO;
        
        for (NSString *part in parts) {
            
            if ([part rangeOfString:@"url_encoded_fmt_stream_map"].location != NSNotFound) {
                
                foundStream = YES;
                
                //Break out parts to find URL's
                NSArray *streamParts = [[[part stringByRemovingPercentEncoding] stringByReplacingOccurrencesOfString:@"url_encoded_fmt_stream_map" withString:@""] componentsSeparatedByString:@","];
                
                NSMutableDictionary *videoDictionary = [NSMutableDictionary dictionary];
                
                //Loop each version (Multiple quality);
                
                for (NSString *streamPart in streamParts) {
                    
                    NSMutableDictionary *dictionaryForQuality = [NSMutableDictionary dictionary];
                    
                    //Loop each part and convert into dictionary
                    NSArray *urlParts = [streamPart componentsSeparatedByString:@"&"];
                    
                    for (NSString *dictionaryItem in urlParts) {
                        
                        NSArray *keyArray = [dictionaryItem componentsSeparatedByString:@"="];
                        
                        [dictionaryForQuality setObject:keyArray[1] forKey:keyArray[0]];
                    }
                    
                    if (dictionaryForQuality[@"quality"]) {
                        [videoDictionary setObject:dictionaryForQuality forKey:dictionaryForQuality[@"quality"]];
                    } else {
                        break;
                    }
                    
                }
                
                //Check for quality
                NSString *quality;
                
                if (videoDictionary[@"medium"]) {
                    quality = @"medium";
                } else if (videoDictionary[@"small"]) {
                    quality = @"small";
                }
                
                if (quality) {
                    
                    //Present the video
                    TSCMediaPlayerViewController *viewController = [[TSCMediaPlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[[NSString stringWithFormat:@"%@&signature=%@", videoDictionary[quality][@"url"], videoDictionary[quality][@"sig"]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    
                    [self presentViewController:viewController animated:YES completion:nil];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Video", @"action":[NSString stringWithFormat:@"YouTube - %@", link.url.absoluteString]}];
                    
                    break;
                    
                } else {
                    
                    //Present error if no video was returned
                    UIAlertController *unableToPlayAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_YOUTUBEERROR_TITLE" fallbackString:@"An error has occured"] message: [NSString stringWithLocalisationKey:@"_ALERT_YOUTUBEERROR_MESSAGE" fallbackString:@"Sorry, we are unable to play this video. Please try again"] preferredStyle:UIAlertControllerStyleAlert];
                    
                    [unableToPlayAlert addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_YOUTUBEERROR_BUTTON_OKAY" fallbackString:@"Okay"] style:UIAlertActionStyleCancel handler:nil]];
                    [unableToPlayAlert addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_YOUTUBEERROR_BUTTON_RETRY" fallbackString:@"Retry"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        [self TSC_handleYouTubeVideo:link];
                    }]];
                    
                    [self presentViewController:unableToPlayAlert animated:true completion:nil];
                }
            }
        }
        
        if (!foundStream) {
            
            UIAlertController *unableToPlayAlert = [UIAlertController alertControllerWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_YOUTUBEERROR_TITLE" fallbackString:@"An error has occured"] message: [NSString stringWithLocalisationKey:@"_ALERT_YOUTUBEERROR_MESSAGE" fallbackString:@"Sorry, we are unable to play this video. Please try again"] preferredStyle:UIAlertControllerStyleAlert];
            
            [unableToPlayAlert addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_YOUTUBEERROR_BUTTON_OKAY" fallbackString:@"Okay"] style:UIAlertActionStyleCancel handler:nil]];
            [unableToPlayAlert addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_YOUTUBEERROR_BUTTON_RETRY" fallbackString:@"Retry"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self TSC_handleYouTubeVideo:link];
            }]];
            
            [self presentViewController:unableToPlayAlert animated:true completion:nil];
        }
    }];
}

- (void)TSC_handleVideo:(TSCLink *)link
{
    NSString *videoPath = [[TSCContentController sharedController] pathForCacheURL:link.url];
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    
    TSCMediaPlayerViewController *viewController = [[TSCMediaPlayerViewController alloc] initWithContentURL:videoURL];
    for(NSString *attribute in link.attributes){
        if([attribute isEqualToString:@"loopable"]){
            viewController.moviePlayer.repeatMode = MPMovieRepeatModeOne;
        }
    }
    
    [self presentViewController:viewController animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Video", @"action":[NSString stringWithFormat:@"Local - %@", link.title]}];
    
    
}

- (void)TSC_handleSMS:(TSCLink *)link
{
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
    if ([MFMessageComposeViewController canSendText]) {
        
        controller.body = link.body;
        controller.recipients = link.recipients;
        controller.messageComposeDelegate = self;
        controller.navigationBar.tintColor = [[UINavigationBar appearance] tintColor];
        
        [self presentViewController:controller animated:YES completion:^{
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"SMS", @"action":[link.recipients componentsJoinedByString:@","]}];
        
    }
}

- (void)TSC_handleEmergencyLink
{
    NSString *emergencyNumber = [[NSUserDefaults standardUserDefaults] stringForKey:@"emergency_number"];
    
    if (emergencyNumber == nil) {
        
        UIAlertController *noNumberAlertController = [UIAlertController alertControllerWithTitle:[NSString stringWithLocalisationKey:@"_EMERGENCY_NUMBER_MISSING" fallbackString:@"No Emergency Number"] message:[NSString stringWithLocalisationKey:@"_EMERGENCY_NUMBER_DESCRIPTION" fallbackString:@"You have not set an emergency number. Please configure your emergency number below"] preferredStyle:UIAlertControllerStyleAlert];
        
        [noNumberAlertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_BUTTON_CANCEL" fallbackString:@"Cancel"] style:UIAlertActionStyleCancel handler:nil]];
        
        [noNumberAlertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_BUTTON_SAVE" fallbackString:@"Save"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if (noNumberAlertController.textFields.firstObject) {
                [[NSUserDefaults standardUserDefaults] setObject:noNumberAlertController.textFields.firstObject.text forKey:@"emergency_number"];
            }
        }]];
        
        [noNumberAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        [self presentViewController:noNumberAlertController animated:true completion:nil];

    } else {
        
        UIAlertController *callNumberAlertController = [UIAlertController alertControllerWithTitle:emergencyNumber message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [callNumberAlertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_BUTTON_CANCEL" fallbackString:@"Cancel"] style:UIAlertActionStyleCancel handler:nil]];

        [callNumberAlertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_BUTTON_CALL" fallbackString:@"Call"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Call", @"action":@"Custom Emergency Number"}];
            
            NSString *emergencyNumber = [[NSUserDefaults standardUserDefaults] stringForKey:@"emergency_number"];
            NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", emergencyNumber]];
            [[UIApplication sharedApplication] openURL:telURL];
        }]];
        
        [callNumberAlertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_BUTTON_EDIT" fallbackString:@"Edit"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self TSC_handleEditEmergencyNumber];
        }]];
        
        [self presentViewController:callNumberAlertController animated:true completion:nil];
    }
}

- (void)TSC_handleEditEmergencyNumber
{
    UIAlertController *editNumberAlertController = [UIAlertController alertControllerWithTitle:[NSString stringWithLocalisationKey:@"_EMERGENCY_NUMBER_EDIT_TITLE" fallbackString:@"Edit Emergency Number"] message:[NSString stringWithLocalisationKey:@"_EDIT_EMERGENCY_NUMBER_DESCRIPTION" fallbackString:@"Please edit your emergency number"] preferredStyle:UIAlertControllerStyleAlert];
    
    [editNumberAlertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_BUTTON_CANCEL" fallbackString:@"Cancel"] style:UIAlertActionStyleCancel handler:nil]];
    
    [editNumberAlertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_BUTTON_SAVE" fallbackString:@"Save"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (editNumberAlertController.textFields.firstObject) {
            [[NSUserDefaults standardUserDefaults] setObject:editNumberAlertController.textFields.firstObject.text forKey:@"emergency_number"];
        }
    }]];
    
    [editNumberAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [self presentViewController:editNumberAlertController animated:true completion:nil];
}

- (void)TSC_handleAppLink:(TSCLink *)link
{
    TSCAppIdentity *app = [[TSCAppLinkController sharedController] appForId:link.identifier];
    
    // Open the requested app
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", app.launcher, link.destination]]]) {
        
        UIAlertController *switchAppAlertController = [UIAlertController alertControllerWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_APPSWITCH_TITLE" fallbackString:@"Switching Apps"] message:[NSString stringWithLocalisationKey:@"_ALERT_APPSWITCH_MESSAGE" fallbackString:@"We are now switching apps"] preferredStyle:UIAlertControllerStyleAlert];
        
        [switchAppAlertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_APPSWITCH_BUTTON_CANCEL" fallbackString:@"Dismiss"] style:UIAlertActionStyleCancel handler:nil]];
        [switchAppAlertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_APPSWITCH_BUTTON_OK" fallbackString:@"OK"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", app.launcher, link.destination]]];
        }]];
        
        [self presentViewController:switchAppAlertController animated:true completion:nil];
        
    } else { // Take user to the app store
        
        UIAlertController *switchAppAlertController = [UIAlertController alertControllerWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_OPENAPPSTORE_TITLE" fallbackString:@"Open app store?"] message:[NSString stringWithLocalisationKey:@"_ALERT_OPENAPPSTORE_MESSAGE" fallbackString:@"We will now take you to the app store to download this app"] preferredStyle:UIAlertControllerStyleAlert];
        
        [switchAppAlertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_OPENAPPSTORE_BUTTON_CANCEL" fallbackString:@"Dismiss"] style:UIAlertActionStyleCancel handler:nil]];
        [switchAppAlertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_OPENAPPSTORE_BUTTON_OK" fallbackString:@"Open"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", app.iTunesId]]];
        }]];

        [self presentViewController:switchAppAlertController animated:true completion:nil];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma clang diagnostic pop

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    [controller dismissViewControllerAnimated:true completion:nil];
}

@end
