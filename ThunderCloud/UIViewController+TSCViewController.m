//
//  UIViewController+TSCViewController.m
//  ThunderCloud
//
//  Created by Phillip Caudell on 20/05/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "UIViewController+TSCViewController.h"
#import <objc/runtime.h>

@implementation UIViewController (TSCViewController)

- (void)setPageIdentifier:(id)identifier
{
    objc_setAssociatedObject(self, @selector(pageIdenitifer), identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)pageIdenitifer
{
    return objc_getAssociatedObject(self, @selector(pageIdenitifer));
}

@end
