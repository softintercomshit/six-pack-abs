#import <UIKit/UIKit.h>
#import "GuideAppDelegate.h"
#import "Workout.h"
#import "Eercise.h"
#import "Repetitions.h"
#import "Photos.h"
#import "EditExercisesController.h"
#import "RecoveryViewController.h"

@interface EditWorkoutController : UIViewController


//@property (weak, nonatomic) IBOutlet UIPickerView *circlesPicker;
@property (weak, nonatomic) IBOutlet UITextField *titleInput;
@property (nonatomic, retain) NSString * workoutTitle;
@property (weak, nonatomic) IBOutlet UIButton *recoveryButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationViewHeightConstraint;
@property (strong, nonatomic) Workout *workout;
//@property (nonatomic, readwrite) BOOL isNew;


@end
