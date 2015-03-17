//
//  TSCMultiVideoListItemView.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 16/01/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCVideoListItemView.h"

/**
 A storm object representation of a video view
 */
@interface TSCVideoListItem : TSCVideoListItemView

/**
 The array of videos that are available to be played when this video item is activated
 */
@property (nonatomic, strong) NSMutableArray *videos;

@end
