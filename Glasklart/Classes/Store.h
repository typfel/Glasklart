//
//  Store.h
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-15.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Todo;
@class NSManagedObjectContext;

@interface Store : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, nonatomic) Todo *rootTodo;

@end
