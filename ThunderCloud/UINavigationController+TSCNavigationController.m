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

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        
//
//    }
//    return self;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
////    self.delegate = self;
//}
//
//- (void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//}
//
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    [self setNeedsNavigationBarAppearanceUpdateWithViewController:viewController animated:animated];
//}
//
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
//
//
- (void)setNeedsNavigationBarAppearanceUpdateAnimated:(BOOL)animated
{
    [self setNeedsNavigationBarAppearanceUpdateWithViewController:self.topViewController animated:animated];
}
//
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return self.topViewController.preferredStatusBarStyle;
//}

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
    
    if ([extension isEqualToString:@"json"] || [scheme isEqualToString:@"app"]) {
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
    
    for (id key in nativePageLookupDictionary) {
        if ([key isEqualToString:link.destination]) {
            [self TSC_handleNativeLinkWithClassName:nativePageLookupDictionary[key]];
        }
    }
    
    if ([scheme isEqualToString:@"tel"]) {
        
        NSURL *telephone = [NSURL URLWithString:[link.url.absoluteString stringByReplacingOccurrencesOfString:@"tel" withString:@"telprompt"]];
        [[UIApplication sharedApplication] openURL:telephone];
        
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
    
    NSLog(@"Push link %@ | %@", link, self.navigationController);
}

- (void)pushNativeViewController:(UIViewController *)nativeViewController animated:(BOOL)animated
{
    [self pushViewController:nativeViewController animated:YES];
}

+ (void)registerNativeLink:(NSString *)nativeLinkName toViewControllerClass:(Class)viewControllerClass
{
    if (!nativePageLookupDictionary) {
        nativePageLookupDictionary = [[NSMutableDictionary alloc] init];
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
        
        [self pushViewController:viewController animated:YES];
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if ([NSStringFromClass(viewController.class) isEqualToString:@"TSCQuizPage"]) {
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            
            [self.navigationController presentViewController:navController animated:YES completion:nil];
        } else {
            
            [self.navigationController pushViewController:viewController animated:YES];
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

    [self presentViewController:shareController animated:YES completion:nil];
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
        
        if ([TSCThemeManager isOS7]) {
            controller.navigationBar.tintColor = [UIColor whiteColor];
        }
        
        [self presentViewController:controller animated:YES completion:^{
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            
            if ([TSCThemeManager isOS7]) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
            } else {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
            }
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"SMS", @"action":[link.recipients componentsJoinedByString:@","]}];
        
    }
}

- (void)TSC_handleEmergencyLink
{
    NSString *emergencyNumber = [[NSUserDefaults standardUserDefaults] stringForKey:@"emergency_number"];
    
    if (emergencyNumber == nil) {
        
        UIAlertView *noNumberAlert = [[UIAlertView alloc] initWithTitle:TSCLanguageString(@"_EMERGENCY_NUMBER_MISSING") ? TSCLanguageString(@"_EMERGENCY_NUMBER_MISSING") : @"No Emergency Number" message:TSCLanguageString(@"_EMERGENCY_NUMBER_DESCRIPTION") ? TSCLanguageString(@"_EMERGENCY_NUMBER_DESCRIPTION") : @"You have not set an emergency number. Please configure your emergency number below" delegate:self cancelButtonTitle:TSCLanguageString(@"_BUTTON_CANCEL") ? TSCLanguageString(@"_BUTTON_CANCEL") :@"Cancel" otherButtonTitles:TSCLanguageString(@"_BUTTON_SAVE") ? TSCLanguageString(@"_BUTTON_SAVE") :@"Save", nil];
        noNumberAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
        noNumberAlert.tag = 0;
        UITextField *tf = [noNumberAlert textFieldAtIndex:0];
        tf.keyboardType = UIKeyboardTypeNumberPad;
        
        [noNumberAlert show];
        
    } else {
        
        UIAlertView *callNumber = [[UIAlertView alloc] initWithTitle:emergencyNumber message:nil delegate:self cancelButtonTitle:TSCLanguageString(@"_BUTTON_CANCEL") ? TSCLanguageString(@"_BUTTON_CANCEL") :@"Cancel" otherButtonTitles:TSCLanguageString(@"_CALL_BUTTON") ? TSCLanguageString(@"_CALL_BUTTON") :@"Call", TSCLanguageString(@"_EDIT_BUTTON") ? TSCLanguageString(@"_EDIT_BUTTON") :@"Edit", nil];
        callNumber.tag = 1;
        [callNumber show];
    }
}

- (void)TSC_handleAppLink:(TSCLink *)link
{
    TSCAppIdentity *app = [[TSCAppLinkController sharedController] appForId:link.identifier];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", app.launcher, link.destination]]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", app.launcher, link.destination]]];
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
            
            UIAlertView *editNumberAlert = [[UIAlertView alloc] initWithTitle:TSCLanguageString(@"_EMERGENCY_NUMBER_EDIT_TITLE") ? TSCLanguageString(@"_EMERGENCY_NUMBER_EDIT_TITLE") : @"Edit Emergency Number" message:TSCLanguageString(@"_EDIT_EMERGENCY_NUMBER_DESC") ? TSCLanguageString(@"_EDIT_EMERGENCY_NUMBER_DESC") : @"Please edit your emergency number" delegate:self cancelButtonTitle:TSCLanguageString(@"_BUTTON_CANCEL") ? TSCLanguageString(@"_BUTTON_CANCEL") :@"Cancel" otherButtonTitles:TSCLanguageString(@"_SAVE_BUTTON") ? TSCLanguageString(@"_SAVE_BUTTON") :@"Save", nil];
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
}

@end