//
//  TSCPokemonListItemView.m
//  ThunderStorm
//
//  Created by Andrew Hart on 15/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCPokemonListItemView.h"
#import "TSCLink.h"
#import "UINavigationController+TSCNavigationController.h"
#import "NSString+LocalisedString.h"

@import ThunderBasics;

@interface TSCPokemonListItemView () <UIAlertViewDelegate>

@property (nonatomic, strong) TSCPokemonListItem *selectedItem;

@end

@implementation TSCPokemonListItemView

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        self.items = [TSCPokemonListItemView pokemonItems];
    }
    
    return self;
}

- (NSString *)rowTitle
{
    return @"This was a triumph";
}

- (NSString *)rowSubtitle
{
    return @"";
}

- (SEL)rowSelectionSelector
{
    return NSSelectorFromString(@"handleSelection:");
}

- (id)rowSelectionTarget
{
    return self.parentObject;
}

- (TSCLink *)rowLink
{
    return self.link;
}

- (BOOL)shouldDisplaySelectionIndicator
{
    return NO;
}

- (BOOL)shouldDisplaySelectionCell
{
    return NO;
}

- (Class)tableViewCellClass
{
    return [TSCPokemonTableViewCell class];
}

- (TSCPokemonTableViewCell *)tableViewCell:(TSCPokemonTableViewCell *)cell
{
    cell.items = self.items;
    cell.delegate = self;
    
    cell.detailTextLabel.text = @"";
    cell.textLabel.text = @"";
    
    return cell;
}

- (CGFloat)tableViewCellHeightConstrainedToSize:(CGSize)contrainedSize
{
    return [TSCPokemonTableViewCell heightForNumberOfItems:[TSCPokemonListItemView pokemonItems].count withWidth:[UIScreen mainScreen].bounds.size.width];;
}

+ (BOOL)itemIsInstalledWithURL:(NSURL *)url
{
    return [[UIApplication sharedApplication] canOpenURL:url];
}

+ (NSArray *)pokemonItems
{
    NSString *currentAppURLScheme = [[NSBundle mainBundle] infoDictionary][@"CFBundleURLTypes"][0][@"CFBundleURLSchemes"][0];
    
    currentAppURLScheme = [currentAppURLScheme stringByAppendingString:@"://"];
    
    NSMutableArray *array = [NSMutableArray new];
    
    TSCPokemonListItem *pfa = [[TSCPokemonListItem alloc] init];
    pfa.localLink = [NSURL URLWithString:@"ARCPFA://"];
    pfa.name = @"Pet";
    pfa.image = [UIImage imageNamed:@"pet_first_aid_icon.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    pfa.appStoreLink = [NSURL URLWithString:@"itunes://669579655"];
    pfa.isInstalled = [TSCPokemonListItemView itemIsInstalledWithURL:pfa.localLink];
    [array addObject:pfa];
    
    TSCPokemonListItem *trc = [[TSCPokemonListItem alloc] init];
    trc.localLink = [NSURL URLWithString:@"ARCTRC://"];
    trc.name = @"Team";
    trc.image = [UIImage imageNamed:@"team_red_cross_icon.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    trc.appStoreLink = [NSURL URLWithString:@"itunes://669579655"];
    trc.isInstalled = [TSCPokemonListItemView itemIsInstalledWithURL:trc.localLink];
    [array addObject:trc];
    
    TSCPokemonListItem *fa = [[TSCPokemonListItem alloc] init];
    fa.localLink = [NSURL URLWithString:@"ARCFA://"];
    fa.name = @"First Aid";
    fa.image = [UIImage imageNamed:@"first_aid_icon.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    fa.appStoreLink = [NSURL URLWithString:@"itunes://529160691"];
    fa.isInstalled = [TSCPokemonListItemView itemIsInstalledWithURL:fa.localLink];
    [array addObject:fa];
    
    TSCPokemonListItem *swim = [[TSCPokemonListItem alloc] init];
    swim.localLink = [NSURL URLWithString:@"ARCWSWIM://"];
    swim.name = @"Swim";
    swim.image = [UIImage imageNamed:@"swim_icon.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    swim.appStoreLink = [NSURL URLWithString:@"itunes://785356681"];
    swim.isInstalled = [TSCPokemonListItemView itemIsInstalledWithURL:swim.localLink];
    [array addObject:swim];
    
    TSCPokemonListItem *tornado = [[TSCPokemonListItem alloc] init];
    tornado.localLink = [NSURL URLWithString:@"ARCTOR://"];
    tornado.name = @"Tornado";
    tornado.image = [UIImage imageNamed:@"tornado_icon.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    tornado.appStoreLink = [NSURL URLWithString:@"itunes://602724318"];
    tornado.isInstalled = [TSCPokemonListItemView itemIsInstalledWithURL:tornado.localLink];
    [array addObject:tornado];
    
    TSCPokemonListItem *hurricane = [[TSCPokemonListItem alloc] init];
    hurricane.localLink = [NSURL URLWithString:@"ARCHUR://"];
    hurricane.name = @"Hurricane";
    hurricane.image = [UIImage imageNamed:@"hurricane_icon.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    hurricane.appStoreLink = [NSURL URLWithString:@"itunes://545689128"];
    hurricane.isInstalled = [TSCPokemonListItemView itemIsInstalledWithURL:hurricane.localLink];
    [array addObject:hurricane];
    
    TSCPokemonListItem *earthquake = [[TSCPokemonListItem alloc] init];
    earthquake.localLink = [NSURL URLWithString:@"ARCHEQ://"];
    earthquake.name = @"Earthquake";
    earthquake.image = [UIImage imageNamed:@"earthquake_icon.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    earthquake.appStoreLink = [NSURL URLWithString:@"itunes://557946227"];
    earthquake.isInstalled = [TSCPokemonListItemView itemIsInstalledWithURL:earthquake.localLink];
    [array addObject:earthquake];
    
    TSCPokemonListItem *wildfire = [[TSCPokemonListItem alloc] init];
    wildfire.localLink = [NSURL URLWithString:@"ARCWIL://"];
    wildfire.name = @"Wildfire";
    wildfire.image = [UIImage imageNamed:@"wildfire_icon.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
    wildfire.appStoreLink = [NSURL URLWithString:@"itunes://566584692"];
    wildfire.isInstalled = [TSCPokemonListItemView itemIsInstalledWithURL:wildfire.localLink];
    [array addObject:wildfire];
    
    NSMutableArray *itemsArray = [NSMutableArray new];
    
    for (TSCPokemonListItem *item in array) {
        if (![item.localLink.absoluteString isEqualToString:currentAppURLScheme]) {
            [itemsArray addObject:item];
        }
    }
    
    return itemsArray;
}

#pragma mark - TSCPokemonTableViewCellDelegate methods

- (void)tableViewCell:(TSCPokemonTableViewCell *)cell didTapItemAtIndex:(NSInteger)index
{
    TSCPokemonListItem *item = [self.items objectAtIndex:index];
    
    if (item.isInstalled) {
        
        self.selectedItem = item;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Switching Apps" message:@"We are now switching apps" delegate:self cancelButtonTitle:[NSString stringWithLocalisationKey:@"_BUTTON_CANCEL" fallbackString:@"Cancel"]otherButtonTitles:@"OK", nil];
        [alertView show];
    } else {
        TSCLink *link = [[TSCLink alloc] init];
        link.url = item.appStoreLink;
        
        self.link = link;
        
        if ([self.parentObject respondsToSelector:NSSelectorFromString(@"handleSelection:")]) {
            [self.parentNavigationController pushLink:self.link];
        }
    }
}

#pragma mark - UIAlertViewDelegate methods


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSCStatEventNotification" object:self userInfo:@{@"type":@"event", @"category":@"Collect Them All", @"action":self.selectedItem.name}];

        [[UIApplication sharedApplication] openURL:self.selectedItem.localLink];
    }
}

@end
