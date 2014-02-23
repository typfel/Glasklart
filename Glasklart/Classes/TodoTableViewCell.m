//
//  TodoTableViewCell.m
//  Glasklart
//
//  Created by Jacob Persson on 2014-02-15.
//  Copyright (c) 2014 Jacob Persson. All rights reserved.
//

#import "UIColor+Additions.h"

#import "TodoTableViewCell.h"

@interface TodoTableViewCell ()

@property (strong, nonatomic) UIColor *deletedColor;
@property (strong, nonatomic) UIColor *completedColor;

@end

@implementation TodoTableViewCell

- (void)awakeFromNib
{
    self.baseColor = [UIColor redColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self setTitlePaneBackgroundColorForState:self.state];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        self.titlePane.backgroundColor = [self.titlePane.backgroundColor lightenColorWithValue:0.2];
    } else {
        [self setTitlePaneBackgroundColorForState:self.state];
    }
}

- (void)setState:(TodoCellState)state
{
    _state = state;
    [self setTitlePaneBackgroundColorForState:state];
    [self setTitleTextColorForState:state];
    [self setTitleText:self.titleTextField.text withStrikethrough:self.state == TodoCellStateCompleted || self.state == TodoCellStateComplete];
}

- (void)setTitlePaneBackgroundColorForState:(TodoCellState)state
{
    switch (state) {
        case TodoCellStateNormal:
            self.titlePane.backgroundColor = self.baseColor;
            break;
            
        case TodoCellStateComplete:
            self.titlePane.backgroundColor = self.completedColor;
            break;
            
        case TodoCellStateCompleted:
        case TodoCellStateDeleted:
            self.titlePane.backgroundColor = self.deletedColor;
            break;
    }
}

- (void)setTitleTextColorForState:(TodoCellState)state
{
    if (state == TodoCellStateCompleted) {
        self.titleTextField.textColor = [UIColor lightGrayColor];
    } else {
        self.titleTextField.textColor = [UIColor whiteColor];
    }
}

- (void)setTitleText:(NSString *)title withStrikethrough:(BOOL)strikethrough
{
    if (strikethrough) {
        NSDictionary *strikeTroughAttribute = @{ NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle) };
        
        self.titleTextField.attributedText = [[NSAttributedString alloc] initWithString:title
                                                                             attributes:strikeTroughAttribute];
    } else {
        self.titleTextField.text = title;
    }
}

- (void)prepareForReuse
{
    self.deleteLabel.alpha = 1;
    self.completeLabel.alpha = 1;
    self.titlePane.frame = CGRectMake(0, 0, self.titlePane.frame.size.width, self.titlePane.frame.size.height);
}

@end
