//
//  PCHUDActivityView.h
//  Glenigan
//
//  Created by Phillip Caudell on 03/05/2012.
//  Copyright (c) 2012 madebyphill.co.uk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PCHUDActivityViewStyleDefault = 0,
    PCHUDActivityViewStylePlain = 1
} PCHUDActivityViewStyle;

@interface PCHUDActivityView : UIView

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) NSInteger displayCount;

- (id)initWithStyle:(PCHUDActivityViewStyle)style;

+ (void)startInView:(UIView *)view style:(PCHUDActivityViewStyle)style;
+ (void)startInView:(UIView *)view;
+ (void)finishInView:(UIView *)view;
+ (PCHUDActivityView *)activityInView:(UIView *)view;

- (void)showInView:(UIView *)view;
- (void)finish;

@end
