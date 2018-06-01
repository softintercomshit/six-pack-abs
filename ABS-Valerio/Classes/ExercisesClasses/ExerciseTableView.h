#import <UIKit/UIKit.h>

@interface ExerciseTableView : UITableViewController
{
    NSArray *arrWithImages;
    NSIndexPath *highlightedPath;
}

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) NSMutableArray *exerciseArray;
@property (strong, nonatomic) NSString *exercisePath;
@property (nonatomic) int circles;
@property (nonatomic) int customType;
@end
