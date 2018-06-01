#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "CustomCell.h"
#import "UITableView+CustomEdit.h"

@interface GuideFirstViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    BOOL editButtonChecker;
    BOOL swipeChecker;
    NSIndexPath *highlightedPath;
//    int editCounter;
    NSArray *indexes;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *exercisArray;
@property (weak, nonatomic) IBOutlet UIButton *editButton;



@end
