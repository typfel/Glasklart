//
//  TodoTableViewCell.h
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-15.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TodoCellState) {
    TodoCellStateNormal,
    TodoCellStateDeleted,
    TodoCellStateComplete,
    TodoCellStateCompleted,
};

@interface TodoTableViewCell : UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *titlePane;
@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UILabel *deleteLabel;
@property (strong, nonatomic) IBOutlet UILabel *completeLabel;
@property (assign, nonatomic) TodoCellState state;
@property (strong, nonatomic) UIColor *baseColor;

@end
