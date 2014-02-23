//
//  Todo.m
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-15.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import "Todo.h"
#import "Todo.h"


@implementation Todo

@dynamic title;
@dynamic order;
@dynamic children;
@dynamic parent;
@dynamic completed;

+ (Todo *)insertTodoWithTitle:(NSString *)title parent:(Todo *)parent inMangedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    Todo *todo = (Todo *)[NSEntityDescription insertNewObjectForEntityForName:@"Todo"
                                                       inManagedObjectContext:managedObjectContext];
    
    todo.order = @(parent.children.count);
    todo.title = title;
    todo.parent = parent;
    
    return todo;
}

- (void)setCompleted:(NSNumber *)completed
{
    [self willChangeValueForKey:@"completed"];
    [self setPrimitiveValue:completed forKey:@"completed"];
    [self didChangeValueForKey:@"completed"];
    
    for (Todo *todo in self.children) {
        todo.completed = [completed copy];
    }
}

+ (void)exchangeTodo:(Todo *)todo withSibling:(Todo *)sibling
{
    NSInteger temp = todo.order.integerValue;
    todo.order = @(sibling.order.integerValue);
    sibling.order = @(temp);
}

- (void)prepareForDeletion
{
    NSSet* siblings = self.parent.children;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"order > %@", self.order];
    NSSet* siblingsAfterSelf = [siblings filteredSetUsingPredicate:predicate];
    [siblingsAfterSelf enumerateObjectsUsingBlock:^(Todo *sibling, BOOL *stop)
     {
         sibling.order = @(sibling.order.integerValue - 1);
     }];
}

@end
