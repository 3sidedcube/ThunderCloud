//
//  TSCButtonView.h
//  ThunderStorm
//
//  Created by Simon Mitchell on 12/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TSCLink;

@interface TSCInlineButtonView : UIButton

@property (nonatomic, strong) TSCLink *link;
@property (nonatomic) BOOL disabled;

@end