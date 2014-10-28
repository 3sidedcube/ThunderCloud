//
//  TSCTableHUDButtonRow.h
//  ThunderStorm
//
//  Created by Andrew Hart on 04/02/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

#import "TSCListItem.h"
#import "TSCTableHUDButtonViewCell.h"

@interface TSCHUDButtonListItemView : TSCListItem <TSCTableHUDButtonViewCellDelegate>

@property (nonatomic, strong) NSArray *buttons;

@end
