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

/**
 This view is presented by the video player when a user attempts to switch languages.
 
 It will display a list of languages for which a video is available
 */
@interface TSCVideoLanguageSelectionViewController : TSCTableViewController

/**
 The delegate that will be called when a new language is selected
 */
@property (nonatomic, weak) id <TSCVideoLanguageSelectionViewControllerDelegate> videoSelectionDelegate;

/**
 Initialises the language selector with the array of videos, usually passed from the video player
 @param An array of TSCVideo objects
 */
- (instancetype)initWithVideos:(NSArray *)videos;

@end
