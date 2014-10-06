//
//  TSCAchievementDisplayView.h
//  Swim
//
//  Created by Andrew Hart on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define ACHIEVEMENT_DISPLAY_VIEW_SIZE CGSizeMake(255, 270)

@interface TSCAchievementDisplayView : UIView

- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image subtitle:(NSString *)subtitle;

@end
