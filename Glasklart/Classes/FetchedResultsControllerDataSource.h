//
//  FetchedResultsControllerDataSource.h
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-18.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol FetchedResultsControllerDataSourceDelegate <NSObject>

- (void)configureCell:(UITableViewCell *)cell withObject:(id)object;
- (void)exhangeObject:(id)object withAnotherObject:(id)anotherObject;
- (void)fetchedResultsControllerDataSourceDidReloadTable;

@end

@interface FetchedResultsControllerDataSource : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate>

- (id)initWithTableView:(UITableView *)tableView;
- (id)selectedItem;

@property (weak, nonatomic) id<FetchedResultsControllerDataSourceDelegate> delegate;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (assign, nonatomic) BOOL reloadTableOnChanges;
@property (assign, nonatomic) BOOL paused;

@end
