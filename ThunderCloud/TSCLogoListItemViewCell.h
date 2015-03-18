//
//  TSCLogoListItemViewCell.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderTable;

/**
 `TSCLogoListItem` is a subclass of TSCListItem it is used to display company logos inside of an app.
 */
@interface TSCLogoListItemViewCell : TSCTableViewCell

/**
 @abstract The label that sits underneath the company logo. Normally used to display the name of the company
 */
@property (nonatomic, strong) UILabel *logoLabel;

@end
