//
//  TSCMultiVideoPlayerViewController.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 16/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCMultiVideoPlayerViewController.h"
#import "TSCVideo.h"
#import "TSCVideoLanguageSelectionViewController.h"
#import "TSCLink.h"
#import "TSCContentController.h"

@import ThunderBasics;

@interface TSCMultiVideoPlayerViewController () <TSCVideoLanguageSelectionViewControllerDelegate>

@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *endTimeLabel;
@property (nonatomic, strong) UISlider *videoProgressTracker;
@property (nonatomic, strong) UISlider *volumeView;

@property (nonatomic, strong) TSCLink *retryYouTubeLink;
@property (nonatomic, readwrite) BOOL dontReload;
@property (nonatomic, strong) UIColor *orginalBarTintColor;

@end

@implementation TSCMultiVideoPlayerViewController

- (id)initWithVideos:(NSArray *)videos
{
    if (self = [super init]) {
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(finishVideo)];
        self.navigationItem.titleView = [self titleViewForNavigationBar];
        self.orginalBarTintColor = self.navigationController.navigationBar.barTintColor;
        UINavigationBar *navigationBar = [UINavigationBar appearance];
        [navigationBar setBarTintColor:[UIColor colorWithRed:74.0f/255.0f green:75.0f/255.0f blue:77.0f/255.0f alpha:1.0]];
        
        self.videos = videos;
    }
    
    return self;
}

- (void)finishVideo
{
    [self.player pause];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect videoFrame = self.view.bounds;
    videoFrame.size.height -= 80;
    
    self.videoPlayerLayer.frame = videoFrame;
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor blackColor];
    [super viewDidLoad];
    TSCVideo *video = self.videos[0];
    [self loadYoutubeVideoForLink:video.videoLink];
    [self.view addSubview:[self playerControlsView]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    BOOL hasFoundVideo = NO;
    
    for (TSCVideo *video in self.videos) {
        
        if ([video.videoLink.linkClass isEqualToString:@"ExternalLink"]) {
            [self loadYoutubeVideoForLink:video.videoLink];
            hasFoundVideo = YES;
            break;
            
        } else if ([video.videoLink.linkClass isEqualToString:@"InternalLink"]) {
            
            NSString *path = [[TSCContentController sharedController] pathForCacheURL:video.videoLink.url];
            if (path) {
                [self playVideoWithURL:[NSURL fileURLWithPath:path]];
                hasFoundVideo = YES;
                break;
            }
        }
    }
    
    if (!hasFoundVideo) {
        
        TSCVideo *video = self.videos[0];
        
        if ([video.videoLink.linkClass isEqualToString:@"ExternalLink"]) {

            [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timeOutVideoLoad) userInfo:nil repeats:NO];
            [self loadYoutubeVideoForLink:video.videoLink];
            
        } else if ([video.videoLink.linkClass isEqualToString:@"InternalLink"]) {
            
            NSString *path = [[TSCContentController sharedController] pathForCacheURL:video.videoLink.url];
            if (path){
                [self playVideoWithURL:[NSURL fileURLWithPath:[[TSCContentController sharedController] pathForCacheURL:video.videoLink.url]]];
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    [navigationBar setBarTintColor:self.orginalBarTintColor];
}

- (void)playVideoWithURL:(NSURL *)url
{
    if (url) {
        
        self.player = [AVPlayer playerWithURL:url];
        self.player.volume = 0.5;
        self.videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        for (CALayer *layer in self.view.layer.sublayers) {
            
            if ([layer isKindOfClass:[AVPlayerLayer class]]) {
                [layer removeFromSuperlayer];
            }
        }
        
        [self.view.layer addSublayer:self.videoPlayerLayer];
        
        [self.player play];
        
        //Set volume control
        self.volumeView.value = self.player.volume;
        
        //Track time
        
        CMTime interval = CMTimeMake(33, 1000);
        
        __unsafe_unretained typeof(self) weakSelf = self;
        
        [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            
            CMTime endTime = CMTimeConvertScale (weakSelf.player.currentItem.asset.duration, weakSelf.player.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
            
            if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
                
                //Time progressed
                NSTimeInterval timeProgressed = CMTimeGetSeconds(weakSelf.player.currentTime);
                
                int progressedMin = timeProgressed / 60;
                int progressedSec = lroundf(timeProgressed) % 60;
                
                weakSelf.currentTimeLabel.text = [NSString stringWithFormat:@"%d:%0.2d", progressedMin, progressedSec];
                
                //End time
                NSTimeInterval totalTime = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
                
                int totalMin = totalTime / 60;
                int totalSec = lroundf(totalTime) % 60;
                
                weakSelf.endTimeLabel.text = [NSString stringWithFormat:@"%d:%0.2d", totalMin, totalSec];
                
                //Sync progress
                weakSelf.videoProgressTracker.maximumValue = CMTimeGetSeconds(weakSelf.player.currentItem.asset.duration);
                weakSelf.videoProgressTracker.value = CMTimeGetSeconds(weakSelf.player.currentTime);
                
            }
        }];
    }
}

#pragma mark - Player controls

- (UIView *)titleViewForNavigationBar
{
    //UIView to contain multiple elements for navigation bar
    UIView *progressContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 210, 44)];
    
    self.currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 12, progressContainer.bounds.size.width, 22)];
    self.currentTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.currentTimeLabel.font = [UIFont boldSystemFontOfSize:14];
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    self.currentTimeLabel.backgroundColor = [UIColor clearColor];
    self.currentTimeLabel.text = @"0:00";
    
    [progressContainer addSubview:self.currentTimeLabel];
    
    self.endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, progressContainer.bounds.size.width - 5, 22)];
    self.endTimeLabel.textAlignment = NSTextAlignmentRight;
    self.endTimeLabel.font = [UIFont boldSystemFontOfSize:14];
    self.endTimeLabel.textColor = [UIColor whiteColor];
    self.endTimeLabel.backgroundColor = [UIColor clearColor];
    self.endTimeLabel.text = @"0:00";
    
    [progressContainer addSubview:self.endTimeLabel];
    
    self.videoProgressTracker = [[UISlider alloc] initWithFrame:CGRectMake(44, 11, progressContainer.bounds.size.width - 88, 22)];
    [self.videoProgressTracker setThumbImage:[UIImage imageNamed:@"smallSlider" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.videoProgressTracker addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [progressContainer addSubview:self.videoProgressTracker];
    
    return progressContainer;
}

- (UIView *)playerControlsView
{
    //UIView to contain multiple elements for navigation bar
    UIView *playerControlsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 80, self.view.frame.size.width, 80)];
    playerControlsContainer.backgroundColor = [UIColor colorWithRed:74.0f/255.0f green:75.0f/255.0f blue:77.0f/255.0f alpha:1.0];
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake((playerControlsContainer.frame.size.width / 2) - 50, 0, 40, 43)];
    [playButton setImage:[UIImage imageNamed:@"mediaPauseButton" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
    [playerControlsContainer addSubview:playButton];
    
    UIButton *languageButton = [[UIButton alloc] initWithFrame:CGRectMake((playerControlsContainer.frame.size.width / 2) + 20, 0, 40, 43)];
    [languageButton setImage:[UIImage imageNamed:@"mediaLanguageButton" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [languageButton addTarget:self action:@selector(changeLanguage:) forControlEvents:UIControlEventTouchUpInside];
    [playerControlsContainer addSubview:languageButton];
    
    self.volumeView = [[UISlider alloc] initWithFrame:CGRectMake(44, playerControlsContainer.bounds.size.height - 40, playerControlsContainer.bounds.size.width - 88, 22)];
    [self.volumeView setThumbImage:[UIImage imageNamed:@"smallSlider" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.volumeView addTarget:self action:@selector(volumeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [playerControlsContainer addSubview:self.volumeView];
    
    return playerControlsContainer;
}

#pragma mark - Video selection delegate

- (void)videoLanguageSelectionViewController:(TSCVideoLanguageSelectionViewController *)view didSelectVideo:(TSCVideo *)video
{
    [self.player pause];
    [view dismissViewControllerAnimated:YES completion:nil];
    
    if ([video.videoLink.linkClass isEqualToString:@"ExternalLink"]) {

        [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timeOutVideoLoad) userInfo:nil repeats:NO];
        [self loadYoutubeVideoForLink:video.videoLink];
    } else if ([video.videoLink.linkClass isEqualToString:@"InternalLink"]) {
        
        NSString *path = [[TSCContentController sharedController] pathForCacheURL:video.videoLink.url];
        if (path) {
            [self playVideoWithURL:[NSURL fileURLWithPath:[[TSCContentController sharedController] pathForCacheURL:video.videoLink.url]]];
        }
    }
}

#pragma mark - Video navigation handling

- (void)sliderValueChanged:(UISlider *)sender
{
    [self.player seekToTime:CMTimeMake(sender.value, 1)];
}

- (void)volumeSliderValueChanged:(UISlider *)sender
{
    self.player.volume = sender.value;
}

- (void)playPause:(UIButton *)sender
{
    if (self.player.rate == 0.0) {
        
        [sender setImage:[UIImage imageNamed:@"mediaPauseButton" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.player play];
        
    } else {
        
        [sender setImage:[UIImage imageNamed:@"mediaPlayButton" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.player pause];
    }
}

- (void)changeLanguage:(UIButton *)sender
{
    TSCVideoLanguageSelectionViewController *selectedLanguageView = [[TSCVideoLanguageSelectionViewController alloc] initWithVideos:self.videos];
    selectedLanguageView.videoSelectionDelegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:selectedLanguageView];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Youtube URL osurcing

- (void)loadYoutubeVideoForLink:(TSCLink *)link
{
    // Extract video ID
    NSString *youtubeId = [link.url.absoluteString componentsSeparatedByString:@"?v="][1];
    
    // Download the file
    NSURLRequest *fileDownload = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/get_video_info?video_id=%@", youtubeId]] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    
    [NSURLConnection sendAsynchronousRequest:fileDownload queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (data.length < 200) {
            
            self.retryYouTubeLink = link;
            
            if (self.dontReload) {

                UIAlertView *unableToPlay = [[UIAlertView alloc] initWithTitle:@"An error has occured" message:@"Sorry, we are unable to play this video. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Retry", nil];
                unableToPlay.tag = 2;
                [unableToPlay show];
            } else {
                [self loadYoutubeVideoForLink:self.retryYouTubeLink];
            }
            
            return;
        }
        
        // Convert data to response string
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        // Break the response into an array by ampersand
        NSArray *parts = [responseString componentsSeparatedByString:@"&"];
        
        // Search for the string that contains video info
        BOOL foundStream = NO;
        
        for (NSString *part in parts) {
            
            if ([part rangeOfString:@"url_encoded_fmt_stream_map"].location != NSNotFound) {
                
                foundStream = YES;
                
                // Break out parts to find URL's
                NSArray *streamParts = [[[part stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"url_encoded_fmt_stream_map" withString:@""] componentsSeparatedByString:@","];
                
                NSMutableDictionary *videoDictionary = [NSMutableDictionary dictionary];
                
                // Loop each version (Multiple quality);
                for (NSString *streamPart in streamParts) {
                    
                    NSMutableDictionary *dictionaryForQuality = [NSMutableDictionary dictionary];
                    
                    // Loop each part and convert into dictionary
                    NSArray *urlParts = [streamPart componentsSeparatedByString:@"&"];
                    
                    for (NSString *dictionaryItem in urlParts) {
                        
                        NSArray *keyArray = [dictionaryItem componentsSeparatedByString:@"="];
                        
                        [dictionaryForQuality setObject:keyArray[1] forKey:keyArray[0]];
                    }
                    
                    
                    if (![dictionaryForQuality objectForKey:@"sig"]) { // Seems the & before sig is sometimes URL encoded. If we haven't already pulled it out, let's decode then pull it out.
                        
                        NSString *decodedStreamPart = [streamPart stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        NSArray *decodedUrlParts = [decodedStreamPart componentsSeparatedByString:@"&"];
                        
                        [decodedUrlParts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) { // Let's find the signature...
                            
                            if ([obj isKindOfClass:[NSString class]]) {
                             
                                NSArray *keyArray = [(NSString *)obj componentsSeparatedByString:@"="];
                                
                                if ([keyArray[0] isEqualToString:@"sig"] || [keyArray[0] isEqualToString:@"signature"]) {
                                    
                                    [dictionaryForQuality setObject:keyArray[1] forKey:@"sig"];
                                    *stop = true;
                                }
                            }
                        }];
                    }
                    
                    if (dictionaryForQuality[@"quality"]) {
                        [videoDictionary setObject:dictionaryForQuality forKey:dictionaryForQuality[@"quality"]];
                    } else {
                        break;
                    }
                }
                
                //Check for quality
                NSString *quality;
                
                if (videoDictionary[@"medium"]) {
                    quality = @"medium";
                } else if (videoDictionary[@"small"]) {
                    quality = @"small";
                }
                
                if (quality) {
                    
                    //Present the video
                    [self playVideoWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"%@&signature=%@", videoDictionary[quality][@"url"], videoDictionary[quality][@"sig"]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                    
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Video", @"action":[NSString stringWithFormat:@"YouTube - %@", link.url.absoluteString]}];
                    
                    break;
                    
                } else {
                    
                    self.retryYouTubeLink = link;
                    
                    if (self.dontReload) {
                    //Present error if no video was returned
                        UIAlertView *unableToPlay = [[UIAlertView alloc] initWithTitle:@"An error has occured" message:@"Sorry, we are unable to play this video. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Retry", nil];
                        unableToPlay.tag = 2;
                        [unableToPlay show];
                    } else {
                        [self loadYoutubeVideoForLink:self.retryYouTubeLink];
                    }
                }
            }
        }
        
        if (!foundStream) {
            
            // retryYouTubeLink = link;
            self.retryYouTubeLink = link;
            
            if (self.dontReload) {
                
                UIAlertView *unableToPlay = [[UIAlertView alloc] initWithTitle:@"An error has occured" message:@"Sorry, we are unable to play this video. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Retry", nil];
                unableToPlay.tag = 2;
                [unableToPlay show];
                
            } else {
                [self loadYoutubeVideoForLink:self.retryYouTubeLink];
            }
        }
    }];
}

- (void)timeOutVideoLoad
{
    self.dontReload = true;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timeOutVideoLoad) userInfo:nil repeats:NO];
        [self loadYoutubeVideoForLink:self.retryYouTubeLink];
    }
}

@end
