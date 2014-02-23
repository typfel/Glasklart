//
//  AppDelegate.m
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-13.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import "UIResponder+KeyboardCache.h"

#import "AppDelegate.h"
#import "CoreDataStack.h"
#import "TodoViewController.h"
#import "Store.h"
#import "Todo.h"

@interface AppDelegate ()

@property (strong, nonatomic) CoreDataStack *coreDataStack;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.coreDataStack = [[CoreDataStack alloc] initWithStoreURL:self.storeURL modelURL:self.modelURL];
    
    Store *store = [[Store alloc] init];
    store.managedObjectContext = self.coreDataStack.managedObjectContext;
    
    if (store.rootTodo.children.count == 0) {
        [self insertDefaultTodoList:store.rootTodo];
    }
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    TodoViewController *viewController = (TodoViewController *)navigationController.topViewController;
    viewController.parent = store.rootTodo;
    
    [UIResponder cacheKeyboard];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSError *error = nil;
    [self.coreDataStack.managedObjectContext save:&error];
    
    if (error) {
        NSLog(@"Error saving managedObjectContext: %@", error);
    }
}

- (void)insertDefaultTodoList:(Todo *)parent;
{
    [Todo insertTodoWithTitle:@"Grocery Shopping" parent:parent inMangedObjectContext:self.coreDataStack.managedObjectContext];
}

- (NSURL *)modelURL
{
    return [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
}

- (NSURL *)storeURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DataStore.sqlite"];
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
