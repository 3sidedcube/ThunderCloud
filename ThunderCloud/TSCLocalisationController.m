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
#import "TSCLocalisation.h"
#import "NSString+LocalisedString.h"
#import "TSCLocalisationEditViewController.h"
#import "TSCLocalisationLanguage.h"
#import "TSCLocalisationKeyValue.h"
#import "MDCHUDActivityView.h"
#import "TSCStormLoginViewController.h"
#import "TSCAuthenticationController.h"
#import "TSCLocalisationExplanationViewController.h"

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

@property (nonatomic, readwrite) BOOL hasUsedWindowRoot;
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

- (instancetype)init
{
    if (self = [super init]) {
        
        self.requestController = [[TSCRequestController alloc] initWithBaseAddress:[NSString stringWithFormat:@"%@/%@/apps/%@", API_BASEURL, API_VERSION, API_APPID]];
        self.localisationsDictionary = [NSMutableDictionary new];
        self.activationMode = TSCLocalisationActivationShake;
    }
    
    return self;
}

#pragma mark - Activation Methods

- (void)setActivationMode:(TSCLocalisationActivation)activationMode
{
    _activationMode = activationMode;
    
    if (self.activationGesture) {
        
        UIWindow *gestureWindow = [UIApplication sharedApplication].keyWindow;
        [gestureWindow removeGestureRecognizer:self.activationGesture];
        self.activationGesture = nil;
    }
    
    if (self.screenshotObserver) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self.screenshotObserver];
        self.screenshotObserver = nil;
    }
    
    if (activationMode == TSCLocalisationActivationTwoFingersSwipeLeft) {
        
        UIWindow *gestureWindow = [UIApplication sharedApplication].keyWindow;
        
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        [gestureWindow addGestureRecognizer:swipeGesture];
        swipeGesture.numberOfTouchesRequired =  2;
        swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
        self.activationGesture = swipeGesture;
    }
    
    if (activationMode == TSCLocalisationActivationScreenshot) {
        
        __weak typeof(self) welf = self;
        self.screenshotObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          
                                                          if (welf) {
                                                              [welf toggleEditing];
                                                          }
                                                      }];
    }
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)swipe
{
    [self toggleEditing];
}

- (void)toggleEditing
{
    // If we're reloading localisations from the CMS don't allow toggle, also if we're displaying an edit view controller don't allow it
    if (self.isReloading || self.localisationEditingWindow || self.loginWindow) {
        return;
    }
    
    self.editing = !self.editing;
    
    // If we're not reloading and the user has turned on editing
    if (self.editing && !self.isReloading) {
        
        // If the user has already signed into storm account
        if ([[TSCAuthenticationController sharedInstance] isAuthenticated]) {
            
            // Start loading localisations from the CMS
            self.isReloading = true;
            [self showActivityIndicatorWithTitle:@"Loading Localisations"];
            [self reloadLocalisationsWithCompletion:^(NSError *error) {
                
                if (error) {
                    
                    NSLog(@"<%s> Failed to load localisations", __PRETTY_FUNCTION__);
                    [self dismissActivityIndicator];
                    return;
                }
                
                self.hasUsedWindowRoot = false;
                self.alertViewIsPresented = false;
                self.gestures = [NSMutableArray new];
                self.additionalLocalisedStrings = [NSMutableArray new];
                
                // Check for navigation controller, highlight its views and add a gesture recognizer to it
                UIView *navigationControllerView = (UIView *)[self selectCurrentViewControllerViewWithClass:[UINavigationController class]];
                if (navigationControllerView) {
                    
                    [self recurseSubviewsOfView:navigationControllerView withLocalisedViewAction:^(UIView *view, UIView *parentView, NSString *string) {
                        
                        view.userInteractionEnabled = true;
                        [self addHighlightToView:view withString:string];
                    }];
                    
                    [self addGesturesToView:navigationControllerView];
                }
                
                // Check for tab bar and higlight it's views, and add a gesture recognizer to it
                UIView *tabBarView = (UIView *)[self selectCurrentViewControllerViewWithClass:[UITabBarController class]];
                if (tabBarView) {
                    
                    [self recurseSubviewsOfView:tabBarView withLocalisedViewAction:^(UIView *view, UIView *parentView, NSString *string) {
                        
                        view.userInteractionEnabled = true;
                        [self addHighlightToView:view withString:string];
                    }];
                    
                    [self addGesturesToView:tabBarView];
                }
                
                // Get main view controller and highlight its views
                UIView *viewControllerView = (UIView *)[self selectCurrentViewControllerViewWithClass:[UIViewController class]];
                if (viewControllerView) {
                    
                    self.currentWindowView = viewControllerView;
                    [self recurseSubviewsOfView:viewControllerView withLocalisedViewAction:^(UIView *view, UIView *parentView, NSString *string) {
                        
                        view.userInteractionEnabled = true;
                        [self addHighlightToView:view withString:string];
                    }];
                    [self addGesturesToView:viewControllerView];
                    
                    if (self.alertViewIsPresented) { // Does this always mean we're in a UIAlertView or UIActionSheet? I'm not so sure...
                        
                        [self recurseSubviewsOfView:[UIApplication sharedApplication].keyWindow asAdditionalStrings:true];
                    }
                }
                
                // See if the displayed view controller is a `TSCTableViewController`
                TSCTableViewController *tscTableViewController = (TSCTableViewController *)[self selectCurrentViewControllerViewWithClass:[TSCTableViewController class]];
                if (tscTableViewController) {
                    
                    tscTableViewController.dataSource = tscTableViewController.dataSource;
                    tscTableViewController.tableView.scrollEnabled = false;
                    [self recurseTableViewHeaderFooterLabelsWithTableViewController:(UITableViewController *)tscTableViewController action:^(UIView *localisedView, UIView *parentView, NSString *string) {
                        [self addHighlightToView:localisedView withString:string];
                    }];
                } else {
                    
                    // Otherwise see if the displayed view controller is a `UITableViewController`
                    UITableViewController *tableViewController = (UITableViewController *)[self selectCurrentViewControllerViewWithClass:[UITableViewController class]];
                    if (tableViewController) {
                        
                        [tableViewController.tableView reloadData];
                        tableViewController.tableView.scrollEnabled = false;
                        [self recurseTableViewHeaderFooterLabelsWithTableViewController:tableViewController action:^(UIView *localisedView, UIView *parentView, NSString *string) {
                            [self addHighlightToView:localisedView withString:string];
                        }];
                    }
                }
                
                self.isReloading = false;
                [self dismissActivityIndicator];
                
                [self showMoreButton];
            }];
        } else {
            
            // If user not logged in ask them to login
            self.editing = false;
            self.isReloading = false;
            [self askForLogin];
        }
        
    } else {
        
        self.isReloading = true;
        
        // Save the users localisations if they have edited any
        if (self.editedLocalisations.count > 0) {
            
            [self saveLocalisations:^(NSError *error) {
                
                if (!error) {
                    NSLog(@"saved localisations! :D");
                }
            }];
        }
        
        // Check for navigation controller and remove highlights and gesture recognizer
        UIView *navigationControllerView = (UIView *)[self selectCurrentViewControllerViewWithClass:[UINavigationController class]];
        if (navigationControllerView) {
            [self removeLocalisationHightlights:navigationControllerView.subviews];
            [self removeGesturesFromView:navigationControllerView];
        }
        
        // Check for tab bar controller and remove highlights and gesture recognizer
        UIView *tabBarView = (UIView *)[self selectCurrentViewControllerViewWithClass:[UITabBarController class]];
        if (tabBarView) {
            
            [self removeLocalisationHightlights:tabBarView.subviews];
            [self removeGesturesFromView:tabBarView];
        }
        
        // Get main view controller and remove highlights
        UIView *viewControllerView = (UIView *)[self selectCurrentViewControllerViewWithClass:[UIViewController class]];
        if (viewControllerView) {
            self.currentWindowView = viewControllerView;
            [self removeLocalisationHightlights:viewControllerView.subviews];
            [self removeGesturesFromView:viewControllerView];
        }
        
        // Get tableView controller... We could intercept the delegate of the tableView here, and reset it later so we can allow the user to still scroll the view...
        TSCTableViewController *tscTableViewController = (TSCTableViewController *)[self selectCurrentViewControllerViewWithClass:[TSCTableViewController class]];
        if (tscTableViewController) {
            
            tscTableViewController.tableView.scrollEnabled = true;
            
        } else {
            
            UITableViewController *tableViewController = (UITableViewController *)[self selectCurrentViewControllerViewWithClass:[UITableViewController class]];
            if (tableViewController) {
                
                tableViewController.tableView.scrollEnabled = true;
            }
        }
        
        if (self.moreButton) {
            
            [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:0.8 options:kNilOptions animations:^{
                
                self.moreButton.alpha = 0.0;
            } completion:^(BOOL finished) {
                
                if (finished) {
                    [self.moreButton removeFromSuperview];
                }
            }];
        }
        
        self.isReloading = false;
    }
}

#pragma mark - Helper methods

// Reflects a change to a localisation for the current app session
- (void)reloadLocalisedView:(UIView *)view inParentView:(UIView *)parentView;
{
    if ([view isKindOfClass:[UILabel class]]) {
        
        UILabel *label = (UILabel *)view;
        
        NSString *newString = [NSString stringWithLocalisationKey:label.text.localisationKey];
        label.text = newString;
        
        if ([parentView isKindOfClass:[UIButton class]]) {
            
            UIButton *button = (UIButton *)parentView;
            [button setTitle:label.text forState:UIControlStateNormal];
        }
        
        return;
    }
    
    if ([view isKindOfClass:[UITextView class]]) {
        
        UITextView *textView = (UITextView *)view;
        textView.text = [NSString stringWithLocalisationKey:textView.text.localisationKey];
        return;
    }
}

// Recurses a navigation controller's `UIViewController`s recursively calling a block at each step
- (void)recurseNavigationController:(UINavigationController *)navigationViewController usingBlock:(TSCNavigationViewControllerRecursionCallback)block
{
    UIViewController *viewController = navigationViewController.visibleViewController;
    UIViewController *presentedViewController = navigationViewController.presentedViewController;
    
    __block BOOL stop = false;
    __block TSCNavigationViewControllerRecursionCallback innerBlock = block;
    
    // If either of these is true the current displayed `UIViewController` is presenting or at least has a `UINavigationController` surrounding it, so we call the block :)
    if (viewController.navigationController || presentedViewController) {
        block(viewController, viewController.navigationController, &stop);
    } else {
        return;
    }
    
    // If the block called earlier told us to stop recursing or the navigation controller isn't presenting a view controller we stop
    if (!stop && presentedViewController) {
        
        // Pull the navigation controller for the visible view controller
        UINavigationController *navController;
        if ([presentedViewController isKindOfClass:[UINavigationController class]]) {
            navController = (UINavigationController *)presentedViewController;
        } else {
            navController = presentedViewController.navigationController;
        }
        
        if (navController) {
            
            // We recurse the presented viewControllers navigationController
            [self recurseNavigationController:navController usingBlock:^(UIViewController *visibleViewController, UINavigationController *navigationController, BOOL *innerStop) {
                
                innerBlock(visibleViewController, navigationController, &stop);
                *innerStop = stop;
            }];
            
            if (stop) {
                return;
            }
        } else {
            return;
        }
    }
}

// Returns the highest (currently displayed) view controller of a certain class
- (NSObject *)selectCurrentViewControllerViewWithClass:(Class)class
{
    UIView *viewToRecurse;
    UINavigationController *navigationController;
    UITabBarController *tabController;
    UITableViewController *tableViewController;
    TSCTableViewController *tscTableViewController;
    
    UIWindow *highestWindow = [[UIApplication sharedApplication] keyWindow];
    
    // If the root view controller is a `UINavigationController`
    if ([highestWindow.rootViewController isKindOfClass:[UINavigationController class]]) {
        
        __block UINavigationController *navController = (UINavigationController *)highestWindow.rootViewController;
        __block UIViewController *viewController = navController.visibleViewController;
        
        // Find the currently visible `UIViewController` and `UINavigationController`
        [self recurseNavigationController:navController usingBlock:^(UIViewController *visibleViewController, UINavigationController *navigationController, BOOL *stop) {
            
            viewController = visibleViewController;
            navController = navigationController;
        }];
        
        if ([viewController isKindOfClass:[TSCTableViewController class]]) {
            tscTableViewController = (TSCTableViewController *)viewController;
        } else if ([viewController isKindOfClass:[UITableViewController class]]) {
            tableViewController = (UITableViewController *)viewController;
        }
        
        viewToRecurse = viewController.view;
        navigationController = navController;
        
    } else if ([highestWindow.rootViewController isKindOfClass:[UITabBarController class]]) { // Root view controller is a `UITabBarController`
        
        tabController = (UITabBarController *)highestWindow.rootViewController;
        
        // Get the selected tab bar controller
        if ([tabController.selectedViewController isKindOfClass:[UINavigationController class]]) {
            
            __block UINavigationController *navController;
            __block UIViewController *viewController;
            
            
            if ([tabController.selectedViewController isKindOfClass:[UINavigationController class]]) {
                
                navController = (UINavigationController *)tabController.selectedViewController;
                viewController = navController.visibleViewController;
                
                [self recurseNavigationController:navController usingBlock:^(UIViewController *visibleViewController, UINavigationController *navigationController, BOOL *stop) {
                    
                    viewController = visibleViewController;
                }];
                
                [self recurseNavigationController:navController usingBlock:^(UIViewController *visibleViewController, UINavigationController *navigationController, BOOL *stop) {
                    
                    if (navigationController) {
                        navController = navigationController;
                    } else {
                        *stop = true;
                    }
                }];
                
            } else {
                
                viewController = tabController.selectedViewController;
            }
            
            if ([viewController isKindOfClass:[TSCTableViewController class]]) {
                tscTableViewController = (TSCTableViewController *)viewController;
            } else if ([viewController isKindOfClass:[UITableViewController class]]) {
                tableViewController = (UITableViewController *)viewController;
            }
            
            // We want to recurse the view controller's view
            viewToRecurse = viewController.view;
            navigationController = navController;
            
        } else {
            
            viewToRecurse = tabController.selectedViewController.view;
        }
        
    } else {
        
        viewToRecurse = highestWindow.rootViewController.view;
        
        self.hasUsedWindowRoot = true;
        
        // If they key window isn't a `UIWindow`
        if (![[UIApplication sharedApplication].keyWindow isMemberOfClass:[UIWindow class]]) {
            self.alertViewIsPresented = true;
        }
    }
    
    // User is looking for a `UINavigationController`
    if (navigationController && class == [UINavigationController class]) {
        return navigationController.view;
    }
    
    // User is looking for a `UITabBarController`
    if (tabController && class == [UITabBarController class]) {
        return tabController.view;
    }
    
    // User is looking for a `TSCTableViewController`
    if (tscTableViewController && class == [TSCTableViewController class]) {
        return tscTableViewController;
    }
    
    // User is looking for a `UITableViewController`
    if (tableViewController && class == [UITableViewController class]) {
        return tableViewController;
    }
    
    // User wasn't asking for a class we know about but we found them a view anyways (We're so nice like that :D)
    if (viewToRecurse && class != [UINavigationController class] && class != [TSCTableViewController class] && class != [UITableViewController class]) {
        return viewToRecurse;
    }
    
    return nil;
}

#pragma mark - Localisation selection

- (void)recurseSubviewsOfView:(UIView *)recursingView
{
    [self recurseSubviewsOfView:recursingView asAdditionalStrings:false];
}

- (void)recurseSubviewsOfView:(UIView *)recursingView asAdditionalStrings:(BOOL)additionalStrings
{
    [self recurseSubviewsOfView:recursingView withLocalisedViewAction:^(UIView *view, UIView *parentView, NSString *string) {
        
        if (additionalStrings) {
            [self.additionalLocalisedStrings addObject:string];
        }
    }];
}

- (void)recurseSubviewsOfView:(UIView *)recursingView withLocalisedViewAction:(TSCLocalisedViewAction)action
{
    
    for (UIView *view in recursingView.subviews) {
        
        NSString *string;
        
        if ([view isKindOfClass:[UILabel class]]) {
            
            UILabel *label = (UILabel *)view;
            string = label.text;
        }
        
        if ([view isKindOfClass:[UITextView class]]) {
            
            UITextView *textView = (UITextView *)view;
            string = textView.text;
        }
        
        if (string) {
            
            if (string.localisationKey) {
                
                if (action) {
                    action(view, recursingView, string);
                }
                continue;
            }
        }
        
        [self recurseSubviewsOfView:view withLocalisedViewAction:action];
    }
}

- (void)addHighlightToView:(UIView *)view withString:(NSString *)string
{
    UIView *highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    highlightView.layer.cornerRadius = 4.0;
    highlightView.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.2].CGColor;
    highlightView.layer.borderWidth = 1.0;
    
    TSCLocalisation *localisation = [self CMSLocalisationForKey:string.localisationKey];
    __block BOOL hasBeenEdited = true;
    
    [localisation.localisationValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj isKindOfClass:[TSCLocalisationKeyValue class]]) {
            
            TSCLocalisationKeyValue *localisationKeyValue = (TSCLocalisationKeyValue *)obj;
            if ([localisationKeyValue.localisedString isEqualToString:string]) {
                
                hasBeenEdited = false;
                *stop = true;
            }
        }
    }];
    
    if (hasBeenEdited && localisation) {
        highlightView.backgroundColor = [UIColor orangeColor];
    } else if (localisation) {
        highlightView.backgroundColor = [UIColor greenColor];
    } else {
        highlightView.backgroundColor = [UIColor redColor];
    }
    
    highlightView.tag = 635355756;
    highlightView.alpha = 0.2;
    highlightView.userInteractionEnabled = NO;
    [view addSubview:highlightView];
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
        
        TSCAlertViewController *alert = [TSCAlertViewController alertControllerWithTitle:@"Choose a localisation" message:@"" preferredStyle:TSCAlertViewControllerStyleActionSheet];
        
        for (NSString *localString in self.localisationStrings) {
            
            [alert addAction:[TSCAlertAction actionWithTitle:localString style:TSCAlertActionStyleDefault handler:^(TSCAlertAction *action) {
                [self presentLocalisationEditViewControllerWithLocalisation:localString];
            }]];
        }
        
        [alert addAction:[TSCAlertAction actionWithTitle:@"Cancel" style:TSCAlertActionStyleCancel handler:nil]];
        [alert showInView:self.currentWindowView];
    }
}

- (void)presentLocalisationEditViewControllerWithLocalisation:(NSString *)localisedString
{
    
    TSCLocalisation *localisation = [self CMSLocalisationForKey:localisedString.localisationKey];
    
    __block TSCLocalisationEditViewController *editViewController;
    if (localisation) {
            
        editViewController = [[TSCLocalisationEditViewController alloc] initWithLocalisation:localisation];
        
    } else {
        
        editViewController = [[TSCLocalisationEditViewController alloc] initWithLocalisationKey:localisedString.localisationKey];
    }
    
    if (editViewController) {
        
        editViewController.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editViewController];
        
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

- (TSCLocalisation *)CMSLocalisationForKey:(NSString *)key
{
    __block TSCLocalisation *foundLocalisation;
    
    [self.localisations enumerateObjectsUsingBlock:^(TSCLocalisation *localisation, NSUInteger idx, BOOL *stop){
        
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

- (void)registerLocalisationEdited:(TSCLocalisation *)localisation
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
    
    for (TSCLocalisation *localisation in editedLocalisations) {
        
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
                TSCLocalisation *newLocalisation = [[TSCLocalisation alloc] initWithDictionary:localisationDictionary];
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
    for (TSCLocalisation *localisation in self.editedLocalisations) {
        
        self.localisationsDictionary[localisation.localisationKey] = [localisation serialisableRepresentation];
    }
    
    UIView *navigationControllerView = (UIView *)[self selectCurrentViewControllerViewWithClass:[UINavigationController class]];
    if (navigationControllerView) {
        
        [self recurseSubviewsOfView:navigationControllerView withLocalisedViewAction:^(UIView *view, UIView *parentView, NSString *string) {
            
            [self reloadLocalisedView:view inParentView:parentView];
        }];
    }
    
    // Get main view controller and remove highlights
    UIView *viewControllerView = (UIView *)[self selectCurrentViewControllerViewWithClass:[UIViewController class]];
    if (viewControllerView) {
        
        [self recurseSubviewsOfView:viewControllerView withLocalisedViewAction:^(UIView *view, UIView *parentView, NSString *string) {
            
            [self reloadLocalisedView:view inParentView:parentView];
        }];
    }
    
    // Get tableView controller
    TSCTableViewController *tableViewController = (TSCTableViewController *)[self selectCurrentViewControllerViewWithClass:[TSCTableViewController class]];
    if (tableViewController) {
        
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
    TSCStormLoginViewController *loginViewController = [TSCStormLoginViewController new];
    
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