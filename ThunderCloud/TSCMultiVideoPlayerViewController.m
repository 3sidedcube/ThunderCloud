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

@interface TSCMultiVideoPlayerViewController () <TSCVideoLanguageSelectionViewControllerDelegate>

@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *endTimeLabel;
@property (nonatomic, strong) UISlider *videoProgressTracker;
@property (nonatomic, strong) UISlider *volumeView;

@end

@implementation TSCMultiVideoPlayerViewController

- (id)initWithVideos:(NSArray *)videos
{
    self = [super init];
    if (self) {
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(finishVideo)];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"FS" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.titleView = [self titleViewForNavigationBar];
        
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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)playVideoWithURL:(NSURL *)url
{
    self.player = [AVPlayer playerWithURL:url];
    
    self.player.volume = 0.5;
    
    self.videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    for (CALayer *layer in self.view.layer.sublayers) {
        
        if([layer isKindOfClass:[AVPlayerLayer class]]){
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

            weakSelf.videoProgressTracker.maximumValue = CMTimeGetSeconds(weakSelf.player.currentItem.duration);
            weakSelf.videoProgressTracker.value = CMTimeGetSeconds(weakSelf.player.currentTime);
            
        }
    }];
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
    [self.videoProgressTracker setThumbImage:[UIImage imageNamed:@"smallSlider"] forState:UIControlStateNormal];
    [self.videoProgressTracker addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [progressContainer addSubview:self.videoProgressTracker];
    
    return progressContainer;
}

- (UIView *)playerControlsView
{
    //UIView to contain multiple elements for navigation bar
    UIView *playerControlsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 80, self.view.frame.size.width, 80)];
//    [playerControlsContainer setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"UINavigationBar-bg"]]];
    playerControlsContainer.backgroundColor = [UIColor colorWithRed:74.0f/255.0f green:75.0f/255.0f blue:77.0f/255.0f alpha:1.0];
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake((playerControlsContainer.frame.size.width / 2) - 50, 0, 40, 43)];
    [playButton setImage:[UIImage imageNamed:@"mediaPauseButton"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
    [playerControlsContainer addSubview:playButton];
    
    UIButton *languageButton = [[UIButton alloc] initWithFrame:CGRectMake((playerControlsContainer.frame.size.width / 2) + 20, 0, 40, 43)];
    [languageButton setImage:[UIImage imageNamed:@"mediaLanguageButton"] forState:UIControlStateNormal];
    [languageButton addTarget:self action:@selector(changeLanguage:) forControlEvents:UIControlEventTouchUpInside];
    [playerControlsContainer addSubview:languageButton];
    
    self.volumeView = [[UISlider alloc] initWithFrame:CGRectMake(44, playerControlsContainer.bounds.size.height - 40, playerControlsContainer.bounds.size.width - 88, 22)];
    [self.volumeView setThumbImage:[UIImage imageNamed:@"smallSlider"] forState:UIControlStateNormal];
    [self.volumeView addTarget:self action:@selector(volumeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [playerControlsContainer addSubview:self.volumeView];
    
    return playerControlsContainer;
}

#pragma mark - Video selection delegate

- (void)videoLanguageSelectionViewController:(TSCVideoLanguageSelectionViewController *)view didSelectVideo:(TSCVideo *)video
{
    [self.player pause];
    [view dismissViewControllerAnimated:YES completion:nil];
    
    [self loadYoutubeVideoForLink:video.videoLink];

}


#pragma mark - Video navigation handling

- (void)sliderValueChanged:(UISlider *)sender
{
    [self.player seekToTime:CMTimeMake(sender.value, 1)];
}

- (void)volumeSliderValueChanged:(UISlider *)sender
{
    self.player.volume = sender.value;
    
//    AVAsset *asset = [[self.player currentItem] asset];
//    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
//    
//    // Mute all the audio tracks
//    NSMutableArray *allAudioParams = [NSMutableArray array];
//    for (AVAssetTrack *track in audioTracks) {
//        AVMutableAudioMixInputParameters *audioInputParams =    [AVMutableAudioMixInputParameters audioMixInputParameters];
//        [audioInputParams setVolume:sender.value atTime:kCMTimeZero];
//        [audioInputParams setTrackID:[track trackID]];
//        [allAudioParams addObject:audioInputParams];
//    }
//    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
//    [audioZeroMix setInputParameters:allAudioParams];
//    
//    [[self.player currentItem] setAudioMix:audioZeroMix];
    
}

- (void)playPause:(UIButton *)sender
{
    if(self.player.rate == 0.0){
        
        [sender setImage:[UIImage imageNamed:@"mediaPauseButton"] forState:UIControlStateNormal];
        [self.player play];
        
    } else {
        
        [sender setImage:[UIImage imageNamed:@"mediaPlayButton"] forState:UIControlStateNormal];
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
    //Extract video ID
    NSString *youtubeId = [link.url.absoluteString componentsSeparatedByString:@"?v="][1];
    
    //Download the file
    NSURLRequest *fileDownload = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/get_video_info?video_id=%@", youtubeId]] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    
    [NSURLConnection sendAsynchronousRequest:fileDownload queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (data.length < 200) {
            //            retryYouTubeLink = link;
            
            UIAlertView *unableToPlay = [[UIAlertView alloc] initWithTitle:@"An error has occured" message:@"Sorry, we are unable to play this video. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Retry", nil];
            unableToPlay.tag = 2;
            [unableToPlay show];
            return;
        }
        
        //Convert data to response string
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        //Break the response into an array by ampersand
        NSArray *parts = [responseString componentsSeparatedByString:@"&"];
        
        //Search for the string that contains video info
        
        BOOL foundStream = NO;
        
        for (NSString *part in parts) {
            
            if ([part rangeOfString:@"url_encoded_fmt_stream_map"].location != NSNotFound) {
                
                foundStream = YES;
                
                //Break out parts to find URL's
                NSArray *streamParts = [[[part stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"url_encoded_fmt_stream_map" withString:@""] componentsSeparatedByString:@","];
                
                NSMutableDictionary *videoDictionary = [NSMutableDictionary dictionary];
                
                //Loop each version (Multiple quality);
                
                for (NSString *streamPart in streamParts) {
                    
                    NSMutableDictionary *dictionaryForQuality = [NSMutableDictionary dictionary];
                    
                    //Loop each part and convert into dictionary
                    NSArray *urlParts = [streamPart componentsSeparatedByString:@"&"];
                    
                    for (NSString *dictionaryItem in urlParts) {
                        
                        NSArray *keyArray = [dictionaryItem componentsSeparatedByString:@"="];
                        
                        [dictionaryForQuality setObject:keyArray[1] forKey:keyArray[0]];
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
                    
                    //                    retryYouTubeLink = link;
                    
                    //Present error if no video was returned
                    UIAlertView *unableToPlay = [[UIAlertView alloc] initWithTitle:@"An error has occured" message:@"Sorry, we are unable to play this video. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Retry", nil];
                    unableToPlay.tag = 2;
                    [unableToPlay show];
                }
            }
        }
        
        if (!foundStream) {
            
            //            retryYouTubeLink = link;
            
            UIAlertView *unableToPlay = [[UIAlertView alloc] initWithTitle:@"An error has occured" message:@"Sorry, we are unable to play this video. Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Retry", nil];
            unableToPlay.tag = 2;
            [unableToPlay show];
        }
    }];
}

@end
