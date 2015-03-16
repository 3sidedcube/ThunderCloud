//
//  TSCVideoLanguageSelectionViewController.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 17/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@import ThunderTable;

@class TSCVideo;
@class TSCVideoLanguageSelectionViewController;

@protocol TSCVideoLanguageSelectionViewControllerDelegate <NSObject>

@required

- (void)videoLanguageSelectionViewController:(TSCVideoLanguageSelectionViewController *)view didSelectVideo:(TSCVideo *)video;

@end

@interface TSCVideoLanguageSelectionViewController : TSCTableViewController

@property (nonatomic, weak) id <TSCVideoLanguageSelectionViewControllerDelegate> videoSelectionDelegate;

- (instancetype)initWithVideos:(NSArray *)videos;

@end
