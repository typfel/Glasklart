//
//  ReorderableCellController.h
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-20.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReorderableCellController : NSObject <UIGestureRecognizerDelegate>

- (id)initWithTableView:(UITableView *)tableView;

@end
