//
//  CoreDataStack.h
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-15.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataStack : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

- (id)initWithStoreURL:(NSURL *)storeURL modelURL:(NSURL *)modelURL;

@end
