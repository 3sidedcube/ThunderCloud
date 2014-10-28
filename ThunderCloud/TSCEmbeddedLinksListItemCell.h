//
//  TSCTableButtonViewCell.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 04/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderTable;
@class TSCInlineButtonView;

@protocol TSCTableViewCellDelegate

- (void)button:(TSCInlineButtonView *)button wasTappedInCell:(TSCTableViewCell *)cell;

@end

@interface TSCEmbeddedLinksListItemCell : TSCTableViewCell

@property (nonatomic, strong) NSArray *buttonViews;
@property (nonatomic, weak) id <TSCTableViewCellDelegate> cellDelegate;

- (void)resetButtonViewsFromButtons:(NSArray *)buttons;

-(void)layoutButtons;

@end
