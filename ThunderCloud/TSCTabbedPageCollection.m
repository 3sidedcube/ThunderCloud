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
@import ThunderBasics;
@import ThunderTable;

@interface TSCTabbedPageCollection ()

@end

@implementation TSCTabbedPageCollection

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        
        self.delegate = self;
        
        /*
         LOAD ROOT STORM PAGES
         */
        
        NSMutableArray *viewControllers = [NSMutableArray new];

        for (NSDictionary *pageDictionary in dictionary[@"pages"]) {
            
            if ([pageDictionary[@"type"] isEqualToString:@"TabbedPageCollection"]) {
                
                NSMutableDictionary *typeDictionary = [NSMutableDictionary dictionaryWithDictionary:pageDictionary];
                [typeDictionary setValue:@"NavigationTabBarViewController" forKey:@"type"];
                
                TSCNavigationTabBarViewController *navTabController = [[TSCNavigationTabBarViewController alloc] initWithDictionary:typeDictionary];
                navTabController.title = TSCLanguageDictionary(pageDictionary[@"tabBarItem"][@"title"]);
                navTabController.tabBarItem.image = [TSCImage imageWithDictionary:pageDictionary[@"tabBarItem"][@"image"]];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:navTabController];
                [viewControllers addObject:navController];
                
            } else {
            
                NSDictionary *tabBarItemDictionary = pageDictionary[@"tabBarItem"];
                
                NSURL *pageURL = [NSURL URLWithString:pageDictionary[@"src"]];
                NSString *tabBarTitle = TSCLanguageDictionary(tabBarItemDictionary[@"title"]);
                UIImage *tabBarImage = [TSCImage imageWithDictionary:tabBarItemDictionary[@"image"]];

                TSCStormViewController *viewController = [[TSCStormViewController alloc] initWithURL:pageURL];
                viewController.tabBarItem.title = tabBarTitle;
                viewController.tabBarItem.image = [self tabBarImageWithImage:tabBarImage];
                
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
                [navigationController setPageIdentifier:pageDictionary[@"src"]];
                [viewControllers addObject:navigationController];
                
            }
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

- (UIImage *)tabBarImageWithImage:(UIImage *)originalImage
{
    CGRect rect;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        rect = CGRectMake(0, 0, 100, 100);
    } else {
        rect = CGRectMake(0, 0, 30, 30);
    }
    
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
    
    if (isPad()) {
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

@end
