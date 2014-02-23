//
//  TodoViewController.h
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-13.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "FetchedResultsControllerDataSource.h"
#import "DraggableCellController.h"

@class Todo;

@interface TodoViewController : UIViewController <UITableViewDelegate, UITextFieldDelegate, DraggableCellControllerDelegate, FetchedResultsControllerDataSourceDelegate>

@property (nonatomic, strong) IBOutlet UIGestureRecognizer *cancelEditingGestureRecognizer;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) Todo *parent;

- (IBAction)stopEditingTodo:(id)sender;

@end
