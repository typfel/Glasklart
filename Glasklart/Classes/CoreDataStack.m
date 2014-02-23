//
//  CoreDataStack.m
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-15.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "CoreDataStack.h"

@interface CoreDataStack ()

@property (strong, nonatomic, readwrite) NSManagedObjectContext *managedObjectContext;

@property (copy, nonatomic) NSURL *storeURL;
@property (copy, nonatomic) NSURL *modelURL;

@end

@implementation CoreDataStack

- (id)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL
{
    self = [super init];
    
    if (self) {
        self.storeURL = storeURL;
        self.modelURL = modelURL;
        
        [self setUpCoreDataStack];
    }
    
    return self;
}

- (void)setUpCoreDataStack
{    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSError *error = nil;
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:self.storeURL
                                                        options:nil
                                                          error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
