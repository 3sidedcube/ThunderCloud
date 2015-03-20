//
//  TSCQuizResponseTextOption.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import Foundation;
@import ThunderTable;

/**
 A model representation of an option the user can select from in a `TSCTextQuizItem` question
 */
@interface TSCQuizResponseTextOption : NSObject

/**
 @abstract Initializes a new text option from a CMS representation of an option
 @param dictionary The dictionary to initialize and populate the class with
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 @abstract The title of the response option
 */
@property (nonatomic, copy) NSString *title;

@end
