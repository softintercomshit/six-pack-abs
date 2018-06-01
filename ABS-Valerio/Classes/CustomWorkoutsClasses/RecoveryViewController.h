#import <UIKit/UIKit.h>
#import "CustomCell.h"
@protocol RecoveryViewControllerDelegate <NSObject>

@optional
- (void)choseRecovery:(int)recovery;

@end


@interface RecoveryViewController : UITableViewController

@property (weak, nonatomic) id <RecoveryViewControllerDelegate> delegate;
@property (readwrite, nonatomic) int selectedRow;

@end
