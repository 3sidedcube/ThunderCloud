 //
//  TSCMultiVideoPlayerViewController.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 16/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCMultiVideoPlayerViewController.h"
#import "TSCLink.h"
#import "ThunderCloud/ThunderCloud-Swift.h"
#import "TSCVideoPlayerControlsView.h"
#import "TSCVideoScrubViewController.h"
#import "TSCStormLanguageController.h"

@import ThunderBasics;

@interface TSCMultiVideoPlayerViewController () <TSCVideoLanguageSelectionViewControllerDelegate>

@property (nonatomic, strong) TSCLink *retryYouTubeLink;
@property (nonatomic, readwrite) BOOL dontReload;
@property (nonatomic, assign) BOOL languageSwitched;
@property (nonatomic, strong) UIColor *originalBarTintColor;
@property (nonatomic, strong) UIActivityIndicatorView *activity;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *videoPlayerLayer;
@property (nonatomic, strong) NSArray *videos;
@property (nonatomic, strong) TSCVideoPlayerControlsView *playerControlsView;
@property (nonatomic, strong) TSCVideoScrubViewController *videoScrubView;
@end

@implementation TSCMultiVideoPlayerViewController

#pragma mark - Video selection delegate


#pragma mark - Video navigation handling

#pragma mark - Youtube URL osurcing

- (void)loadYoutubeVideoForLink:(TSCLink *)link
{
    // Extract video ID
    NSString *youtubeId = [link.url.absoluteString componentsSeparatedByString:@"?v="][1];
    
    // Download the file
    NSURLRequest *fileDownload = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.youtube.com/get_video_info?video_id=%@", youtubeId]] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30];
    
    NSURLSession *session = [NSURLSession sharedSession];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:fileDownload completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    
        if (data.length < 200) {
            
            self.retryYouTubeLink = link;
            
            if (self.dontReload) {
                
                UIAlertController *unableToPlayAlert = [UIAlertController alertControllerWithTitle:@"An error has occured" message:@"Sorry, we are unable to play this video. Please try again" preferredStyle:UIAlertControllerStyleAlert];
                
                [unableToPlayAlert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
                
                [unableToPlayAlert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timeOutVideoLoad) userInfo:nil repeats:NO];
                    [self loadYoutubeVideoForLink:self.retryYouTubeLink];
                }]];
                
                
                [self presentViewController:unableToPlayAlert animated:true completion:nil];
                
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
                NSArray *streamParts = [[[part stringByRemovingPercentEncoding] stringByReplacingOccurrencesOfString:@"url_encoded_fmt_stream_map" withString:@""] componentsSeparatedByString:@","];
                
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
                        
                        NSString *decodedStreamPart = [streamPart stringByRemovingPercentEncoding];
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
                
                if (quality &&
                    videoDictionary[quality] &&
                    [videoDictionary[quality] isKindOfClass:[NSDictionary class]] &&
                    videoDictionary[quality][@"url"] &&
                    [videoDictionary[quality][@"url"] isKindOfClass:[NSString class]] &&
                    videoDictionary[quality][@"sig"] &&
                    [videoDictionary[quality][@"sig"] isKindOfClass:[NSString class]]) {
                    
                    //Present the video
                    [self playVideoWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"%@&signature=%@", videoDictionary[quality][@"url"], videoDictionary[quality][@"sig"]] stringByRemovingPercentEncoding]]];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Video", @"action":[NSString stringWithFormat:@"YouTube - %@", link.url.absoluteString]}];
                    
                    break;
                    
                } else {
                    
                    self.retryYouTubeLink = link;
                    
                    if (self.dontReload) {
                        //Present error if no video was returned
                        UIAlertController *unableToPlayAlert = [UIAlertController alertControllerWithTitle:@"An error has occured" message:@"Sorry, we are unable to play this video. Please try again" preferredStyle:UIAlertControllerStyleAlert];
                        
                        [unableToPlayAlert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
                        
                        [unableToPlayAlert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            
                            [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timeOutVideoLoad) userInfo:nil repeats:NO];
                            [self loadYoutubeVideoForLink:self.retryYouTubeLink];
                        }]];
                        
                        
                        [self presentViewController:unableToPlayAlert animated:true completion:nil];
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
                
                UIAlertController *unableToPlayAlert = [UIAlertController alertControllerWithTitle:@"An error has occured" message:@"Sorry, we are unable to play this video. Please try again" preferredStyle:UIAlertControllerStyleAlert];
                
                [unableToPlayAlert addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
                
                [unableToPlayAlert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timeOutVideoLoad) userInfo:nil repeats:NO];
                    [self loadYoutubeVideoForLink:self.retryYouTubeLink];
                }]];
                
                
                [self presentViewController:unableToPlayAlert animated:true completion:nil];
                
            } else {
                [self loadYoutubeVideoForLink:self.retryYouTubeLink];
            }
        }
    }];
    
    [dataTask resume];
}

- (void)timeOutVideoLoad
{
    self.dontReload = true;
}

@end
