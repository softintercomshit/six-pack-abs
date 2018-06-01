#import "UITableView+CustomEdit.h"

@implementation UITableView (CustomEdit)

-(void)setTableViewEditing:(BOOL)editing
{
    if (editing) {
        [self beginEditing1];
    }else{
        [self endEditing];
    }
}

-(void)beginEditing1
{
    CGRect frame = self.frame;
    frame.origin.x = 30;
    
    [UIView animateWithDuration:0.5 animations:^{
    
        [self setFrame:frame];
    }];
}

-(void)endEditing
{
    CGRect frame = self.frame;
    frame.origin.x = 0;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        [self setFrame:frame];
    }];
}



@end
