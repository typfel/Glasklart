//
//  DraggableCellController.h
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-18.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DraggableCellControllerDelegate <NSObject>

- (void)draggableCellControllerDidDragCell:(UITableViewCell *)cell offset:(CGFloat)offset triggered:(BOOL)triggered;
- (void)draggableCellControllerDidReleaseCell:(UITableViewCell *)cell offset:(CGFloat)offset triggered:(BOOL)triggered;

@end

@interface DraggableCellController : NSObject <UIDynamicAnimatorDelegate, UIGestureRecognizerDelegate>

- (id)initWithTableView:(UITableView *)tableView draggableViewKeyPath:(NSString *)draggableViewKeyPath;

@property (weak, nonatomic) id<DraggableCellControllerDelegate> delegate;

@end
