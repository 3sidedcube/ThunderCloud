//
//  TSCTipViewController.m
//  ThunderStorm
//
//  Created by Andrew Hart on 30/12/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCPlaceholderViewController.h"
@import ThunderTable;
@import ThunderBasics;

@interface TSCPlaceholderViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation TSCPlaceholderViewController

- (instancetype)init
{
    if (self = [super init]) {
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:36];
        self.titleLabel.textColor = [UIColor colorWithHexString:@"4b4949"];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = self.title;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.titleLabel];
        
        self.descriptionLabel = [[UILabel alloc] init];
        self.descriptionLabel.font = [UIFont systemFontOfSize:20];
        self.descriptionLabel.textColor = [UIColor colorWithHexString:@"7b7b7f"];
        self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
        self.descriptionLabel.numberOfLines = 100;
        self.descriptionLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.descriptionLabel];
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.frame = CGRectMake(0, 0, 150, 150);
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:self.imageView];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [TSCThemeManager sharedManager].theme.backgroundColor;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self _TSCLayoutSubviews];
}

- (void)_TSCLayoutSubviews
{
    self.imageView.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - (self.imageView.frame.size.height / 2));
    
    float width = self.view.frame.size.width / 2;
    
    self.titleLabel.frame = CGRectMake((self.view.frame.size.width - width) / 2, (self.view.frame.size.height / 2), self.view.frame.size.width / 2, 50);
    
    CGSize constrainedSize = CGSizeMake(self.view.frame.size.width / 2, MAXFLOAT);
    CGSize descriptionLabelSize = [self.descriptionLabel sizeThatFits:constrainedSize];
    self.descriptionLabel.frame = CGRectMake((self.view.frame.size.width - descriptionLabelSize.width) / 2, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 15, descriptionLabelSize.width, descriptionLabelSize.height);
}

#pragma mark - Setter methods

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    
    self.titleLabel.text = self.title;
    
    [self _TSCLayoutSubviews];
}

- (void)setPlaceholderDescription:(NSString *)placeholderDescription
{
    _placeholderDescription = placeholderDescription;
    
    self.descriptionLabel.text = self.placeholderDescription;
    
    [self _TSCLayoutSubviews];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    self.imageView.image = _image;
    
    [self _TSCLayoutSubviews];
}

@end
