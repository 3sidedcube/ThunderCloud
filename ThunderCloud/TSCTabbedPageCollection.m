//
//  TSCTabbedPageCollection.m
//  ThunderStorm
//
//  Created by Phillip Caudell on 23/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCTabbedPageCollection.h"
#import "TSCNavigationTabBarViewController.h"
#import "TSCAccordionTabBarViewController.h"
#import "TSCImage.h"
#import "TSCStormViewController.h"
#import "TSCSplitViewController.h"
#import "UINavigationController+TSCNavigationController.h"
#import "UIViewController+TSCViewController.h"
#import "TSCTabBarMoreViewController.h"
#import "TSCPlaceholder.h"
#import "TSCStormObject.h"
#import "TSCPlaceholderViewController.h"

@import ThunderBasics;
@import ThunderTable;

@interface TSCTabbedPageCollection ()

@property (nonatomic, strong) NSMutableArray *placeholders;
@property (nonatomic) NSInteger selectedTabIndex;

@end

@implementation TSCTabbedPageCollection

- (instancetype)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)object
{
    if (self = [super init]) {
        
        self.delegate = self;
        self.placeholders = [[NSMutableArray alloc] init];

        /*
         LOAD ROOT STORM PAGES
         */
        
        NSMutableArray *viewControllers = [NSMutableArray new];
        
        for (NSDictionary *pageDictionary in dictionary[@"pages"]) {
            
            TSCPlaceholder *placeholder = [[TSCPlaceholder alloc] initWithDictionary:pageDictionary[@"tabBarItem"]];
            [self.placeholders addObject:placeholder];
            
            if ([pageDictionary[@"type"] isEqualToString:@"TabbedPageCollection"]) {
                
                NSMutableDictionary *typeDictionary = [NSMutableDictionary dictionaryWithDictionary:pageDictionary];
                [typeDictionary setValue:@"NavigationTabBarViewController" forKey:@"type"];
                UIImage *tabBarImage = [TSCImage imageWithJSONObject:pageDictionary[@"tabBarItem"][@"image"]];
            
                Class tabViewControllerClass = [TSCStormObject classForClassKey:NSStringFromClass([TSCNavigationTabBarViewController class])];
                TSCNavigationTabBarViewController *navTabController = [[tabViewControllerClass alloc] initWithDictionary:typeDictionary];
                navTabController.title = TSCLanguageDictionary(pageDictionary[@"tabBarItem"][@"title"]);
                navTabController.tabBarItem.image = [[self tabBarImageWithImage:tabBarImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                navTabController.tabBarItem.selectedImage = [self tabBarImageWithImage:tabBarImage];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:navTabController];
                [viewControllers addObject:navController];
                
            } else {
                
                NSDictionary *tabBarItemDictionary = pageDictionary[@"tabBarItem"];
                
                NSURL *pageURL = [NSURL URLWithString:pageDictionary[@"src"]];
                NSString *tabBarTitle = TSCLanguageDictionary(tabBarItemDictionary[@"title"]);
                UIImage *tabBarImage = [TSCImage imageWithJSONObject:tabBarItemDictionary[@"image"]];
                
                TSCStormViewController *viewController = [[TSCStormViewController alloc] initWithURL:pageURL];
                viewController.tabBarItem.title = tabBarTitle;
                viewController.tabBarItem.image = [[self tabBarImageWithImage:tabBarImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                viewController.tabBarItem.selectedImage = [self tabBarImageWithImage:tabBarImage];
                
//                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
                
                if(viewController) {
//                    [navigationController setPageIdentifier:pageDictionary[@"src"]];
                    [viewControllers addObject:viewController];
                }
            }
        }
        
        /*
         CUSTOM MORE PAGE IF MORE THAN 5 VIEW CONTROLLERS
         */
        
        if (viewControllers.count > 5) {
            
            NSIndexSet *overflowIndices = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(4, viewControllers.count-4)];
            NSArray *overflowViewControllers = [viewControllers objectsAtIndexes:overflowIndices];
            [viewControllers removeObjectsAtIndexes:overflowIndices];
            
            TSCTabBarMoreViewController *moreViewController = [[TSCTabBarMoreViewController alloc] initWithViewControllers:overflowViewControllers];
            UINavigationController *moreNavController = [[UINavigationController alloc] initWithRootViewController:moreViewController];
            [viewControllers addObject:moreNavController];
        }
        
        /*
         PAGE ORDERING
         */
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *preferedOrder = [defaults objectForKey:kTSCTabbedPageCollectionUsersPreferedOrderKey];
        
        if (!preferedOrder) {
            
            self.viewControllers = viewControllers;
            
        } else {
            
            NSMutableArray *orderedViewControllers = [NSMutableArray new];
            
            for (NSString *pageIdentifier in preferedOrder) {
                
                UIViewController *viewController = [self viewControllerForPageIdentifier:pageIdentifier withViewControllers:viewControllers];
                
                if (viewController) {
                    
                    [orderedViewControllers addObject:viewController];
                    [viewControllers removeObject:viewController];
                }
            }
            
            // As new pages could be added in that don't have a prefered order. To prevent these from being missed out, just add them on the end
            [orderedViewControllers addObjectsFromArray:viewControllers];
            
            self.viewControllers = orderedViewControllers;
        }
    }
    
    return self;
}

- (UIViewController *)viewControllerForPageIdentifier:(id)pageIdentifier withViewControllers:(NSArray *)viewControllers
{
    for (UIViewController *viewController in viewControllers) {
        
        if ([[viewController pageIdenitifer] isEqual:pageIdentifier]) {
            return viewController;
        }
    }
    
    return nil;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSInteger index = [self.viewControllers indexOfObject:viewController];
    self.selectedTabIndex = index;
    [self showPlaceholderViewController];
}

- (UIImage *)tabBarImageWithImage:(UIImage *)originalImage
{
    CGRect rect = CGRectMake(0, 0, 30, 30);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);
    [originalImage drawInRect:rect];
    
    UIImage *contextImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return contextImage;
}

- (void)openNavigationLink:(UIBarButtonItem *)barButtonItem
{
    UIViewController *viewController = self.viewControllers[barButtonItem.tag];
    viewController.hidesBottomBarWhenPushed = YES;
    
    if (TSC_isPad()) {
        [[TSCSplitViewController sharedController] setRightViewController:viewController fromNavigationController:(UINavigationController *)self.selectedViewController];
    } else {
        [(UINavigationController *)self.selectedViewController pushViewController:viewController animated:YES];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *identifiers = [NSMutableArray array];
    
    for (UIViewController *viewController in viewControllers) {
        [identifiers addObject:[viewController pageIdenitifer]];
    }
    
    [defaults setObject:identifiers forKey:kTSCTabbedPageCollectionUsersPreferedOrderKey];
    [defaults synchronize];
}

- (void)showPlaceholderViewController
{
    if (TSC_isPad()) {
        NSString *retainKey = [NSString stringWithFormat:@"%li", (long)self.selectedTabIndex];
        
        if ([[TSCSplitViewController sharedController] retainKeyAlreadyStored:retainKey]) {
            [[TSCSplitViewController sharedController] setRightViewControllerUsingRetainKey:retainKey];
        } else {
            TSCPlaceholder *placeholder = [self.placeholders objectAtIndex:self.selectedTabIndex];
            
            TSCPlaceholderViewController *placeholderVC = [[TSCPlaceholderViewController alloc] init];
            placeholderVC.title = placeholder.title;
            placeholderVC.placeholderDescription = placeholder.placeholderDescription;
            placeholderVC.image = placeholder.image;
            [[TSCSplitViewController sharedController] setRightViewController:placeholderVC fromNavigationController:self.navigationController usingRetainKey:retainKey];
        }
    }
}

@end
