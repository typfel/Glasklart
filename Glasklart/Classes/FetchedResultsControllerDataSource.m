//
//  FetchedResultsControllerDataSource.m
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-18.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import "FetchedResultsControllerDataSource.h"

@interface FetchedResultsControllerDataSource ()

@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) CGPoint contentOffsetBeforeInsert;
@property (assign, nonatomic) BOOL changeIsUserDriven;

@end

@implementation FetchedResultsControllerDataSource

- (id)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    
    if (self) {
        _tableView = tableView;
        _tableView.dataSource = self;
    }
    
    return self;
}

- (void)setFetchedResultsController:(NSFetchedResultsController*)fetchedResultsController
{
    NSAssert(_fetchedResultsController == nil, @"TODO: you can currently only assign this property once");
    _fetchedResultsController = fetchedResultsController;
    fetchedResultsController.delegate = self;
    [fetchedResultsController performFetch:NULL];
}

- (id)selectedItem
{
    NSIndexPath *path = self.tableView.indexPathForSelectedRow;
    return path ? [self.fetchedResultsController objectAtIndexPath:path] : nil;
}

- (void)setPaused:(BOOL)paused
{
    _paused = paused;
    if (paused) {
        self.fetchedResultsController.delegate = nil;
    } else {
        self.fetchedResultsController.delegate = self;
        [self.fetchedResultsController performFetch:NULL];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource delegate methods

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    self.changeIsUserDriven = YES;
    
    id object = [self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
    id anotherObject = [self.fetchedResultsController objectAtIndexPath:destinationIndexPath];
    
    [self.delegate exhangeObject:object withAnotherObject:anotherObject];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TodoCell"];
    [self.delegate configureCell:cell withObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    
    return cell;
}

#pragma mark - NSFetchedResultsController delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (self.reloadTableOnChanges) {
        self.contentOffsetBeforeInsert = self.tableView.contentOffset;
    } else {
        [self.tableView beginUpdates];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (self.reloadTableOnChanges) {
        [self.tableView reloadData];
        self.tableView.contentOffset = CGPointMake(self.contentOffsetBeforeInsert.x, self.contentOffsetBeforeInsert.y + self.tableView.rowHeight);
        [self.delegate fetchedResultsControllerDataSourceDidReloadTable];
    } else {
        self.changeIsUserDriven = NO;
        [self.tableView endUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.changeIsUserDriven) return;
    if (self.reloadTableOnChanges) return;
    
    UITableView *tableView = self.tableView;

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self.delegate configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
                              withObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            break;

        case NSFetchedResultsChangeMove:
            [self.delegate configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
                              withObject:[self.fetchedResultsController objectAtIndexPath:newIndexPath]];
            
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

@end
