//
//  TSCEmbeddedLinksListInputItemCell.h
//  ThunderCloud
//
//  Created by Simon Mitchell on 29/10/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

@import ThunderTable;

@interface TSCEmbeddedLinksInputCheckItemCell : TSCTableInputCheckViewCell

@property (nonatomic, strong) NSArray *links;

@property (nonatomic, assign) BOOL hideUnavailableLinks;

@end
