#import <UIKit/UIKit.h>
#import "GuideAppDelegate.h"
#import "Workout.h"
#import "Eercise.h"
#import "Photos.h"
#import "Repetitions.h"
#import "ExercisePrevController.h"
#import "CustomProgramCreatorViewController.h"
#import "CustomCell.h"

@interface EditExercisesController : UITableViewController<ExercisePrevControllerDelegate, CustomProgramCreatorViewControllerDelegate, UIActionSheetDelegate>
{
    int circles;
//    int editCounter;
    
    BOOL editing;
    BOOL swipeChecker;
    BOOL didLayout;
    
    UIActionSheet *actionSh;
    
//    NSIndexPath *highlightedPath;
    
   // NSArray *indexes;
}
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, retain) NSArray *fetchArray;
@property (nonatomic, retain) NSString *workoutTitle;
@property (nonatomic, retain) NSMutableArray *exerciseArray;
@property (nonatomic, weak) id <ExercisePrevControllerDelegate> delegate;
@property (nonatomic, weak) id <CustomProgramCreatorViewControllerDelegate> customDelegate;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic, readwrite) BOOL isNew;
@property (nonatomic, strong) Workout *workout;

-(IBAction)moveBack:(id)sender;
-(IBAction)seteditingTableiew:(id)sender;
@end
