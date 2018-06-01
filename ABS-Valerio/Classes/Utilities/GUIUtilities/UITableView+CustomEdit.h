#import <UIKit/UIKit.h>

@interface UITableView (CustomEdit)
@property (nonatomic, readwrite) BOOL isInEditMode;

-(void)setTableViewEditing:(BOOL)editing;

-(void)beginEditing;
@end
