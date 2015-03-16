//
//  TSCVideoLanguageSelectionViewController.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 17/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCVideoLanguageSelectionViewController.h"

@interface TSCVideoLanguageSelectionViewController ()

@property (nonatomic, strong) NSArray *videos;

@end

@implementation TSCVideoLanguageSelectionViewController

- (instancetype)initWithVideos:(NSArray *)videos
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
        self.videos = videos;
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(dismissLanguageSelector)];
    }
    
    return self;
}

- (void)dismissLanguageSelector
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TSCTableSection *languageSection = [TSCTableSection sectionWithTitle:@"Languages" footer:nil items:self.videos target:self selector:@selector(videoSelected:)];
    
    self.dataSource = @[languageSection];
}

- (void)videoSelected:(TSCTableSelection *)selectedVideo
{
    [self.videoSelectionDelegate videoLanguageSelectionViewController:self didSelectVideo:(TSCVideo *)selectedVideo.object];
}

@end
