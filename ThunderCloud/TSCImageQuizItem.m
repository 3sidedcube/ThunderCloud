//
//  TSCImageSelectionQuestion.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 14/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCImageQuizItem.h"
#import "TSCQuizQuestion.h"
#import "TSCQuizCollectionViewCell.h"
#import "TSCQuizResponseTextOption.h"
#import "TSCQuizCollectionHeaderView.h"
#import "UIView+Pop.h"
#import "TSCImage.h"

@interface TSCImageQuizItem ()

@property (nonatomic) BOOL isAnimating;
@property (nonatomic) BOOL hasFinishedAnimatingIn;
@property (nonatomic, strong) NSIndexPath *selectedItemIndexPath;
@property (nonatomic, strong) UIDynamicAnimator *animator;

@end

@implementation TSCImageQuizItem

- (id)initWithQuestion:(TSCQuizQuestion *)question
{
    self = [super init];
    
    if (self) {
        
        self.question = question;
        
       // self.animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self.collectionViewLayout];
        
        [self.collectionView registerClass:[TSCQuizCollectionViewCell class] forCellWithReuseIdentifier:@"StandardCell"];
        [self.collectionView registerClass:[TSCQuizCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"QuizQuestionView"];
        
        [self configureCollectionViewLayoutWithOrientation:self.interfaceOrientation];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.hasFinishedAnimatingIn = YES;
        });
        
        self.collectionView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    }
    
    return self;
}

- (void)configureCollectionViewLayoutWithOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.flowLayout setItemSize:CGSizeMake(159.5, 159.5)];
    } else {
        
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            
            [self.flowLayout setItemSize:CGSizeMake(225, 225)];
            [self.flowLayout setSectionInset:UIEdgeInsetsMake(20, 80, 0, 80)];
            [self.flowLayout setMinimumInteritemSpacing:20];
            [self.flowLayout setMinimumLineSpacing:20];
            
        } else {
            
            [self.flowLayout setItemSize:CGSizeMake(200, 200)];
            [self.flowLayout setSectionInset:UIEdgeInsetsMake(20, 60, 60, 60)];
            [self.flowLayout setMinimumInteritemSpacing:20];
            [self.flowLayout setMinimumLineSpacing:20];
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self configureCollectionViewLayoutWithOrientation:toInterfaceOrientation];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.hasFinishedAnimatingIn = YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection view data source

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        TSCQuizCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"QuizQuestionView" forIndexPath:indexPath];
        headerView.question = self.question;
        
        return headerView;
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.frame.size.width, [self heightOfQuestionText]);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.question.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"StandardCell" forIndexPath:indexPath];
    
    TSCQuizCollectionViewCell *standardCell = (TSCQuizCollectionViewCell *)cell;
    standardCell.imageView.image = [TSCImage imageWithDictionary:self.question.images[indexPath.item]];
    standardCell.layer.cornerRadius = 4.0f;
    standardCell.layer.masksToBounds = YES;
    standardCell.textLabel.text = ((TSCQuizResponseTextOption *)self.question.options[indexPath.item]).title;
    standardCell.backgroundColor = [UIColor clearColor];
    
    if (standardCell.textLabel.text.length > 0) {
        [standardCell.contentView addSubview:standardCell.gradientImageView];
        [standardCell.contentView bringSubviewToFront:standardCell.gradientImageView];
        [standardCell.contentView bringSubviewToFront:standardCell.textLabel];
    } else {
        [standardCell.gradientImageView removeFromSuperview];
    }
    
    standardCell.contentView.layer.borderColor = [[TSCThemeManager sharedTheme] mainColor].CGColor;
    standardCell.contentView.layer.borderWidth = 0.0f;
    
    standardCell.contentView.alpha = 1;
    
    if (self.hasFinishedAnimatingIn && [self.question.selectedIndexes containsObject:indexPath]) {
        
        if (!self.isAnimating && self.selectedItemIndexPath.row == indexPath.row && self.selectedItemIndexPath.section == indexPath.section) {
            
            UIGraphicsBeginImageContextWithOptions(standardCell.contentView.frame.size, NO, [UIScreen mainScreen].scale);
            [standardCell.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = standardCell.frame;
            imageView.image = viewImage;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.cornerRadius = 4.0f;
            [self.collectionView addSubview:imageView];
            
            
            standardCell.contentView.alpha = 0;
            
            imageView.layer.borderColor = standardCell.contentView.layer.borderColor;
            
            float speed = 0.09;
            
            if ([TSCThemeManager isOS7]) {
                
                [imageView popIn];
                
                CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                                  animationWithKeyPath:@"transform"];
                
                CATransform3D scale1 = CATransform3DMakeScale(1, 1, 1);
                CATransform3D scale2 = CATransform3DMakeScale(0.85, 0.85, 1);
                CATransform3D scale3 = CATransform3DMakeScale(1.1, 1.1, 1);
                CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
                
                NSArray *frameValues = @[[NSValue valueWithCATransform3D:scale1],
                                         [NSValue valueWithCATransform3D:scale2],
                                         [NSValue valueWithCATransform3D:scale3],
                                         [NSValue valueWithCATransform3D:scale4]];
                [animation setValues:frameValues];
                
                animation.fillMode = kCAFillModeForwards;
                animation.removedOnCompletion = NO;
                animation.duration = 0.5;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
                
                [imageView.layer addAnimation:animation forKey:nil];
                
                standardCell.contentView.layer.borderWidth = 4;
                standardCell.layer.cornerRadius = 4.0f;
                standardCell.layer.masksToBounds = YES;
                imageView.layer.borderWidth = standardCell.contentView.layer.borderWidth;
                imageView.layer.masksToBounds = YES;
                imageView.layer.cornerRadius = 4.0f;
                
            } else {
                
                self.isAnimating = YES;
                [UIView animateWithDuration:speed delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    imageView.transform = CGAffineTransformMakeScale(0.75, 0.75);
                }completion:^(BOOL finished) {
                    [UIView animateWithDuration:speed * 1.618 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                        imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                        standardCell.contentView.layer.borderWidth = 4.0f;
                        imageView.layer.borderWidth = 4.0f;
                    }completion:^(BOOL finished) {
                    }];
                }];
            }
            
            CABasicAnimation *scaleAnimation;
            scaleAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
            scaleAnimation.duration = speed;
            scaleAnimation.fromValue = [NSNumber numberWithFloat:0];
            scaleAnimation.toValue = [NSNumber numberWithFloat:4];
            [imageView.layer addAnimation:scaleAnimation forKey:@"animateBorder"];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [imageView removeFromSuperview];
                standardCell.contentView.alpha = 1.0;
                self.isAnimating = NO;
            });
        } else {
            standardCell.contentView.layer.borderWidth = 4.0f;
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.question.selectedIndexes.count == self.question.limit && ![self.question.selectedIndexes containsObject:indexPath]) {
        NSIndexPath *lastSelectedIndex = [self.question.selectedIndexes lastObject];
        [self.question toggleSelectedIndex:lastSelectedIndex];
    }
    
    [self.question toggleSelectedIndex:indexPath];
    
    self.selectedItemIndexPath = indexPath;
    
    [self.collectionView reloadData];
}

#pragma mark - Helper methods

- (CGFloat)heightOfQuestionText
{
    //Constraints
    CGSize constraintForHeaderWidth = CGSizeMake(self.collectionView.bounds.size.width - 20, MAXFLOAT);
    
    CGSize questionSize = [self.question.questionText sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToSize:constraintForHeaderWidth lineBreakMode:NSLineBreakByWordWrapping];
    CGSize hintSize = [self.question.hintText sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] constrainedToSize:constraintForHeaderWidth lineBreakMode:NSLineBreakByWordWrapping];
    
    return questionSize.height + hintSize.height + 20;
}

@end
