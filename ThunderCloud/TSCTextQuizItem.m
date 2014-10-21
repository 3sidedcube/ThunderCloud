//
//  TSCTextSelectionQuestionViewController.m
//  ThunderStorm
//
//  Created by Matt Cheetham on 11/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCTextQuizItem.h"
#import "TSCQuizQuestion.h"
#import "TSCQuizCompletionViewController.h"

@interface TSCTextQuizItem ()

@end

@implementation TSCTextQuizItem

- (id)initWithQuestion:(TSCQuizQuestion *)question
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        self.question = question;
    }
    
    return self;
}

- (void)viewDidLoad
{
//    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    TSCTableSection *questions = [TSCTableSection sectionWithTitle:nil footer:nil items:self.question.options target:self selector:@selector(handleResponse:)];
    
    self.dataSource = @[questions];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

#pragma mark Response handling

- (void)handleResponse:(TSCTableSelection *)selection
{
    if (self.question.selectedIndexes.count == self.question.limit && ![self.question.selectedIndexes containsObject:selection.indexPath]) {
        
        NSIndexPath *lastSelectedIndex = [self.question.selectedIndexes lastObject];
        TSCTableInputCheckViewCell *lastSelectedCell = (TSCTableInputCheckViewCell *)[self.tableView cellForRowAtIndexPath:lastSelectedIndex];
        [lastSelectedCell.checkView setOn:NO animated:YES];
        [self.question toggleSelectedIndex:lastSelectedIndex];
    }
    
    TSCTableInputCheckViewCell *cell = (TSCTableInputCheckViewCell *)[self.tableView cellForRowAtIndexPath:selection.indexPath];
    [cell.checkView setOn:!cell.checkView.isOn animated:YES];
    [self.tableView deselectRowAtIndexPath:selection.indexPath animated:YES];
    
    [self.question toggleSelectedIndex:selection.indexPath];
}

#pragma mark Header handling

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //Constraints
    CGSize constraintForHeaderWidth = CGSizeMake(tableView.bounds.size.width - 20, MAXFLOAT);
    
    UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, constraintForHeaderWidth.width, 0)];
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, questionLabel.frame.size.height + 15, constraintForHeaderWidth.width, 0)];

    //Calculated question size
    CGSize questionSize = [questionLabel sizeThatFits:constraintForHeaderWidth];
    CGSize hintSize = [hintLabel sizeThatFits:constraintForHeaderWidth];

    //Question Label
    questionLabel.frame = CGRectMake(10, 10, constraintForHeaderWidth.width, questionSize.height);
    questionLabel.text = self.question.questionText;
    questionLabel.numberOfLines = 0;
    questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    questionLabel.textAlignment = NSTextAlignmentCenter;
    questionLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    questionLabel.backgroundColor = [UIColor clearColor];
    
    //Hint Label
    hintLabel.frame = CGRectMake(10, questionLabel.frame.size.height + 15, constraintForHeaderWidth.width, hintSize.height);
    hintLabel.text = self.question.hintText;
    hintLabel.numberOfLines = 0;
    hintLabel.lineBreakMode = NSLineBreakByWordWrapping;
    hintLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    hintLabel.textColor = [[TSCThemeManager sharedTheme] secondaryLabelColor];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.backgroundColor = [UIColor clearColor];
    
    //Create view to hold our labels
    UIView *questionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, questionLabel.frame.size.height + hintLabel.frame.size.height)];
    questionView.backgroundColor = [UIColor colorWithRed:247.0f / 255.0f green:247.0f / 255.0f blue:247.0f / 255.0f alpha:1.0];
    
    //Add labels to header
    [questionView addSubview:questionLabel];
    [questionView addSubview:hintLabel];

    return questionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //Constraints
    CGSize constraintForHeaderWidth = CGSizeMake(tableView.bounds.size.width - 20, MAXFLOAT);
    
    //Calculated question size
    CGSize questionSize = [self.question.questionText sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToSize:constraintForHeaderWidth lineBreakMode:NSLineBreakByWordWrapping];
    CGSize hintSize = [self.question.hintText sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] constrainedToSize:constraintForHeaderWidth lineBreakMode:NSLineBreakByWordWrapping];
    
    return questionSize.height + hintSize.height + 20;
}

@end
