//
//  TSCCollectionCell.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 26/05/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

#import "TSCCollectionCell.h"

@interface TSCCollectionCell ()

@property (nonatomic) NSInteger currentPage;

@property (nonatomic) BOOL nibBased;

@end

@implementation TSCCollectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIImage *backgroundImage = [[UIImage imageNamed:@"TSCPortalViewCell-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        [self.contentView addSubview:self.backgroundView];
        
        self.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
        [self.contentView addSubview:self.collectionView];
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 17, self.frame.size.width, 16)];
        [self.contentView addSubview:self.pageControl];
        
        [self sharedInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
    self.pageControl.currentPage = 0;
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.currentPageIndicatorTintColor = [[TSCThemeManager sharedTheme] mainColor];
    self.pageControl.userInteractionEnabled = NO;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self.collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self sharedInit];
    self.nibBased = true;
}

- (void)dealloc
{
    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.nibBased) {
        self.collectionView.frame = self.bounds;
        self.pageControl.numberOfPages = MAX(1, ceil(self.collectionView.contentSize.width / self.collectionView.frame.size.width));
        self.pageControl.frame = CGRectMake(0, self.bounds.size.height - 17, self.bounds.size.width, 12);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
}

- (void)reload
{
    [self.collectionView reloadData];
    self.pageControl.numberOfPages = ceil(self.collectionView.contentSize.width / self.collectionView.frame.size.width);
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float page = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.currentPage = ceil(page);
}

#pragma mark - Setter methods

- (void)setCurrentPage:(NSInteger)currentPage
{
    _currentPage = currentPage;
    self.pageControl.currentPage = currentPage;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    self.pageControl.numberOfPages = ceil(self.collectionView.contentSize.width / self.collectionView.frame.size.width);
}

@end
