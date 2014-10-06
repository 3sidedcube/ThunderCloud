//
//  TSCQuizController.h
//  ThunderStorm
//
//  Created by Andrew Hart on 30/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCQuizController : NSObject

@property (nonatomic, strong) NSMutableArray *quizzes;

+ (TSCQuizController *)sharedController;

@end
