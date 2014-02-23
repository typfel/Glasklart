//
//  Store.m
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-15.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "Store.h"
#import "Todo.h"

@implementation Store

- (Todo *)rootTodo
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Todo"];
    request.predicate = [NSPredicate predicateWithFormat:@"parent = %@", nil];
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:NULL];
    Todo *rootTodo = [objects lastObject];
    
    if (rootTodo == nil) {
        rootTodo = [Todo insertTodoWithTitle:@"Todo Lists" parent:nil inMangedObjectContext:self.managedObjectContext];
    }
    
    return rootTodo;
}

@end
