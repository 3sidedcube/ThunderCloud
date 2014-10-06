//
//  TSCButtonView.h
//  ThunderStorm
//
//  Created by Andrew Hart on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSCInlineButton.h"

typedef enum {
    ButtonDisabledReasonOther,
    ButtonDisabledReasonCallsNotSupported
} ButtonDisabledReason;

@class TSCInlineButtonView;

@protocol TSCInlineButtonViewInteractionDelegate <NSObject>

- (void)inlineButtonWasTapped:(TSCInlineButtonView *)button;

@end

@interface TSCInlineButtonView : UIButton

@property (nonatomic, strong) TSCInlineButton *button;
@property (nonatomic) BOOL disabled;
@property (nonatomic) ButtonDisabledReason buttonDisabledReason;
@property (nonatomic, weak) id <TSCInlineButtonViewInteractionDelegate> interactionDelegate;

@end