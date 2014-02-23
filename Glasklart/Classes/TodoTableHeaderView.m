//
//  TodoTableHeaderView.m
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-20.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import "TodoTableHeaderView.h"

@implementation TodoTableHeaderView

- (void)mountainFoldWithResultingHeight:(CGFloat)height
{
    CGFloat fraction = height / self.frame.size.height;
    fraction = MIN(MAX(0, fraction), 1);
    CGFloat angle = acos(fraction);
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -500;
    transform = CATransform3DRotate(transform, angle, 1.0f, 0.0f, 0.0f);
    
    self.fold.layer.anchorPoint = CGPointMake(0.5, 1.0);
    self.fold.layer.position = CGPointMake(self.fold.layer.position.x, self.fold.layer.bounds.size.height);
    self.fold.layer.transform = transform;
    
    self.shadow.alpha = 1 - (0.3 + 0.7 * fraction);
}

@end
