//
//  TodoTableHeaderView.h
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-20.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodoTableHeaderView : UIView

@property (strong, nonatomic) IBOutlet UIView *fold;
@property (strong, nonatomic) IBOutlet UIView *shadow;
@property (strong, nonatomic) IBOutlet UILabel *title;

- (void)mountainFoldWithResultingHeight:(CGFloat)height;

@end
