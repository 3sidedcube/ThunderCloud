//
//  TSCButtonListItemViewCell.h
//  ThunderStorm
//
//  Created by Andrew Hart on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCEmbeddedLinksListItemCell.h"
#import "TSCInlineButtonView.h"

@class TSCButtonListItemViewCell;

@protocol TSCButtonListItemViewCellDelegate

- (void)button:(TSCInlineButtonView *)button wasTappedInTSCButtonListItemViewCell:(TSCButtonListItemViewCell *)cell;

@end

@interface TSCButtonListItemViewCell : TSCEmbeddedLinksListItemCell

@property (nonatomic, strong) NSArray *buttonViews;
@property (nonatomic, weak) id <TSCButtonListItemViewCellDelegate> delegate;

@end