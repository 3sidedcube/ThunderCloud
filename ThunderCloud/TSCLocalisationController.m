//
//  TSCLocalisationController.m
//  ThunderCloud
//
//  Created by Matthew Cheetham on 16/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#define API_VERSION [[NSBundle mainBundle] infoDictionary][@"TSCAPIVersion"]
#define API_BASEURL [[NSBundle mainBundle] infoDictionary][@"TSCBaseURL"]
#define API_APPID [[NSBundle mainBundle] infoDictionary][@"TSCAppId"]

#import "TSCLocalisationController.h"
#import "NSString+LocalisedString.h"
#import "TSCStormLoginViewController.h"
#import "TSCAuthenticationController.h"
#import "TSCLocalisationExplanationViewController.h"
#import <ThunderCloud/ThunderCloud-Swift.h>

@import UIKit;
@import LocalAuthentication;
@import Security;
@import ThunderBasics;
@import ThunderRequest;
@import ThunderTable;

typedef void (^TSCLocalisedViewAction)(UIView *localisedView, UIView *parentView, NSString *string);
typedef void (^TSCNavigationViewControllerRecursionCallback)(UIViewController *visibleViewController, UINavigationController *navigationController, BOOL *stop);
typedef void (^TSCLocalisationRefreshCompletion)(NSError *error);

@interface TSCLocalisationController () <UIGestureRecognizerDelegate, TSCLocalisationEditViewControllerDelegate>

@property (nonatomic, strong) TSCRequestController *requestController;

@property (nonatomic, strong) NSMutableArray *localisations;
@property (nonatomic, strong, readwrite) NSMutableArray *editedLocalisations;
@property (nonatomic, strong, readwrite) NSMutableArray *additionalLocalisedStrings;
@property (nonatomic, strong) NSMutableArray *localisationStrings;

@property (nonatomic, strong) UIView *currentWindowView;
@property (nonatomic, strong) NSMutableArray *gestures;

@property (nonatomic, readwrite) BOOL alertViewIsPresented;

@property (nonatomic, strong) UIWindow *localisationEditingWindow;
@property (nonatomic, strong) UIWindow *activityIndicatorWindow;
@property (nonatomic, strong) UIWindow *loginWindow;
@property (nonatomic, strong) UIWindow *moreInfoWindow;

@property (nonatomic, strong) NSMutableDictionary *localisationsDictionary;

@property (nonatomic, assign) BOOL isReloading;
@property (nonatomic, assign) BOOL needsRedraw;

@property (nonatomic, strong) UIButton *moreButton;

@property (nonatomic, strong) UIGestureRecognizer *activationGesture;
@property (nonatomic, assign) id <NSObject> screenshotObserver;

@end

@implementation TSCLocalisationController

static TSCLocalisationController *sharedController = nil;

+ (TSCLocalisationController *)sharedController
{
    @synchronized(self) {
        
        if (sharedController == nil) {
            sharedController = [self new];
        }
    }
    
    return sharedController;
}

#pragma mark - Activation Methods

- (void)toggleEditing
{

}


#pragma mark - Localisation selection

- (void)recurseSubviewsOfView:(UIView *)recursingView withLocalisedViewAction:(TSCLocalisedViewAction)action
{
	
}

- (void)addHighlightToView:(UIView *)view withString:(NSString *)string
{
 
}

- (void)recurseTableViewHeaderFooterLabelsWithTableViewController:(UITableViewController *)tableViewController action:(TSCLocalisedViewAction)action
{
    NSMutableArray *sectionHeaderFooterTitles = [NSMutableArray new];
    
    for (int i = 0;  i < [tableViewController.tableView numberOfSections]; i++) {
        
        NSString *tableSectionHeaderText = [tableViewController.tableView.dataSource tableView:tableViewController.tableView titleForHeaderInSection:i];
        NSString *tableSectionFooterText = [tableViewController.tableView.dataSource tableView:tableViewController.tableView titleForFooterInSection:i];
        
        if (!tableSectionHeaderText) {
            
            if ([tableViewController.tableView.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
                
                UIView *headerView = [tableViewController.tableView.delegate tableView:tableViewController.tableView viewForHeaderInSection:i];
                [self recurseSubviewsOfView:headerView withLocalisedViewAction:action];
            }
            
        } else {
            [sectionHeaderFooterTitles addObject:tableSectionHeaderText];
        }
        
        if (!tableSectionFooterText) {
            
            if ([tableViewController.tableView.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
                
                UIView *footerView = [tableViewController.tableView.delegate tableView:tableViewController.tableView viewForFooterInSection:i];
                [self recurseSubviewsOfView:footerView withLocalisedViewAction:action];
            }
            
        } else {
            [sectionHeaderFooterTitles addObject:tableSectionFooterText];
        }
    }
    
    NSMutableArray *unlocalisedHeaderFooterTitles = [NSMutableArray new];
    for (NSString *string in sectionHeaderFooterTitles) {
        
        if (!string.localisationKey) {
            [unlocalisedHeaderFooterTitles addObject:string];
        }
    }
    
    [sectionHeaderFooterTitles removeObjectsInArray:unlocalisedHeaderFooterTitles];
    
    [self.additionalLocalisedStrings addObjectsFromArray:sectionHeaderFooterTitles];
}

- (void)removeLocalisationHightlights:(NSArray *)subviews
{
    for (UIView *view in subviews) {
        
        if (view.tag == 635355756) {
            [view removeFromSuperview];
        }
        
        if ([view isKindOfClass:[UILabel class]]) {
            
            UILabel *label = (UILabel *)view;
            
            if (label.text.localisationKey != nil) {
                
                [self removeLocalisationHightlights:label.subviews];
                label.userInteractionEnabled = NO;
                continue;
            }
        }
        
        if ([view isKindOfClass:[UITextView class]]) {
            
            UITextView *textView = (UITextView *)view;
            
            if (textView.text.localisationKey != nil) {
                
                [self removeLocalisationHightlights:textView.subviews];
                textView.userInteractionEnabled = NO;
                continue;
            }
        }
        
        [self removeLocalisationHightlights:view.subviews];
    }
}

#pragma mark - Gestures

- (void)addGesturesToView:(UIView *)view
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentLocalisationEditViewController:)];
    view.userInteractionEnabled = YES;
    tap.delegate = self;
    [self.gestures addObject:tap];
    [view addGestureRecognizer:tap];
}

- (void)removeGesturesFromView:(UIView *)view
{
    for (UIGestureRecognizer *viewGesture in view.gestureRecognizers) {
        
        for (UIGestureRecognizer *gesture in self.gestures) {
            
            if (viewGesture == gesture) {
                [view removeGestureRecognizer:viewGesture];
            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

#pragma mark - Localisation presenting

- (void)presentLocalisationEditViewController:(UITapGestureRecognizer *)gesture
{
    CGPoint touchPoint = [gesture locationInView:gesture.view];
    UIView *view = [gesture.view hitTest:touchPoint withEvent:nil];
    
    NSString *localisedString; // The string from the bundle
    
    if ([view isKindOfClass:[UILabel class]]) {
        
        UILabel *label = (UILabel *)view;
        
        if (label.text.localisationKey) {
            localisedString = label.text;
        }
    }
    
    if ([view isKindOfClass:[UITextView class]]) {
        
        UITextView *textView = (UITextView *)view;
        
        if (textView.text.localisationKey) {
            localisedString = textView.text;
        }
    }
    
    if (localisedString) {
        
        [self presentLocalisationEditViewControllerWithLocalisation:localisedString];
        return;
    }
    
    if ([view isKindOfClass:[UINavigationBar class]]) {
        
        UINavigationBar *navBar = (UINavigationBar *)gesture.view;
        self.localisationStrings = [NSMutableArray new];
        [self handleNavigationSelection:navBar.subviews];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose a localisation" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        for (NSString *localString in self.localisationStrings) {
            
            [alert addAction:[UIAlertAction actionWithTitle:localString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self presentLocalisationEditViewControllerWithLocalisation:localString];
            }]];
        }
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        
        [[UIApplication sharedApplication].keyWindow.visibleViewController presentViewController:alert animated:true completion:nil];
    }
}

- (void)presentLocalisationEditViewControllerWithLocalisation:(NSString *)localisedString
{
    
    Localisation *localisation = [self CMSLocalisationForKey:localisedString.localisationKey];
    
    __block TSCLocalisationEditViewController *editViewController;
    if (localisation) {
            
        editViewController = [[TSCLocalisationEditViewController alloc] initWithLocalisation:localisation];
        
    } else {
        
        editViewController = [[TSCLocalisationEditViewController alloc] initWithKey:localisedString.localisationKey];
    }
    
    if (editViewController) {
        
        editViewController.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editViewController];
        
        [navController.navigationBar setTintColor:[UIColor blackColor]];
        [navController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
        [navController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [navController.navigationBar setBarTintColor:[UIColor whiteColor]];
        
        self.localisationEditingWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.localisationEditingWindow.rootViewController = navController;
        self.localisationEditingWindow.windowLevel = UIWindowLevelAlert+1;
        self.localisationEditingWindow.hidden = false;
        
        self.localisationEditingWindow.transform = CGAffineTransformMakeTranslation(0, self.localisationEditingWindow.frame.size.height);
        
        [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:kNilOptions animations:^{
            self.localisationEditingWindow.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

- (void)handleNavigationSelection:(NSArray *)subviews
{
    for (UIView *view in subviews) {
        
        if ([view isKindOfClass:[UILabel class]]) {
            
            UILabel *label = (UILabel *)view;
            
            if (label.text.localisationKey != nil) {
                [self.localisationStrings addObject:label.text];
                continue;
            }
        }
        
        if ([view isKindOfClass:[UITextView class]]) {
            
            UITextView *textView = (UITextView *)view;
            
            if (textView.text.localisationKey != nil) {
                [self.localisationStrings addObject:textView.text];
                continue;
            }
        }
        
        if (view != self.currentWindowView) {
            [self handleNavigationSelection:view.subviews];
        }
    }
}

- (Localisation *)CMSLocalisationForKey:(NSString *)key
{
    __block Localisation *foundLocalisation;
    
    [self.localisations enumerateObjectsUsingBlock:^(Localisation *localisation, NSUInteger idx, BOOL *stop){
        
        if ([localisation.localisationKey isEqualToString:key]) {
            foundLocalisation = localisation;
            *stop = YES;
        }
    }];
    
    return foundLocalisation;
}

#pragma mark - Showing more info

- (void)showMoreButton
{
    UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    
    self.moreButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 26, 44, 44)];
    self.moreButton.alpha = 0.0;
    [self.moreButton addTarget:self action:@selector(showMoreInfo) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *buttonImage = [UIImage imageNamed:@"localisations-morebutton" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    [self.moreButton setImage:buttonImage forState:UIControlStateNormal];
    [mainWindow addSubview:self.moreButton];
    [mainWindow bringSubviewToFront:self.moreButton];
    
    [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.8 options:kNilOptions animations:^{
        
        self.moreButton.alpha = 1.0;
    } completion:nil];
}

- (void)showMoreInfo
{
    TSCLocalisationExplanationViewController *explanationViewController = [TSCLocalisationExplanationViewController new];
    
    __weak typeof(self) welf = self;
    [explanationViewController setTSCLocalisationDismissHandler:^{
       
        if (welf) {
            
            welf.localisationEditingWindow.hidden = true;
            welf.localisationEditingWindow = nil;
            
            if (welf.needsRedraw) {
                [welf redrawViewsWithEditedLocalisations];
            }
        }
    }];
    
    self.localisationEditingWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.localisationEditingWindow.rootViewController = explanationViewController;
    self.localisationEditingWindow.windowLevel = UIWindowLevelAlert;
    self.localisationEditingWindow.hidden = false;
}

#pragma mark - Saving localisations

- (void)registerLocalisationEdited:(Localisation *)localisation
{
    if (!self.editedLocalisations) {
        self.editedLocalisations = [NSMutableArray array];
    }
    
    if (![self.editedLocalisations containsObject:localisation]) {
        [self.editedLocalisations addObject:localisation];
    }
    
    // Because we are letting the user add new keys to the CMS we want to make sure they can't add them multiple times.
    if (![self.localisations containsObject:localisation]) {
        [self.localisations addObject:localisation];
    }
}

- (void)saveLocalisations:(TSCLocalisationSaveCompletion)completion
{
    NSMutableDictionary *localisationsDictionary = [NSMutableDictionary new];
    __block NSMutableArray *editedLocalisations = [self.editedLocalisations mutableCopy];
    
    for (Localisation *localisation in editedLocalisations) {
        
        localisationsDictionary[localisation.localisationKey] = [localisation serialisableRepresentation];
        self.localisationsDictionary[localisation.localisationKey] = [localisation serialisableRepresentation];
    }
    
    NSDictionary *payloadDictionary = @{@"strings":localisationsDictionary};
    self.editedLocalisations = [NSMutableArray new];
    
    [self showActivityIndicatorWithTitle:@"Saving"];
    [self.requestController put:@"native" bodyParams:payloadDictionary completion:^(TSCRequestResponse *response, NSError *error) {
        
        if (error) {
            
            [self.editedLocalisations addObjectsFromArray:editedLocalisations]; // If we error when saving, let's add them back into the array to save later.
            completion(error);
            return;
        }
        [self dismissActivityIndicator];
        
        completion (nil);
    }];
}

#pragma mark - Server interaction

- (void)fetchLocalisations:(TSCLocalisationFetchCompletion)completion
{
    [self.requestController get:@"native" completion:^(TSCRequestResponse *response, NSError *error) {
        
        if (error) {
            
            completion(nil, error);
            return;
        }
        
        NSMutableArray *localisations = [NSMutableArray array];
        
        if ([response.dictionary respondsToSelector:@selector(allKeys)]) {
            
            for (NSString *localisationKey in response.dictionary.allKeys) {
                
                NSDictionary *localisationDictionary = response.dictionary[localisationKey];
                Localisation *newLocalisation = [[Localisation alloc] initWithDictionary:localisationDictionary];
                newLocalisation.localisationKey = localisationKey;
                [localisations addObject:newLocalisation];
            }
        }
        
        self.localisations = [NSMutableArray arrayWithArray:localisations];
        completion(localisations, nil);
    }];
}

- (void)fetchAvailableLanguagesForApp:(TSCLocalisationFetchLanguageCompletion)completion
{
    [self.requestController get:@"languages" completion:^(TSCRequestResponse *response, NSError *error) {
        
        if (error || response.status != 200) {
            
            completion(nil, error);
            return;
        }
        
        NSMutableArray *languages = [NSMutableArray array];
        for (NSDictionary *languageDictionary in response.array) {
            
            TSCLocalisationLanguage *newLanguage = [[TSCLocalisationLanguage alloc] initWithDictionary:languageDictionary];
            [languages addObject:newLanguage];
        }
        
        self.availableLanguages = languages;
        
        completion(languages, nil);
    }];
}

#pragma mark - Localisation Edit View Controller Delegate

- (void)editingCancelledInViewController:(TSCLocalisationEditViewController *)viewController
{
    
    [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:kNilOptions animations:^{
        
        self.localisationEditingWindow.transform = CGAffineTransformMakeTranslation(0, self.localisationEditingWindow.frame.size.height);
    } completion:^(BOOL finished) {
        
        if (finished) {
            
            [self.localisationEditingWindow resignKeyWindow];
            self.localisationEditingWindow.hidden = true;
            self.localisationEditingWindow = nil;
        }
    }];
}

- (void)editingSavedInViewController:(TSCLocalisationEditViewController *)viewController
{
    
    if (viewController) {
        
        [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:kNilOptions animations:^{
            
            self.localisationEditingWindow.transform = CGAffineTransformMakeTranslation(0, self.localisationEditingWindow.frame.size.height);
        } completion:^(BOOL finished) {
            
            if (finished) {
                
                [self.localisationEditingWindow resignKeyWindow];
                self.localisationEditingWindow.hidden = true;
                self.localisationEditingWindow = nil;
            }
        }];
        
        [self redrawViewsWithEditedLocalisations];
    } else {
        
        self.needsRedraw = true;
    }
}

- (void)redrawViewsWithEditedLocalisations
{
    for (Localisation *localisation in self.editedLocalisations) {
        
        self.localisationsDictionary[localisation.localisationKey] = [localisation serialisableRepresentation];
    }
    
    UIWindow *highestWindow = [[UIApplication sharedApplication] keyWindow];
    UIViewController *visibleViewController = highestWindow.visibleViewController;
    
    if (visibleViewController.navigationController.navigationBar && !visibleViewController.navigationController.navigationBarHidden) {
        
        [self recurseSubviewsOfView:visibleViewController.navigationController.navigationBar withLocalisedViewAction:^(UIView *view, UIView *parentView, NSString *string) {
        
            [self reloadLocalisedView:view inParentView:parentView];
        }];
    }
    
    if (visibleViewController.tabBarController.tabBar && !visibleViewController.tabBarController.tabBar.hidden) {
        
        [self recurseSubviewsOfView:visibleViewController.tabBarController.tabBar withLocalisedViewAction:^(UIView *view, UIView *parentView, NSString *string) {
            
            [self reloadLocalisedView:view inParentView:parentView];
        }];
    }
    
    // Get main view controller and remove highlights
    if (visibleViewController.view) {
        
        [self recurseSubviewsOfView:visibleViewController.view withLocalisedViewAction:^(UIView *view, UIView *parentView, NSString *string) {
            
            [self reloadLocalisedView:view inParentView:parentView];
        }];
    }
    
    // Get tableView controller
    if ([visibleViewController isKindOfClass:[UITableViewController class]]) {
        
        UITableViewController *tableViewController = (UITableViewController *)visibleViewController;
        [self recurseTableViewHeaderFooterLabelsWithTableViewController:(UITableViewController *)tableViewController action:^(UIView *localisedView, UIView *parentView, NSString *string) {
            [self reloadLocalisedView:localisedView inParentView:parentView];
        }];
    }
}

#pragma mark - Retrieving data

- (NSString *)localisedLanguageNameForLanguageKey:(NSString *)key
{
    if ([self languageForLanguageKey:key]) {
        return ((TSCLocalisationLanguage *)[self languageForLanguageKey:key]).languageName;
    }
    
    return @"Unknown";
}

- (TSCLocalisationLanguage *)languageForLanguageKey:(NSString *)key
{
    for (TSCLocalisationLanguage *localisationLanguage in self.availableLanguages) {
        
        if ([localisationLanguage.languageCode isEqualToString:key]){
            
            return localisationLanguage;
        }
    }
    
    return nil;
}

#pragma mark - Login

- (void)askForLogin
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle bundleForClass:[TSCLocalisationController class]]];
    
    UIViewController *viewController = [storyboard instantiateInitialViewController];
    
    if (![viewController isKindOfClass:[TSCStormLoginViewController class]]) {
        return;
    }
    
    TSCStormLoginViewController *loginViewController = (TSCStormLoginViewController *)viewController;
    
    __weak typeof(self) welf = self;
    [loginViewController setCompletion:^void (BOOL successful, BOOL cancelled) {
        
        if (welf) {
            
            if (successful || cancelled) {
                
                welf.loginWindow.hidden = true;
                welf.loginWindow = nil;
                
                if (!cancelled) {
                    [welf toggleEditing];
                }
            }
        }
    }];

    
    self.loginWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.loginWindow.rootViewController = loginViewController;
    self.loginWindow.windowLevel = UIWindowLevelAlert+1;
    self.loginWindow.hidden = false;
}

- (void)reloadLocalisationsWithCompletion:(TSCLocalisationRefreshCompletion)completion
{
    self.requestController.sharedRequestHeaders[@"Authorization"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"TSCAuthenticationToken"];
    
    [self fetchAvailableLanguagesForApp:^(NSArray *languages, NSError *error) {
        
        if (!error) {
            
            [self fetchLocalisations:^(NSArray *localisations, NSError *error) {
                
                if (error) {
                    
                    completion(error);
                    return;
                }
                
                completion(nil);
            }];
        }
    }];
}

#pragma mark - Retrieving edited strings

- (NSDictionary *)localisationDictionaryForKey:(NSString *)key
{
    return self.localisationsDictionary[key];
}

#pragma mark - Activity View Controllers

- (void)showActivityIndicatorWithTitle:(NSString *)title
{
    self.activityIndicatorWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.activityIndicatorWindow.hidden = false;
    
    [MDCHUDActivityView startInView:self.activityIndicatorWindow text:title];
}

- (void)dismissActivityIndicator
{
    [MDCHUDActivityView finishInView:self.activityIndicatorWindow];
    self.activityIndicatorWindow = nil;
}

@end
