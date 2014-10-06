//
//  TSCNavigationControllerController.m
//  ThunderCloud
//
//  Created by Phillip Caudell on 10/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCNavigationController.h"

@interface TSCNavigationController ()

@property (nonatomic, assign) CGFloat currentOffsetY;

@end

@implementation TSCNavigationController

- (NSString *)rowTitle
{
    return self.topViewController.tabBarItem.title;
}

- (UIImage *)rowImage
{
    return self.topViewController.tabBarItem.image;
}

- (UITableViewCell *)tableViewCell:(UITableViewCell *)cell
{
    [cell setHighlighted:self.selected animated:YES];
    
    return cell;
}

- (BOOL)shouldRemainSelected
{
    return YES;
}

@end
