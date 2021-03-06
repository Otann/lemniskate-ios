//
//  ViewController.m
//  Lemniskate
//
//  Created by Chebotaev Anton on 20/11/14.
//  Copyright (c) 2014 MenadCompany. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ACAllCollectionsViewController.h"
#import "ACAddCollectionViewController.h"
#import "ACSingleCollectionViewController.h"
#import "ACTextFieldTableViewCell.h"
#import "ACCollectionTableViewCell.h"
#import "ACAppDelegate.h"
#import "LemniCollection.h"
#import "MDCControlConstants.h"

@interface ACAllCollectionsViewController ()
@property (nonatomic, strong) NSFetchedResultsController *dataController;
@end

@implementation ACAllCollectionsViewController

#pragma mark - Getters

- (NSFetchedResultsController *)dataController
{
    if (!_dataController) {
        ACAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LemniCollection"];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
        _dataController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                              managedObjectContext:delegate.managedObjectContext
                                                                sectionNameKeyPath:nil
                                                                         cacheName:nil];
        
        [_dataController setDelegate:self];
        
        // Perform Fetch
        NSError *error = nil;
        [_dataController performFetch:&error];
        
        if (error) {
            NSLog(@"Unable to perform fetch.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
    }
    
    return _dataController;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        CGRect sb = [self.view frame];
        CGRect frame = CGRectMake(sb.origin.x, sb.origin.y, sb.size.width, sb.size.height - MDCMagicalTableOffset);
        
        _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        _tableView.rowHeight = MDCCollectionViewHeight;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor blackColor];
    }
    return _tableView;
}

- (NSString *)title
{
    return @"Collections";
}

#pragma mark - UIViewController

- (void)loadView
{
    [super loadView];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-icon"]];
    self.navigationItem.titleView = logo;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                          target:self
                                                                                          action:@selector(editBarButtonItemTap:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addBarButtonItemTap:)];

    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self.tableView reloadData];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.dataController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[self.dataController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.dataController sections][section];
        return [sectionInfo numberOfObjects];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LemniCollection *collection = (LemniCollection *)[self.dataController objectAtIndexPath:indexPath];

    UITableViewCell *cell = [ACCollectionTableViewCell cellWithCollection:collection];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}



#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            if ([self.tableView numberOfSections]) {
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
    LemniCollection *collection = (LemniCollection *)[self.dataController objectAtIndexPath:indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self navigateToCollection:collection];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    LemniCollection *collection = (LemniCollection *)[self.dataController objectAtIndexPath:indexPath];
    [self navigateToCollection:collection];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *managedObject = [self.dataController objectAtIndexPath:indexPath];
        ACAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.managedObjectContext deleteObject:managedObject];
        [delegate.managedObjectContext save:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1; // TODO is this right? Looks like the only way to hide header
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1; // TODO is this right? Looks like the only way to hide header
}

#pragma mark - Action handlers

- (void)addBarButtonItemTap:(UIBarButtonItem *)sender
{
    ACAddCollectionViewController *viewController = [ACAddCollectionViewController new];
    viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)editBarButtonItemTap:(UIBarButtonItem *)sender
{
    [self setEditing:![self isEditing] animated:YES];
}

- (void)navigateToCollection:(LemniCollection *)collection {
    ACSingleCollectionViewController *viewController = [ACSingleCollectionViewController new];
    viewController.collection = collection;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
