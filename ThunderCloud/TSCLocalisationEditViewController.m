//
//  TSCLocalisationEditViewController.m
//  ThunderCloud
//
//  Created by Simon Mitchell on 17/09/2014.
//  Copyright (c) 2014 threesidedcube. All rights reserved.
//

#import "TSCLocalisationEditViewController.h"
#import "TSCLocalisationKeyValue.h"
#import "TSCLocalisationController.h"

@interface TSCLocalisationEditViewController ()

@property (nonatomic, assign) BOOL isNewLocalisation;

@end

@implementation TSCLocalisationEditViewController

- (instancetype)initWithLocalisation:(TSCLocalisation *)localisation
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        self.localisation = localisation;
    }
    return self;
}

- (instancetype)initWithLocalisationKey:(NSString *)localisationKey
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        self.localisation = [[TSCLocalisation alloc] initWithAvailableLanguages:[[TSCLocalisationController sharedController] availableLanguages]];
        self.localisation.localisationKey = localisationKey;
        self.isNewLocalisation = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(handleSave:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(handleCancel:)];
    [self reload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)reload
{
    
    NSMutableArray *localisationsArray = [NSMutableArray array];
    
    for (TSCLocalisationKeyValue *localisationValue in self.localisation.localisationValues) {
        
        TSCTableInputTextFieldRow *localisationValueRow = [TSCTableInputTextFieldRow rowWithTitle:[[TSCLocalisationController sharedController] localisedLanguageNameForLanguageKey:localisationValue.languageCode] placeholder:localisationValue.languageCode inputId:localisationValue.languageCode required:YES];
        localisationValueRow.value = localisationValue.localisedString;
        [localisationsArray addObject:localisationValueRow];
    }
    
    TSCTableSection *localisationsSection = [TSCTableSection sectionWithTitle:self.localisation.localisationKey footer:self.isNewLocalisation ? @"This string is not currently in the CMS, saving it will add it." : nil items:localisationsArray target:nil selector:nil];
    
    self.dataSource = @[localisationsSection];
    
}

- (void)handleSave:(id)sender
{
    
    for (NSString *key in self.inputDictionary.allKeys) {
        
        [self.localisation setLocalisedString:self.inputDictionary[key] forLanguageCode:key];
        [[TSCLocalisationController sharedController] registerLocalisationEdited:self.localisation];
    }
    
    TSCTableInputViewCell *cell = (TSCTableInputViewCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [cell setEditing:NO animated:YES];
    [self dismissViewControllerAnimated:true completion:nil];
    [self.delegate editingSavedInViewController:self];
}

- (void)handleCancel:(id)sender
{
    TSCTableInputViewCell *cell = (TSCTableInputViewCell *)[self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
    [cell setEditing:NO animated:YES];
    [self dismissViewControllerAnimated:true completion:nil];
    [self.delegate editingCancelledInViewController:self];
}

@end
