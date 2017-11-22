//
//  TSCTextSelectionQuestionViewController.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCTextQuizItem.h"
#import "TSCQuizItem.h"
#import "TSCQuizResponseTextOption.h"
#import "TSCQuizCheckableView.h"
#import "TSCCheckView.h"
#import <ThunderCloud/ThunderCloud-Swift.h>
@import ThunderBasics;

@interface TSCTextQuizItem ()

@property (nonatomic) NSInteger yAxis;
@property (nonatomic, strong) UIView *questionView;
@property (nonatomic, assign) BOOL haslayedOut;

@end

@implementation TSCTextQuizItem

- (instancetype)initWithQuestion:(TSCQuizItem *)question
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.question = question;
        self.optionViews = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [TSCThemeManager sharedManager].theme.backgroundColor;
    self.tableView.backgroundColor = [TSCThemeManager sharedManager].theme.backgroundColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!self.haslayedOut){
        
        if (self.questionView) {
            [self.questionView removeFromSuperview];
        }
        
        self.yAxis = 0;
        
        //Header view
        //Constraints
        CGSize constraintForHeaderWidth = CGSizeMake(self.tableView.bounds.size.width - 20, MAXFLOAT);
        
        UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, constraintForHeaderWidth.width, 0)];
        UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, questionLabel.frame.size.height + 15, constraintForHeaderWidth.width, 0)];
        
        questionLabel.text = self.question.questionText;
        hintLabel.text = self.question.hintText;
        
        //Question Label
        questionLabel.numberOfLines = 0;
        questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        questionLabel.textAlignment = NSTextAlignmentCenter;
        questionLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        questionLabel.backgroundColor = [UIColor whiteColor];
        
        //Hint Label
        hintLabel.backgroundColor = [UIColor whiteColor];
        hintLabel.numberOfLines = 0;
        hintLabel.lineBreakMode = NSLineBreakByWordWrapping;
        hintLabel.font = [UIFont systemFontOfSize:16];
        hintLabel.textColor = [TSCThemeManager sharedManager].theme.secondaryLabelColor;
        hintLabel.textAlignment = NSTextAlignmentCenter;
        
        //Calculated question size
        CGSize questionSize = [questionLabel sizeThatFits:constraintForHeaderWidth];
        CGSize hintSize = [hintLabel sizeThatFits:constraintForHeaderWidth];
        
        questionLabel.frame = CGRectMake(10, 10, constraintForHeaderWidth.width, questionSize.height);
        hintLabel.frame = CGRectMake(10, questionLabel.frame.size.height + 20, constraintForHeaderWidth.width, hintSize.height);
        
        //Create view to hold our labels
        UIView *questionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, questionLabel.frame.size.height + hintLabel.frame.size.height + 50)];
        questionView.backgroundColor = [UIColor whiteColor];
        
        //Add labels to header
        [questionView addSubview:questionLabel];
        [questionView addSubview:hintLabel];
        [questionView centerSubviewsVertically];
        
        self.questionView = questionView;
        [self.tableView addSubview:self.questionView];
        
        self.yAxis += questionView.frame.size.height + 34;
        
        //Questions
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        for (TSCQuizResponseTextOption *option in self.question.options) {
            
            TSCQuizCheckableView *view = [TSCQuizCheckableView new];
            
            CGSize constraintForTitle = CGSizeMake(self.tableView.bounds.size.width - 70, MAXFLOAT);
            
            CGRect calculatedTitleRect = [option.title boundingRectWithSize:constraintForTitle options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[UIFont systemFontSize]]} context:nil];
            
            if (calculatedTitleRect.size.height < 33) {
                
                calculatedTitleRect.size.height = 48;
            } else {
                calculatedTitleRect.size.height = calculatedTitleRect.size.height + 32;
            }
            
            view.frame = CGRectMake(0, self.yAxis, self.tableView.frame.size.width, calculatedTitleRect.size.height);
            view.titleLabel.text = option.title;
            view.indexPath = indexPath;
            
            if ([self.question.selectedIndexes containsObject:indexPath]) {
                [view.checkView setOn:true animated:false];
            }
            
            indexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
            
            [self.tableView addSubview:view];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleResponse:)];
            [view addGestureRecognizer:tapGesture];
            
            self.yAxis += calculatedTitleRect.size.height;
            
            [self.optionViews addObject:view];
            
        }
        
        TSCQuizCheckableView *lastCheckableView = [self.optionViews lastObject];
        
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.backgroundColor = [UIColor colorWithWhite:0.87 alpha:1.0].CGColor;
        bottomBorder.frame = CGRectMake(0, lastCheckableView.frame.size.height-1, CGRectGetWidth(lastCheckableView.frame), 1.0);
        [lastCheckableView.layer addSublayer:bottomBorder];
        
        self.haslayedOut = YES;
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    for (UIView *subview in self.view.subviews) {
        
        if ([subview isKindOfClass:[TSCQuizCheckableView class]]) {
            
            subview.frame = CGRectMake(0, subview.frame.origin.y, self.tableView.frame.size.width, subview.frame.size.height);
            
        }
    }
    
    if (self.questionView) {
        [self.questionView removeFromSuperview];
    }
    
    //    self.yAxis = 0;
    
    //Header view
    //Constraints
    CGSize constraintForHeaderWidth = CGSizeMake(self.tableView.bounds.size.width - 20, MAXFLOAT);
    
    UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, constraintForHeaderWidth.width, 0)];
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, questionLabel.frame.size.height + 15, constraintForHeaderWidth.width, 0)];
    
    questionLabel.text = self.question.questionText;
    hintLabel.text = self.question.hintText;
    
    //Question Label
    questionLabel.numberOfLines = 0;
    questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    questionLabel.textAlignment = NSTextAlignmentCenter;
    questionLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    questionLabel.backgroundColor = [UIColor whiteColor];
    
    //Hint Label
    hintLabel.backgroundColor = [UIColor whiteColor];
    hintLabel.numberOfLines = 0;
    hintLabel.lineBreakMode = NSLineBreakByWordWrapping;
    hintLabel.font = [UIFont systemFontOfSize:16];
    hintLabel.textColor = [TSCThemeManager sharedManager].theme.secondaryLabelColor;
    hintLabel.textAlignment = NSTextAlignmentCenter;
    
    //Calculated question size
    CGSize questionSize = [questionLabel sizeThatFits:constraintForHeaderWidth];
    CGSize hintSize = [hintLabel sizeThatFits:constraintForHeaderWidth];
    
    questionLabel.frame = CGRectMake(10, 10, constraintForHeaderWidth.width, questionSize.height);
    hintLabel.frame = CGRectMake(10, questionLabel.frame.size.height + 20, constraintForHeaderWidth.width, hintSize.height);
    
    //Create view to hold our labels
    UIView *questionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, questionLabel.frame.size.height + hintLabel.frame.size.height + 50)];
    questionView.backgroundColor = [UIColor whiteColor];
    
    //Add labels to header
    [questionView addSubview:questionLabel];
    [questionView addSubview:hintLabel];
    [questionView centerSubviewsVertically];
    
    self.questionView = questionView;
    [self.tableView addSubview:self.questionView];
    
    self.tableView.contentSize = CGSizeMake(self.tableView.frame.size.width, self.yAxis);
    
    
}

#pragma mark Response handling

- (void)handleResponse:(UITapGestureRecognizer *)gesture
{
    TSCQuizCheckableView *selection = (TSCQuizCheckableView *)gesture.view;
    if (self.question.selectedIndexes.count == self.question.limit && ![self.question.selectedIndexes containsObject:selection.indexPath]) {
        
        NSIndexPath *lastSelectedIndex = [self.question.selectedIndexes lastObject];
        TSCQuizCheckableView *lastSelectedView = self.optionViews[lastSelectedIndex.row];
        [lastSelectedView.checkView setOn:NO animated:YES];
        [self.question toggleSelectedIndex:lastSelectedIndex];
    }
    
    TSCQuizCheckableView *checkableView = self.optionViews[selection.indexPath.row];
    [checkableView.checkView setOn:!checkableView.checkView.isOn animated:YES];
    
    [self.question toggleSelectedIndex:selection.indexPath];
}

#pragma mark Header handling

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //Constraints
    CGSize constraintForHeaderWidth = CGSizeMake(tableView.bounds.size.width - 20, MAXFLOAT);
    
    UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, constraintForHeaderWidth.width, 0)];
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, questionLabel.frame.size.height + 15, constraintForHeaderWidth.width, 0)];
    
    questionLabel.text = self.question.questionText;
    hintLabel.text = self.question.hintText;
    
    //Question Label
    questionLabel.numberOfLines = 0;
    questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    questionLabel.textAlignment = NSTextAlignmentCenter;
    questionLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    questionLabel.backgroundColor = [UIColor whiteColor];
    
    //Hint Label
    hintLabel.backgroundColor = [UIColor whiteColor];
    hintLabel.numberOfLines = 0;
    hintLabel.lineBreakMode = NSLineBreakByWordWrapping;
    hintLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    hintLabel.textColor = [TSCThemeManager sharedManager].theme.secondaryLabelColor;
    hintLabel.textAlignment = NSTextAlignmentCenter;
    
    //Calculated question size
    CGSize questionSize = [questionLabel sizeThatFits:constraintForHeaderWidth];
    CGSize hintSize = [hintLabel sizeThatFits:constraintForHeaderWidth];
    
    questionLabel.frame = CGRectMake(10, 10, constraintForHeaderWidth.width, questionSize.height);
    hintLabel.frame = CGRectMake(10, questionLabel.frame.size.height + 15, constraintForHeaderWidth.width, hintSize.height);
    
    //Create view to hold our labels
    UIView *questionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, questionLabel.frame.size.height + hintLabel.frame.size.height)];
    questionView.backgroundColor = [UIColor whiteColor];
    
    //Add labels to header
    [questionView addSubview:questionLabel];
    [questionView addSubview:hintLabel];
    
    return questionView;
}

- (CGFloat)heightForHeader
{
    // Constraints
    CGSize constraintForHeaderWidth = CGSizeMake(self.tableView.bounds.size.width - 20, MAXFLOAT);
    
    // Calculated question size
    CGRect questionRect = [self.question.questionText boundingRectWithSize:constraintForHeaderWidth options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0f]} context:nil];
    CGRect hintRect = [self.question.hintText boundingRectWithSize:constraintForHeaderWidth options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[UIFont systemFontSize]]} context:nil];
    
    return questionRect.size.height + hintRect.size.height + 20;
}

@end
