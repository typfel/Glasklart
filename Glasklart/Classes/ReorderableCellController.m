//
//  ReorderableCellController.m
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-20.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import "ReorderableCellController.h"

@interface ReorderableCellController ()

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (strong, nonatomic) NSIndexPath *initialIndexPath;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (strong, nonatomic) UITableViewCell *draggedCell;
@property (strong, nonatomic) UIView *draggedCellImposter;
@property (assign, nonatomic) CGPoint initialDraggedCellFrameOrigin;

@end

@implementation ReorderableCellController

- (id)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    
    if (self) {
        self.tableView = tableView;
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(selectCellWithGestureRecognizer:)];
        self.longPressGestureRecognizer.delegate = self;
        [self.tableView addGestureRecognizer:self.longPressGestureRecognizer];
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveCellWithGestureRecognizer:)];
        self.panGestureRecognizer.delegate = self;
        [self.tableView addGestureRecognizer:self.panGestureRecognizer];
    }
    
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return (gestureRecognizer == self.longPressGestureRecognizer || gestureRecognizer  == self.panGestureRecognizer) &&
           (otherGestureRecognizer == self.longPressGestureRecognizer || otherGestureRecognizer == self.panGestureRecognizer);
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.panGestureRecognizer) {
        return self.draggedCell != nil;
    }
    
    if (gestureRecognizer == self.longPressGestureRecognizer) {
        return self.draggedCell == nil;
    }
    
    return YES;
}

- (void)selectCellWithGestureRecognizer:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && !self.draggedCell) {
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[recognizer locationInView:self.tableView]];
        
        if (indexPath && [self.tableView.dataSource tableView:self.tableView canMoveRowAtIndexPath:indexPath]) {
            [self selectCellAtIndexPath:indexPath];
            [self replaceDraggedCellWithImposter];
            [self pickUpDraggedCell];
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded && self.panGestureRecognizer.state == UIGestureRecognizerStateFailed) {
        [self releaseDraggedCell];
    }
}

- (void)moveCellWithGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if (!self.draggedCell) return;
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self moveDraggedCellWithTranslation:[recognizer translationInView:self.tableView]];
        [self moveDraggedRowIfIndexPathHasChanged:[self.tableView indexPathForRowAtPoint:[recognizer locationInView:self.tableView]]];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self releaseDraggedCell];
    }
}

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath
{
    self.initialIndexPath = indexPath;
    self.currentIndexPath = indexPath;
    self.draggedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    self.initialDraggedCellFrameOrigin = self.draggedCell.frame.origin;
}

- (void)moveDraggedCellWithTranslation:(CGPoint)translation
{
    CGRect frame = self.draggedCellImposter.frame;
    frame.origin = CGPointMake(translation.x + self.initialDraggedCellFrameOrigin.x,
                               translation.y + self.initialDraggedCellFrameOrigin.y);
    self.draggedCellImposter.frame = frame;
}

- (void)moveDraggedRowIfIndexPathHasChanged:(NSIndexPath *)indexPathForTouch
{
    if (indexPathForTouch != nil && ![self.currentIndexPath isEqual:indexPathForTouch]) {
        [self.tableView moveRowAtIndexPath:self.currentIndexPath toIndexPath:indexPathForTouch];
        self.currentIndexPath = indexPathForTouch;
    }
}

- (void)replaceDraggedCellWithImposter
{
    self.draggedCellImposter = [self.draggedCell snapshotViewAfterScreenUpdates:NO];
    self.draggedCellImposter.frame = self.draggedCell.frame;
    [self.tableView addSubview:self.draggedCellImposter];
    self.draggedCell.hidden = YES;
}

- (void)pickUpDraggedCell
{
    [UIView beginAnimations:nil context:NULL];
    self.draggedCellImposter.transform = CGAffineTransformMakeScale(1.15, 1.15);
    self.draggedCellImposter.alpha = 0.95;
    self.draggedCellImposter.layer.shadowOpacity = 0.5;
    self.draggedCellImposter.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
}

- (void)releaseDraggedCell
{
    [UIView animateWithDuration:0.3 animations:^{
        self.draggedCellImposter.transform = CGAffineTransformIdentity;
        self.draggedCellImposter.frame = self.draggedCell.frame;
        self.draggedCellImposter.alpha = 1;
        self.draggedCellImposter.layer.shadowOpacity = 0.0;
    } completion:^(BOOL finished) {
        [self.draggedCellImposter removeFromSuperview];
        self.draggedCell.hidden = NO;
        self.draggedCell = nil;
        
        [self.tableView.dataSource tableView:self.tableView moveRowAtIndexPath:self.initialIndexPath toIndexPath:self.currentIndexPath];
    }];
}

@end
