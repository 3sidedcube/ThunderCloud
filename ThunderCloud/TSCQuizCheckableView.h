//
//  TSCQuizCheckableView.h
//  ThunderCloud
//
//  Created by Sam Houghton on 16/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import <UIKit/UIKit.h>
@import ThunderTable;

/**
 A view which displays like a `UITableViewCell` with a check view in it.
 
 @discussion This has been created to avoid a horrible re-use issue with quizzes and will likely be re-written at a later stage
 */
@interface TSCQuizCheckableView : UIView

/**
 @abstract A label displaying the title of the 'cell'
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 @abstract The check view for the 'cell'
 */
@property (nonatomic, strong) TSCCheckView *checkView;

/**
 @abstract The current index path of the 'cell'
 */
@property (nonatomic, strong) NSIndexPath *indexPath;

@end
