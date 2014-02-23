//
//  TodoViewController.m
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-13.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "UIColor+Crayola.h"

#import "TodoViewController.h"
#import "FetchedResultsControllerDataSource.h"
#import "ReorderableCellController.h"
#import "TodoTableViewCell.h"
#import "TodoTableHeaderView.h"
#import "Todo.h"
#import "Store.h"

static NSInteger const NavigationBarHeight = 64;
static NSString* const selectTodoSegue = @"selectTodo";

@interface TodoViewController ()

@property (strong, nonatomic) FetchedResultsControllerDataSource *fetchedResultsControllerDataSource;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) DraggableCellController *draggableCellController;
@property (strong, nonatomic) ReorderableCellController *reorderableCellController;
@property (strong, nonatomic) TodoTableViewCell *selectedCell;
@property (strong, nonatomic) NSArray *cellShadows;

@end

@implementation TodoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpFetchResultsControllerDataSource];
    
    self.reorderableCellController = [[ReorderableCellController alloc] initWithTableView:self.tableView];
    
    self.draggableCellController = [[DraggableCellController alloc] initWithTableView:self.tableView draggableViewKeyPath:@"titlePane"];
    self.draggableCellController.delegate = self;
    
    self.tableView.tableHeaderView.bounds = CGRectMake(0, 0, self.tableView.tableHeaderView.bounds.size.width, self.tableView.rowHeight);
    [[(TodoTableHeaderView *)self.tableView.tableHeaderView fold] setBackgroundColor:self.baseColor];
    self.tableView.contentInset = UIEdgeInsetsMake(-self.tableView.rowHeight, 0, 0, 0);
    
    self.title = self.parent.title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.fetchedResultsControllerDataSource.paused = YES;
    [self unsubcribeFromAllNotifications];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.fetchedResultsControllerDataSource.paused = NO;
    [self subscribeForKeyboardNotications];
}

- (void)subscribeForKeyboardNotications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unsubcribeFromAllNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setUpFetchResultsControllerDataSource
{
    NSManagedObjectContext *context = self.parent.managedObjectContext;
    NSManagedObjectModel *model = self.parent.managedObjectContext.persistentStoreCoordinator.managedObjectModel;
        
    NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"TodoList"
                                                     substitutionVariables:@{ @"parent": self.parent }];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"completed" ascending:YES],
                                     [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    self.fetchedResultsControllerDataSource = [[FetchedResultsControllerDataSource alloc] initWithTableView:self.tableView];
    self.fetchedResultsControllerDataSource.delegate = self;
    self.fetchedResultsControllerDataSource.fetchedResultsController = self.fetchedResultsController;
}

- (BOOL)isRootList
{
    return self.parent.parent == nil;
}

- (UIColor *)baseColor
{
    if (self.isRootList) {
        return [UIColor crayola_Denim_Color];
    } else {
        return [UIColor crayola_SunsetOrange_Color];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:selectTodoSegue]) {
        return self.isRootList; // Only allow one level of meta lists
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:selectTodoSegue]) {
        [self presentSubTodoViewController:segue.destinationViewController];
    }
}

- (void)presentSubTodoViewController:(TodoViewController *)subTodoViewController
{
    Todo *todo = [self.fetchedResultsControllerDataSource selectedItem];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    subTodoViewController.parent = todo;
}

#pragma mark - Delete / Complete / Edit Todos

- (void)createTodo
{
    self.fetchedResultsControllerDataSource.reloadTableOnChanges = YES;
    [Todo insertTodoWithTitle:@"" parent:self.parent inMangedObjectContext:self.parent.managedObjectContext];
    [self performSelector:@selector(editTodoAtIndexPath:) withObject:[NSIndexPath indexPathForRow:0 inSection:0] afterDelay:0];
}

- (void)completeTodoAtIndexPath:(NSIndexPath *)indexPath
{
    Todo *todo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    todo.completed = @(YES);
}

- (void)uncompleteTodoAtIndexPath:(NSIndexPath *)indexPath
{
    Todo *todo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    todo.completed = @(NO);
}

- (void)deleteTodoAtIndexPath:(NSIndexPath *)indexPath
{
    Todo *todo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [todo.managedObjectContext deleteObject:todo];
}

- (void)editTodoAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCell = (TodoTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    self.selectedCell.titleTextField.delegate = self;
    self.selectedCell.titleTextField.userInteractionEnabled = YES;
    self.tableView.scrollEnabled = NO;
    self.tableView.allowsSelection = NO;
    self.cancelEditingGestureRecognizer.enabled = YES;
    
    [self fadeOutNotSelectedCells];
    [self.selectedCell.titleTextField becomeFirstResponder];
}

- (void)stopEditingTodo:(id)sender
{
    self.tableView.scrollEnabled = YES;
    self.tableView.allowsSelection = YES;
    self.selectedCell.titleTextField.userInteractionEnabled = NO;
    [self.selectedCell.titleTextField resignFirstResponder];
    self.cancelEditingGestureRecognizer.enabled = NO;
    
    [self fadeInNotSelectedCells];
}

#pragma mark - UITableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isRootList) {
        [self editTodoAtIndexPath:indexPath];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UIScrollView delegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    TodoTableHeaderView *todoTableHeaderView = (TodoTableHeaderView *)self.tableView.tableHeaderView;
    
    if (scrollView.contentOffset.y > -NavigationBarHeight) {
        todoTableHeaderView.title.text = @"Pull to Create Item";
    } else {
        todoTableHeaderView.title.text = @"Release to Create Item";
    }
    
    CGFloat tableHeaderBottom = scrollView.contentOffset.y - self.tableView.tableHeaderView.frame.size.height;
    CGFloat visibleHeaderHeight = -(NavigationBarHeight + tableHeaderBottom);
    
    [todoTableHeaderView mountainFoldWithResultingHeight:visibleHeaderHeight];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.tableView.tableHeaderView.hidden = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -NavigationBarHeight) {
        [self createTodo];
    }
}

#pragma mark - DraggableCellController delegate methods

- (void)draggableCellControllerDidDragCell:(TodoTableViewCell *)cell offset:(CGFloat)offset triggered:(BOOL)triggered
{
    [UIView animateWithDuration:0.25 animations:^{
        
        if (triggered && offset > 0) {
            cell.state = TodoCellStateComplete;
        } else if (triggered && offset < 0) {
            cell.state = TodoCellStateDeleted;
        } else {
            Todo *todo = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
            
            if (todo.completed.boolValue) {
                cell.state = TodoCellStateCompleted;
            } else {
                cell.state = TodoCellStateNormal;
            }
        }
    }];
}

- (void)draggableCellControllerDidReleaseCell:(TodoTableViewCell *)cell offset:(CGFloat)offset triggered:(BOOL)triggered
{
    if (triggered && offset < 0) {
        [UIView animateWithDuration:0.3 animations:^{
            cell.titlePane.frame = CGRectMake(-cell.titlePane.frame.size.width, 0, cell.titlePane.frame.size.width, cell.titlePane.frame.size.height);
        } completion:^(BOOL finished) {
            [self deleteTodoAtIndexPath:[self.tableView indexPathForCell:cell]];
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            cell.titlePane.frame = CGRectMake(0, 0, cell.titlePane.frame.size.width, cell.titlePane.frame.size.height);
        } completion:^(BOOL finished) {
            if (triggered && offset > 0) {
                Todo *todo = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:cell]];
                
                if (todo.completed.boolValue) {
                    [self uncompleteTodoAtIndexPath:[self.tableView indexPathForCell:cell]];
                } else {
                    [self completeTodoAtIndexPath:[self.tableView indexPathForCell:cell]];
                }
            }
        }];
    }
}

#pragma mark - FetchedResultsControllerDataSource delegate methods

- (void)configureCell:(TodoTableViewCell *)cell withObject:(Todo *)todo
{
    cell.baseColor = self.baseColor;
    cell.titleTextField.text = todo.title;
    
    if ([todo.completed boolValue]) {
        cell.state = TodoCellStateCompleted;
    } else {
        cell.state = TodoCellStateNormal;
    }
}

- (void)fetchedResultsControllerDataSourceDidReloadTable
{
    self.tableView.tableHeaderView.hidden = YES;
    self.fetchedResultsControllerDataSource.reloadTableOnChanges = NO;
}

- (void)exhangeObject:(id)object withAnotherObject:(id)anotherObject
{
    [Todo exchangeTodo:object withSibling:anotherObject];
}

#pragma mark - UITextField delegate methods

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self.selectedCell];
    Todo *todo = [self.fetchedResultsControllerDataSource.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (self.selectedCell.titleTextField.text.length > 0) {
        todo.title = self.selectedCell.titleTextField.text;
    } else {
        [self deleteTodoAtIndexPath:indexPath];
    }
    
    self.selectedCell.titleTextField.delegate = nil;
    self.selectedCell = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self stopEditingTodo:nil];
    return YES;
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^(void) {
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0, 0, 0);
         self.tableView.contentInset = contentInsets;
         self.tableView.scrollIndicatorInsets = contentInsets;
     }];
}

#pragma mark - Fade in / out cells

- (void)fadeOutNotSelectedCells
{
    NSMutableArray *cellShadows = [NSMutableArray array];
    
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if (cell == self.selectedCell) continue;
        
        UIView *shadow = [[UIView alloc] initWithFrame:cell.bounds];
        shadow.backgroundColor = [UIColor blackColor];
        [cell addSubview:shadow];
        shadow.alpha = 0.0;
        [cellShadows addObject:shadow];
    }
    
    self.cellShadows = [cellShadows copy];
    
    [UIView animateWithDuration:0.3 animations:^{
        for (UIView *shadow in cellShadows) {
            shadow.alpha = 0.5;
        }
    }];
}

- (void)fadeInNotSelectedCells
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.cellShadows makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];
}

@end
