//
//  TSCAchievementDisplayView.h
//  Swim
//
//  Created by Andrew Hart on 20/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 `TSCAchievementDisplayView` is a view for displaying an image and a subtitle as a pop up. Generally used for displying badges once they have been completed.
 */
@interface TSCAchievementDisplayView : UIView

/**
 @abstract A view representation of the subtitle, this is layed out under the image.
 */
@property (nonatomic, strong) UITextView *subtitleLabel;

/**
 Initializes a new instance of `TSCAchievementDisplayView`
 @param frame The size of the view
 @param image The image to be displayed in the view
 @param subtitle The subtitle to be displayed in the view
 */
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image subtitle:(NSString *)subtitle;

@end
