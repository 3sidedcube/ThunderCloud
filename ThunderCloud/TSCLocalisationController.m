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
#import "TSCAuthenticationController.h"
#import "TSCLocalisationEditViewController.h"
#import "TSCLocalisationLanguage.h"
#import "TSCLocalisationKeyValue.h"
#import "MDCHUDActivityView.h"

@import UIKit;
@import LocalAuthentication;
@import Security;
@import ThunderBasics;
@import ThunderRequest;
@import ThunderTable;

typedef void (^TSCLocalisedViewAction)(UIView *localisedView, UIView *parentView, NSString *string);
typedef void (^TSCNavigationViewControllerRecursionCallback)(UIViewController *visibleViewController, UINavigationController *navigationController, BOOL *stop);

@interface TSCLocalisationController () <UIGestureRecognizerDelegate, TSCLocalisationEditViewControllerDelegate>

@property (nonatomic, strong) TSCRequestController *requestController;
@property (nonatomic, strong) NSMutableArray *localisations;
@property (nonatomic, strong) NSMutableArray *editedLocalisations;
@property (nonatomic, strong) NSMutableArray *localisationStrings;
@property (nonatomic, strong) UIView *currentWindowView;
@property (nonatomic, strong) NSMutableArray *gestures;
@property (nonatomic, readwrite) BOOL hasUsedWindowRoot;
@property (nonatomic, readwrite) BOOL alertViewIsPresented;
@property (nonatomic, strong) NSMutableArray *additionalLocalisedStrings;
@property (nonatomic, strong) UIButton *additonalLocalisationButton;
@property (nonatomic, strong) UIWindow *localisationEditingWindow;
@property (nonatomic, strong) UIWindow *activityIndicatorWindow;
@property (nonatomic, strong) NSMutableDictionary *localisationsDictionary;

@property (nonatomic, assign) BOOL isReloading;

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
    }
    
    return self;
}

- (void)toggleEditing
{
    if (self.isReloading) {
        return;
    }
    
    self.editing = !self.editing;
    
    if (self.editing && !self.isReloading) {
        
        if ([[TSCAuthenticationController sharedInstance] isAuthenticated]) {
            
            self.isReloading = true;
            [self showActivityIndicatorWithTitle:@"Loading Localisations"];
            [self reloadLocalisationsWithCompletion:^(NSError *error) {
                
                if (error) {
                    
                    NSLog(@"<%s> Failed to load localisations", __PRETTY_FUNCTION__);
                    return;
                }
                
                self.hasUsedWindowRoot = false;
                self.alertViewIsPresented = false;
                self.gestures = [NSMutableArray new];
                self.additionalLocalisedStrings = [NSMutableArray new];
                
                // Check for navigation controller and highlight its views
                UIView *navigationControllerView = (UIView *)[self selectCurrentViewControllerViewWithClass:[UINavigationController class]];
                if (navigationControllerView) {
                    
                    [self recurseSubviewsOfView:navigationControllerView withLocalisedViewAction:^(UIView *view, UIView *parentView, NSString *string) {
                        
                        view.userInteractionEnabled = true;
                        [self addHighlightToView:view withString:string];
                    }];
                    
                    [self addGesturesToView:navigationControllerView];
                }
                
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
                
                TSCTableViewController *tscTableViewController = (TSCTableViewController *)[self selectCurrentViewControllerViewWithClass:[TSCTableViewController class]];
                if (tscTableViewController) {
                    
                    tscTableViewController.dataSource = tscTableViewController.dataSource;
                    tscTableViewController.tableView.scrollEnabled = false;
                    [self recurseTableViewHeaderFooterLabelsWithTableViewController:(UITableViewController *)tscTableViewController action:^(UIView *localisedView, UIView *parentView, NSString *string) {
                        [self addHighlightToView:localisedView withString:string];
                    }];
                }
                
                if (!tscTableViewController) {
                    
                    UITableViewController *tableViewController = (UITableViewController *)[self selectCurrentViewControllerViewWithClass:[UITableViewController class]];
                    if (tableViewController) {
                        
                        [tableViewController.tableView reloadData];
                        tableViewController.tableView.scrollEnabled = false;
                        [self recurseTableViewHeaderFooterLabelsWithTableViewController:tableViewController action:^(UIView *localisedView, UIView *parentView, NSString *string) {
                            [self addHighlightToView:localisedView withString:string];
                        }];
                    }
                }
                
                if (self.additionalLocalisedStrings.count > 0) {
                    self.additonalLocalisationButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [self.additonalLocalisationButton setFrame:CGRectMake(10, viewControllerView.frame.size.height - 35 - 30, viewControllerView.frame.size.width - 20, 35)];
                    [self.additonalLocalisationButton setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
                    [self.additonalLocalisationButton setTitle:@"Additional Strings" forState:UIControlStateNormal];
                    [self.additonalLocalisationButton addTarget:self action:@selector(handleAdditionalStrings) forControlEvents:UIControlEventTouchUpInside];
                    
                    [[UIApplication sharedApplication].keyWindow addSubview:self.additonalLocalisationButton];
                    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.additonalLocalisationButton];
                }
                
                self.isReloading = false;
                [self dismissActivityIndicator];
            }];
        } else {
            
            self.editing = NO;
            self.isReloading = false;
            [self askForLogin];
        }
        
    } else {
        
        self.isReloading = true;
        
        if (self.editedLocalisations.count > 0) {
            
            [self saveLocalisations:^(NSError *error) {
                
                if (!error) {
                    NSLog(@"saved localisations! :D");
                }
            }];
        }
        
        // Check for navigation controller and remove highlights
        UIView *navigationControllerView = (UIView *)[self selectCurrentViewControllerViewWithClass:[UINavigationController class]];
        if (navigationControllerView) {
            [self removeLocalisationHightlights:navigationControllerView.subviews];
            [self removeGesturesFromView:navigationControllerView];
        }
        
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
        
        // Get tableView controller
        
        TSCTableViewController *tscTableViewController = (TSCTableViewController *)[self selectCurrentViewControllerViewWithClass:[TSCTableViewController class]];
        if (tscTableViewController) {
            
            tscTableViewController.tableView.scrollEnabled = true;
        }
        
        if (!tscTableViewController) {
            
            UITableViewController *tableViewController = (UITableViewController *)[self selectCurrentViewControllerViewWithClass:[UITableViewController class]];
            if (tableViewController) {
                
                tableViewController.tableView.scrollEnabled = true;
            }
        }
        
        if (self.additonalLocalisationButton) {
            [self.additonalLocalisationButton removeFromSuperview];
        }
        
        self.isReloading = false;
    }
}

#pragma mark - Helper methods

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

- (void)recurseNavigationController:(UINavigationController *)navigationViewController usingBlock:(TSCNavigationViewControllerRecursionCallback)block
{
    UIViewController *viewController = navigationViewController.visibleViewController;
    UIViewController *presentedViewController = navigationViewController.presentedViewController;
    
    __block BOOL stop = false;
    __block TSCNavigationViewControllerRecursionCallback innerBlock = block;
    
    if (viewController.navigationController || presentedViewController) {
        block(viewController, viewController.navigationController, &stop);
    } else {
        return;
    }
    
    if (!stop && presentedViewController) {
        
        UINavigationController *navController;
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            navController = (UINavigationController *)viewController;
        } else {
            navController = viewController.navigationController;
        }
        
        if (navController) {
            [self recurseNavigationController:viewController.navigationController usingBlock:^(UIViewController *visibleViewController, UINavigationController *navigationController, BOOL *innerStop) {
                
                innerBlock(visibleViewController, navigationController, &stop);
                *innerStop = stop;
            }];
            
            if (stop) {
                return;
            }
        } else {
            return;
        }
    } else {
        return;
    }
}

- (NSObject *)selectCurrentViewControllerViewWithClass:(Class)class
{
    UIView *viewToRecurse;
    UINavigationController *navigationController;
    UITabBarController *tabController;
    UITableViewController *tableViewController;
    TSCTableViewController *tscTableViewController;
    
    UIWindow *highestWindow = [[UIApplication sharedApplication] keyWindow];
    
    if ([highestWindow.rootViewController isKindOfClass:[UINavigationController class]]) {
        
        __block UINavigationController *navController = (UINavigationController *)highestWindow.rootViewController;
        __block UIViewController *viewController = navController.visibleViewController;
        
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
        
        if ([viewController isKindOfClass:[TSCTableViewController class]]) {
            tscTableViewController = (TSCTableViewController *)viewController;
        } else if ([viewController isKindOfClass:[UITableViewController class]]) {
            tableViewController = (UITableViewController *)viewController;
        }
        
        viewToRecurse = viewController.view;
        navigationController = navController;
        
    } else if ([highestWindow.rootViewController isKindOfClass:[UITabBarController class]]) {
        
        tabController = (UITabBarController *)highestWindow.rootViewController;
        
        if ([tabController.selectedViewController isKindOfClass:[UINavigationController class]]) {
            
            __block UINavigationController *navController = (UINavigationController *)tabController.selectedViewController;
            __block UIViewController *viewController = navController.visibleViewController;
            
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
            
            if ([viewController isKindOfClass:[TSCTableViewController class]]) {
                tscTableViewController = (TSCTableViewController *)viewController;
            } else if ([viewController isKindOfClass:[UITableViewController class]]) {
                tableViewController = (UITableViewController *)viewController;
            }
            
            viewToRecurse = viewController.view;
            navigationController = navController;
            
        } else {
            
            viewToRecurse = tabController.selectedViewController.view;
        }
        
    } else {
        viewToRecurse = highestWindow.rootViewController.view;
        
        self.hasUsedWindowRoot = true;
        if (![[UIApplication sharedApplication].keyWindow isMemberOfClass:[UIWindow class]]) {
            self.alertViewIsPresented = true;
        }
    }
    
    if (navigationController && class == [UINavigationController class]) {
        return navigationController.view;
    }
    
    if (tabController && class == [UITabBarController class]) {
        return tabController.view;
    }
    
    if (tscTableViewController && class == [TSCTableViewController class]) {
        return tscTableViewController;
    }
    
    if (tableViewController && class == [UITableViewController class]) {
        return tableViewController;
    }
    
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
    UIView *highlightView = [[UIView alloc] initWithFrame:CGRectMake(0, 2, view.frame.size.width, view.frame.size.height - 4)];
    
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
    
    for (NSString *string in sectionHeaderFooterTitles) {
        if (!string.localisationKey) {
            [sectionHeaderFooterTitles removeObject:string];
        }
    }
    
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
        
        if (label.text.localisationKey != nil) {
            localisedString = label.text;
        }
    }
    
    if ([view isKindOfClass:[UITextView class]]) {
        
        UITextView *textView = (UITextView *)view;
        
        if (textView.text.localisationKey != nil) {
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
        
        __block BOOL hasBeenEdited = true;
        
        [localisation.localisationValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if ([obj isKindOfClass:[TSCLocalisationKeyValue class]]) {
                
                TSCLocalisationKeyValue *localisationKeyValue = (TSCLocalisationKeyValue *)obj;
                if ([localisationKeyValue.localisedString isEqualToString:localisedString]) {
                    
                    hasBeenEdited = false;
                    *stop = true;
                }
            }
        }];
        
        if (hasBeenEdited) {
            
            TSCAlertViewController *alreadyEditedAlertView = [TSCAlertViewController alertControllerWithTitle:@"Localisation Edited In CMS" message:@"This localisation has been edited in the CMS since the last publish, changing it here will overwrite the value in the CMS" preferredStyle:TSCAlertViewControllerStyleAlert];
            
            TSCAlertAction *continueAction = [TSCAlertAction actionWithTitle:@"Edit" style:TSCAlertActionStyleDefault handler:^(TSCAlertAction *action) {
                
                editViewController = [[TSCLocalisationEditViewController alloc] initWithLocalisation:localisation];
                editViewController.delegate = self;
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:editViewController];
                
                self.localisationEditingWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                self.localisationEditingWindow.rootViewController = navController;
                self.localisationEditingWindow.windowLevel = UIWindowLevelAlert+1;
                self.localisationEditingWindow.hidden = false;
            }];
            
            TSCAlertAction *cancelAction = [TSCAlertAction actionWithTitle:@"Cancel" style:TSCAlertActionStyleDefault handler:nil];
            
            [alreadyEditedAlertView addAction:continueAction];
            [alreadyEditedAlertView addAction:cancelAction];
            [alreadyEditedAlertView showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
            
        } else {
            
            editViewController = [[TSCLocalisationEditViewController alloc] initWithLocalisation:localisation];
        }
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

- (void)handleAdditionalStrings
{
    TSCAlertViewController *alert = [TSCAlertViewController alertControllerWithTitle:@"Additional Localisations" message:nil preferredStyle:TSCAlertViewControllerStyleActionSheet];
    
    for (NSString *string in self.additionalLocalisedStrings) {
        [alert addAction:[TSCAlertAction actionWithTitle:string style:TSCAlertActionStyleDefault handler:^(TSCAlertAction *action) {
            [self presentLocalisationEditViewControllerWithLocalisation:string];
        }]];
    }
    
    [alert addAction:[TSCAlertAction actionWithTitle:@"Cancel" style:TSCAlertActionStyleCancel handler:nil]];
    [alert showInView:self.currentWindowView];
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
    [self.localisationEditingWindow resignKeyWindow];
    self.localisationEditingWindow.hidden = true;
    self.localisationEditingWindow = nil;
}

- (void)editingSavedInViewController:(TSCLocalisationEditViewController *)viewController
{
    [self.localisationEditingWindow resignKeyWindow];
    self.localisationEditingWindow.hidden = true;
    self.localisationEditingWindow = nil;
    
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
    for (TSCLocalisationLanguage *localisationLanguage in self.availableLanguages) {
        
        if ([localisationLanguage.languageCode isEqualToString:key]){
            
            return localisationLanguage.languageName;
        }
    }
    
    return @"Unknown";
}

#pragma mark - Login

- (void)askForLogin
{
    [self showLoginAlert];
}

- (void)showLoginAlert
{
    UIAlertView *editLoginAlert = [[UIAlertView alloc] initWithTitle:@"Editing mode enabled" message:@"Please log in with your Storm account" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
    editLoginAlert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    editLoginAlert.tag = 0;
    
    [editLoginAlert show];
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

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 0 && buttonIndex == 1){
        
        __block NSString *username = [alertView textFieldAtIndex:0].text;
        __block NSString *password = [alertView textFieldAtIndex:1].text;
        [self showActivityIndicatorWithTitle:@"Logging in"];
        
        [[TSCAuthenticationController sharedInstance] authenticateUsername:username password:password completion:^(BOOL sucessful, NSError *error) {
            
            [self dismissActivityIndicator];
            if (sucessful) {
                
                [self toggleEditing];
            } else {
                
                [self askForLogin];
            }
        }];
    }
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
