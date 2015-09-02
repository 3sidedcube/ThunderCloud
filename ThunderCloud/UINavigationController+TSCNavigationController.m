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
#import "NSObject+AddedProperties.h"
#import "TSCTabbedPageCollection.h"
#import "TSCNavigationTabBarViewController.h"
#import "TSCImage.h"
#import "TSCQuizPage.h"

@import ThunderTable;
@import ThunderBasics;

@interface UINavigationController () <SKStoreProductViewControllerDelegate, MFMessageComposeViewControllerDelegate, TSCNavigationBarDataSource, UINavigationControllerDelegate>

@end

@implementation UINavigationController (TSCNavigationController)

static UINavigationController *sharedController = nil;
static NSMutableDictionary *nativePageLookupDictionary = nil;
static NSString *disclaimerPageId = nil;
static TSCLink *retryYouTubeLink = nil;

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
            
            CGFloat y = 0;
            CGFloat alpha = 0;
            
            if (hidden) {
                y = - (64 + 20);
                alpha = 0.0;
            } else {
                y = - 20;
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
    
    [self pushViewController:[controllerClass new] animated:YES];
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
        
        TSCWebViewController *viewController = [[TSCWebViewController alloc] initWithURL:link.url];
        viewController.hidesBottomBarWhenPushed = YES;
        
        if ([[[[UIApplication sharedApplication] keyWindow] rootViewController] isKindOfClass:[TSCSplitViewController class]]) {
            
            [[TSCSplitViewController sharedController] setRightViewController:viewController fromNavigationController:self];
            
        } else {
            
            [self pushViewController:viewController animated:YES];
            
        }
        
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Visit URL", @"action":link.url.absoluteString}];
    
}

- (UINavigationController *)navigationController
{
    return self;
}

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
            
            if ([[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentedViewController] isKindOfClass:[UINavigationController class]]) {
                
                UINavigationController *navController = (UINavigationController *)[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentedViewController];
                [navController pushViewController:viewController animated:true];
                
            } else if ([[[[UIApplication sharedApplication] keyWindow] rootViewController] isKindOfClass:[TSCSplitViewController class]]) {
                
                [[TSCSplitViewController sharedController] setRightViewController:viewController fromNavigationController:self];
                
            } else {
                
                [self.navigationController presentViewController:navController animated:YES completion:nil];
                
            }
            
        } else {
            
            if ([[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentedViewController] isKindOfClass:[UINavigationController class]]) {
                
                UINavigationController *navController = (UINavigationController *)[[[[UIApplication sharedApplication] keyWindow] rootViewController] presentedViewController];
                [navController pushViewController:viewController animated:true];
                
            } else if ([[[[UIApplication sharedApplication] keyWindow] rootViewController] isKindOfClass:[TSCSplitViewController class]]) {
                [[TSCSplitViewController sharedController] setRightViewController:viewController fromNavigationController:self];
            } else {
                [self.navigationController pushViewController:viewController animated:true];
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
            retryYouTubeLink = link;
            
            UIAlertView *unableToPlay = [[UIAlertView alloc] initWithTitle:@"An error has occured" message:@"Sorry, we are unable to play this video. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Retry", nil];
            unableToPlay.tag = 2;
            [unableToPlay show];
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
                NSArray *streamParts = [[[part stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"url_encoded_fmt_stream_map" withString:@""] componentsSeparatedByString:@","];
                
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
                    
                    retryYouTubeLink = link;
                    
                    //Present error if no video was returned
                    UIAlertView *unableToPlay = [[UIAlertView alloc] initWithTitle:@"An error has occured" message:@"Sorry, we are unable to play this video. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Retry", nil];
                    unableToPlay.tag = 2;
                    [unableToPlay show];
                }
            }
        }
        
        if (!foundStream) {
            
            retryYouTubeLink = link;
            
            UIAlertView *unableToPlay = [[UIAlertView alloc] initWithTitle:@"An error has occured" message:@"Sorry, we are unable to play this video. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Retry", nil];
            unableToPlay.tag = 2;
            [unableToPlay show];
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
        
        UIAlertView *noNumberAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithLocalisationKey:@"_EMERGENCY_NUMBER_MISSING" fallbackString:@"No Emergency Number"] message:[NSString stringWithLocalisationKey:@"_EMERGENCY_NUMBER_DESCRIPTION" fallbackString:@"You have not set an emergency number. Please configure your emergency number below"] delegate:self cancelButtonTitle:[NSString stringWithLocalisationKey:@"_BUTTON_CANCEL" fallbackString:@"Cancel"] otherButtonTitles:[NSString stringWithLocalisationKey:@"_BUTTON_SAVE" fallbackString:@"Save"], nil];
        noNumberAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        noNumberAlert.tag = 0;
        UITextField *tf = [noNumberAlert textFieldAtIndex:0];
        tf.keyboardType = UIKeyboardTypeNumberPad;
        
        [noNumberAlert show];
        
    } else {
        
        UIAlertView *callNumber = [[UIAlertView alloc] initWithTitle:emergencyNumber message:nil delegate:self cancelButtonTitle:[NSString stringWithLocalisationKey:@"_BUTTON_CANCEL" fallbackString:@"Cancel"] otherButtonTitles:[NSString stringWithLocalisationKey:@"_BUTTON_CALL" fallbackString:@"Call"], [NSString stringWithLocalisationKey:@"_BUTTON_EDIT" fallbackString:@"Edit"], nil];
        callNumber.tag = 1;
        [callNumber show];
    }
}

- (void)TSC_handleAppLink:(TSCLink *)link
{
    TSCAppIdentity *app = [[TSCAppLinkController sharedController] appForId:link.identifier];
    
    [self setAssociativeObject:app forKey:@"appToOpen"];
    [self setAssociativeObject:link forKey:@"linkToOpen"];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", app.launcher, link.destination]]]) {
        
        UIAlertView *switchAppAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_APPSWITCH_TITLE" fallbackString:@"Switching Apps"] message:[NSString stringWithLocalisationKey:@"_ALERT_APPSWITCH_MESSAGE" fallbackString:@"We are now switching apps"] delegate:self cancelButtonTitle:[NSString stringWithLocalisationKey:@"_ALERT_APPSWITCH_BUTTON_CANCEL" fallbackString:@"Dismiss"] otherButtonTitles:[NSString stringWithLocalisationKey:@"_ALERT_APPSWITCH_BUTTON_OK" fallbackString:@"OK"], nil];
        switchAppAlert.tag = 3;
        [switchAppAlert show];
    } else {
        
        UIAlertView *switchAppAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithLocalisationKey:@"_ALERT_OPENAPPSTORE_TITLE" fallbackString:@"Open app store?"] message:[NSString stringWithLocalisationKey:@"_ALERT_OPENAPPSTORE_MESSAGE" fallbackString:@"We will now take you to the app store to download this app"] delegate:self cancelButtonTitle:[NSString stringWithLocalisationKey:@"_ALERT_OPENAPPSTORE_BUTTON_CANCEL" fallbackString:@"Dismiss"] otherButtonTitles:[NSString stringWithLocalisationKey:@"_ALERT_OPENAPPSTORE_BUTTON_OK" fallbackString:@"Open"], nil];
        switchAppAlert.tag = 4;
        [switchAppAlert show];
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 0 && buttonIndex == 1) {
        
        NSString *newNumber = [alertView textFieldAtIndex:0].text;
        [[NSUserDefaults standardUserDefaults] setObject:newNumber forKey:@"emergency_number"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (alertView.tag == 1) {
        
        if (buttonIndex == 2) {
            
            UIAlertView *editNumberAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithLocalisationKey:@"_EMERGENCY_NUMBER_EDIT_TITLE" fallbackString:@"Edit Emergency Number"] message:[NSString stringWithLocalisationKey:@"_EDIT_EMERGENCY_NUMBER_DESCRIPTION" fallbackString:@"Please edit your emergency number"] delegate:self cancelButtonTitle:[NSString stringWithLocalisationKey:@"_BUTTON_CANCEL" fallbackString:@"Cancel"] otherButtonTitles:[NSString stringWithLocalisationKey:@"_BUTTON_SAVE" fallbackString:@"Save"], nil];
            editNumberAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            editNumberAlert.tag = 0;
            UITextField *tf = [editNumberAlert textFieldAtIndex:0];
            tf.keyboardType = UIKeyboardTypeNumberPad;
            tf.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"emergency_number"];
            
            [editNumberAlert show];
            
        } else if (buttonIndex == 1) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Call", @"action":@"Custom Emergency Number"}];
            
            NSString *emergencyNumber = [[NSUserDefaults standardUserDefaults] stringForKey:@"emergency_number"];
            NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", emergencyNumber]];
            [[UIApplication sharedApplication] openURL:telURL];
        }
    }
    
    if (alertView.tag == 2) {
        
        if (buttonIndex == 1) {
            
            [self TSC_handleYouTubeVideo:retryYouTubeLink];
        }
    }
    
    if (alertView.tag == 3) {
        
        if (buttonIndex == 1) {
            
            TSCAppIdentity *appToOpen = (TSCAppIdentity *)[self associativeObjectForKey:@"appToOpen"];
            TSCLink *linkToOpen = (TSCLink *)[self associativeObjectForKey:@"linkToOpen"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", appToOpen.launcher, linkToOpen.destination]]];
        }
    }
    
    if (alertView.tag == 4) {
        
        if (buttonIndex == 1) {
            
            TSCAppIdentity *appToOpen = (TSCAppIdentity *)[self associativeObjectForKey:@"appToOpen"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appToOpen.iTunesId]]];
        }
    }
    
    [self setAssociativeObject:nil forKey:@"appToOpen"];
    [self setAssociativeObject:nil forKey:@"linkToOpen"];
    
}

@end