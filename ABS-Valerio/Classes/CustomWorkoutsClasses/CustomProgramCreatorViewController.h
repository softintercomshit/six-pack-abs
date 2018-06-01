#import <UIKit/UIKit.h>
#import "TitleViewController.h"
#import "DescriptionViewController.h"
#import "RepetitionsViewContoller.h"
#import "GuideAppDelegate.h"
#import "Workout.h"
#import "Eercise.h"
#import "Photos.h"
#import "Repetitions.h"

#import "CustomCell.h"

@protocol CustomProgramCreatorViewControllerDelegate <NSObject>

@optional
-(void)sendExercise:(NSDictionary*)exerciseData;

@end

@interface CustomProgramCreatorViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TitleViewControllerDelegate, DescriptionViewControllerDelegate, RepetitionsViewContollerDelegate>
{
    UIImagePickerController *imagePickerController;

    NSMutableArray *photoArray;
    NSString *exerciseTitle;
    NSString *descriptionString;
    NSString *repsString;
    NSArray *repsArray;
    NSString *descriptionPath;
    Eercise *exercise;

}

@property (nonatomic, weak)  IBOutlet UIScrollView *imageScrollView;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray *fetchArray;
@property (nonatomic, retain) NSString *folderPath;
@property (nonatomic, readwrite) int circles;
@property (nonatomic, readwrite) BOOL editing;
@property (nonatomic, retain) NSString *exerciseTitle;
@property (nonatomic, retain) NSString *workoutTitle;
@property (strong, nonatomic) Workout *workout;
@property (nonatomic, retain) id<CustomProgramCreatorViewControllerDelegate> delegate;
-(IBAction)saveExercise:(id)sender;
-(IBAction)popBack :(id)sender;
@end
