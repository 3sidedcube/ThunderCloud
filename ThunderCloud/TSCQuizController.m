//
//  TSCQuizController.m
//  ThunderStorm
//
//  Created by Andrew Hart on 30/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCQuizController.h"
#import "TSCContentController.h"

@implementation TSCQuizController

static TSCQuizController *sharedController = nil;

+ (TSCQuizController *)sharedController
{
    @synchronized(self) {
        
        if (sharedController == nil) {
            sharedController = [[self alloc] init];
        }
    }
    
    return sharedController;
}

- (id)init
{
    if (self = [super init]) {
        
        //Ready for badges
        self.quizzes = [NSMutableArray array];
        
        //Load up badges JSON
        NSString *quizzesFile = [[TSCContentController sharedController] pathForResource:@"app" ofType:@"json" inDirectory:nil];
        
        if (quizzesFile) {
            
            NSData *data = [NSData dataWithContentsOfFile:quizzesFile];
            NSDictionary *quizzesJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (quizzesJSON) {
                
                for (NSDictionary *dict in quizzesJSON[@"map"]) {
                    if ([dict[@"type"] isEqualToString:@"QuizPage"]) {
                        NSString *quizSrc = dict[@"src"];
                        NSString *quizId = [quizSrc stringByReplacingOccurrencesOfString:@"cache://pages/" withString:@""];
                        quizId = [quizId stringByReplacingOccurrencesOfString:@".json" withString:@""];
                        
                        NSLog(@"src: %@", quizSrc);
                        
                        [[TSCContentController sharedController] pageWithId:quizId completion:^(TSCListPage *listPage, NSError *error) {
                            NSLog(@"list page: %@", listPage);
                            NSLog(@"error: %@", error);
                        }];
                    }
                }
            }
        }
    }
    
    return self;
}

@end
