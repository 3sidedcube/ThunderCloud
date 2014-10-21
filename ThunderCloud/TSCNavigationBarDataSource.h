//
//  TSCNavigationBarDataSource.h
//  ThunderCloud
//
//  Created by Phillip Caudell on 10/04/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TSCNavigationBarDataSource <NSObject>

@optional
- (BOOL)shouldHideNavigationBar;

@end
