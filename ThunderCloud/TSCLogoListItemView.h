//
//  TSCLogoListItemView.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/10/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCStandardListItemView.h"

@interface TSCLogoListItemView : TSCStandardListItemView

@property (nonatomic, strong) NSString *logoTitle;

- (id)initWithDictionary:(NSDictionary *)dictionary parentObject:(id)parentObject styler:(TSCStormStyler *)styler;

@end
