//
//  TSCEditLocalisationTableViewCell.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 19/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

@import ThunderTable;

/**
 A cell for allowing the user to edit a localisation for a certain language
 */
@interface TSCEditLocalisationTableViewCell : TSCTableInputViewCell

/**
 @abstract Defines the placeholder for the input text view
 */
@property (nonatomic, copy) NSString *placeholder;

/**
 @abstract The text view that the user can use to edit the localisation
 */
@property (nonatomic, strong) UITextView *textView;


@end
