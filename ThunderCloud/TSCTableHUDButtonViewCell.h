//
//  TSCTableHUDButtonViewCell.h
//  ThunderStorm
//
//  Created by Andrew Hart on 04/02/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCEmbeddedLinksListItemCell.h"

@class TSCTableHUDButtonViewCell;

@protocol TSCTableHUDButtonViewCellDelegate <NSObject>

-(void)hudButtonViewCell:(TSCTableHUDButtonViewCell *)cell buttonPressedAtIndex:(NSInteger)index;

@end

@interface TSCTableHUDButtonViewCell : TSCEmbeddedLinksListItemCell

@property (nonatomic, weak) id <TSCTableHUDButtonViewCellDelegate> delegate;

@end
