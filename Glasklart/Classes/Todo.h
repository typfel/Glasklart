//
//  Todo.h
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-15.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Todo;
@class NSManagedObjectContext;

@interface Todo : NSManagedObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *order;
@property (nonatomic, retain) NSNumber *completed;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) Todo *parent;

+ (Todo *)insertTodoWithTitle:(NSString *)title parent:(Todo *)parent inMangedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (void)exchangeTodo:(Todo *)todo withSibling:(Todo *)sibling;

@end
