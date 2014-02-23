//
//  DraggableCellController.m
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-18.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import "DraggableCellController.h"

@interface DraggableCellController ()

@property (strong, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSString *draggableViewKeyPath;
@property (strong, nonatomic) UITableViewCell *draggedCell;

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *attachmentBehavior;
@property (strong, nonatomic) UISnapBehavior *snapBehavior;

@property (assign, nonatomic) CGFloat triggerDistance;
@property (assign, nonatomic) BOOL springEnabled;

@end

@implementation DraggableCellController

- (id)initWithTableView:(UITableView *)tableView draggableViewKeyPath:(NSString *)draggableViewKeyPath
{
    self = [super init];
    
    if (self) {
        self.tableView = tableView;
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.tableView];
        self.draggableViewKeyPath = draggableViewKeyPath;
        self.triggerDistance = 80;
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragCellWithGestureRecognizer:)];
        self.panGestureRecognizer.delegate = self;
        [self.tableView addGestureRecognizer:self.panGestureRecognizer];
    }
    
    return self;
}

- (void)dragCellWithGestureRecognizer:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[recognizer locationInView:self.tableView]];
        
        if (indexPath) {
            [self beginDraggingCellAtIndexPath:indexPath];
        }
    }
    
    if (!self.draggedCell) return;
    
    CGPoint translation = [recognizer translationInView:self.tableView];
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self dragCellWithTranslation:translation];
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == recognizer.state == UIGestureRecognizerStateCancelled) {
        [self stopDraggingCellWithTranslation:translation];
    }
}

- (void)beginDraggingCellAtIndexPath:(NSIndexPath *)indexPath
{
    self.draggedCell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self attachBehaviors];
}

- (void)dragCellWithTranslation:(CGPoint)translation
{
    self.springEnabled = fabs(translation.x) > self.triggerDistance;
    self.attachmentBehavior.anchorPoint = CGPointMake(self.draggedCell.center.x + translation.x, self.attachmentBehavior.anchorPoint.y);
    [self.delegate draggableCellControllerDidDragCell:self.draggedCell offset:translation.x triggered:self.springEnabled];
}

- (void)stopDraggingCellWithTranslation:(CGPoint)translation
{
    [self.animator removeAllBehaviors];
    [self.delegate draggableCellControllerDidReleaseCell:self.draggedCell offset:translation.x triggered:self.springEnabled];
    self.draggedCell = nil;
}

- (void)attachBehaviors
{
    [self.animator removeAllBehaviors];
    
    UIView *draggableView = [self.draggedCell valueForKeyPath:self.draggableViewKeyPath];
    CGPoint center = [self.tableView convertPoint:draggableView.center fromView:draggableView.superview];
    
    UIDynamicItemBehavior *dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[draggableView]];
    [self.animator addBehavior:dynamicItemBehavior];
    dynamicItemBehavior.allowsRotation = NO;
    dynamicItemBehavior.density = 2;
    
    self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:draggableView attachedToAnchor:center];
    [self.animator addBehavior:self.attachmentBehavior];
    self.attachmentBehavior.length = 0;
}

- (void)setSpringEnabled:(BOOL)enabled
{
    if (_springEnabled == enabled) return;
    
    _springEnabled = enabled;
    
    if (enabled) {
        UIView *draggableView = [self.draggedCell valueForKeyPath:self.draggableViewKeyPath];
        
        self.snapBehavior = [[UISnapBehavior alloc] initWithItem:draggableView snapToPoint:self.attachmentBehavior.anchorPoint];
        self.snapBehavior.damping = 0.1;
        
        [self.animator addBehavior:self.snapBehavior];
        
        self.attachmentBehavior.damping = 2.0;
        self.attachmentBehavior.frequency = 3;
    } else {
        [self.animator removeBehavior:self.snapBehavior];
        
        self.attachmentBehavior.damping = 1.0;
        self.attachmentBehavior.frequency = 0.0;
    }
}

#pragma mark - UIGestureRecognizer delegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
    
    if (fabsf(translation.x) > fabsf(translation.y)) {
        return YES;
    } else {
        return NO;
    }
}

@end
