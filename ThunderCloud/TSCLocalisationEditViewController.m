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
#import "TSCEditLocalisationRow.h"
#import "UIColor-Expanded.h"

@interface TSCLocalisationEditViewController ()

@property (nonatomic, assign) BOOL isNewLocalisation;

@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *cancelButton;

@end

@implementation TSCLocalisationEditViewController

- (void)dealloc
{
    TSCTableSection *section = self.dataSource[0];
    for (TSCEditLocalisationRow *row in section.sectionItems) {
        [row removeObserver:self forKeyPath:@"value"];
    }
}

- (instancetype)initWithLocalisation:(TSCLocalisation *)localisation
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
        self.localisation = localisation;
        
        self.title = @"Edit";
    }
    
    return self;
}

- (instancetype)initWithLocalisationKey:(NSString *)localisationKey
{
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        
        self.localisation = [[TSCLocalisation alloc] initWithAvailableLanguages:[[TSCLocalisationController sharedController] availableLanguages]];
        self.localisation.localisationKey = localisationKey;
        self.isNewLocalisation = YES;
        
        self.title = @"Edit";
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E9F0"];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize:17]}];
    
    self.saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 53, 27)];
    [self.saveButton addTarget:self action:@selector(handleSave:) forControlEvents:UIControlEventTouchUpInside];
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    self.saveButton.layer.backgroundColor = [UIColor colorWithHexString:@"72D33B"].CGColor;
    self.saveButton.titleLabel.font = [UIFont systemFontOfSize:13];
    self.saveButton.layer.cornerRadius = 2.0;
    self.saveButton.alpha = 0.5;
    self.saveButton.userInteractionEnabled = false;
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 67, 27)];
    [self.cancelButton addTarget:self action:@selector(handleCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    self.cancelButton.layer.backgroundColor = [UIColor colorWithHexString:@"FF3B39"].CGColor;
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:13];
    self.cancelButton.layer.cornerRadius = 2.0;
    
    [self.navigationController.navigationBar addSubview:self.saveButton];
    [self.navigationController.navigationBar addSubview:self.cancelButton];
    
    [self reload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.saveButton.frame = CGRectMake(self.view.bounds.size.width - 53 - 6, 44 - 27 - 12, 53, 27);
    self.cancelButton.frame = CGRectMake(6, 44 - 27 - 12, 67, 27);
}

- (void)reload
{
    NSMutableArray *localisationsArray = [NSMutableArray array];
    
    for (TSCLocalisationKeyValue *localisationValue in self.localisation.localisationValues) {
        
        TSCEditLocalisationRow *editRow = [TSCEditLocalisationRow rowWithLocalisationKeyValue:localisationValue];
        [localisationsArray addObject:editRow];
        
        [editRow addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![self isMissingRequiredInputRows]) {
        
        self.saveButton.alpha = 1.0;
        self.saveButton.userInteractionEnabled = true;
    } else {
        
        self.saveButton.alpha = 0.5;
        self.saveButton.userInteractionEnabled = false;
    }
}

@end
