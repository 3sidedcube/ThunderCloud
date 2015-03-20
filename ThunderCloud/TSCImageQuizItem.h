//
//  TSCImageSelectionQuestion.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCCollectionViewController.h"

@class TSCQuizItem;

/**
 A collection view which presents the user with a question and hint with a list of images (and associated text) to select from below
 
 This can be multiple or single selection
 */
@interface TSCImageQuizItem : TSCCollectionViewController

/**
 Initializes a new object with a given `TSCQuizItem`
 @param question The question to be displayed to the user
 */
- (instancetype)initWithQuestion:(TSCQuizItem *)question;

/**
 @abstract The quiz item being displayed in the `TSCCollectionViewController`
 */
@property (nonatomic, strong) TSCQuizItem *question;

@end
