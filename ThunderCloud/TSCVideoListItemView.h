//
//  TSCVideoListItemView.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 27/09/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCImageListItem.h"

/**
 A storm object representation of a video 
 */
@interface TSCVideoListItemView : TSCImageListItem

/**
 The length of the video in seconds
 */
@property (nonatomic) NSTimeInterval duration;

@end
