//
//  TSCTableButtonViewCell.h
//  ThunderStorm
//
//  Created by Phillip Caudell on 04/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

@import ThunderTable;

@interface TSCEmbeddedLinksListItemCell : TSCTableViewCell

@property (nonatomic, strong) NSArray *links;

@property (nonatomic, assign) BOOL hideUnavailableLinks;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

- (void)layoutLinks;

@end
