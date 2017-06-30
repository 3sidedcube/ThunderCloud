//
//  TSCVideo.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 16/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@import Foundation;
@import ThunderTable;
#import "TSCLink.h"

/**
 A video object containing information about a video that can be played by the multi video player
 */
@interface TSCVideo : NSObject /*<TSCTableRowDataSource>*/

/**
 The string representation of the locale that the video language is in.
 */
@property (nonatomic, copy) NSString *videoLocaleString;

/**
 The locale that the video lanugage is in
 */
@property (nonatomic, strong) NSLocale *videoLocale;

/**
 The link to the video file or relevant YouTube link
 */
@property (nonatomic, strong) TSCLink *videoLink;


/**
 Initialises the video object with an array of information provided by Storm
 @param dictionary A storm dictionary object to initialise the video object with
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
