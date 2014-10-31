//
//  TSCCollectionViewController.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCCollectionViewController.h"

@interface TSCCollectionViewController ()

@end

@implementation TSCCollectionViewController

- (id)init
{
    if (self = [super init]) {
        
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [self.flowLayout setMinimumInteritemSpacing:1.0f];
        [self.flowLayout setMinimumLineSpacing:1.0f];
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.collectionView];
        
        self.collectionView.alwaysBounceVertical = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.title) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"screen", @"name":self.title}];
    }
}

@end
