#import <UIKit/UIKit.h>
#import "Eercise.h"
#import "Repetitions.h"
#import "CustomUnwindSegue.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

@class ExercisePrevController;
@protocol ExercisePrevControllerDelegate <NSObject>
@optional
- (void)addExercise:(NSDictionary *)exercise;
@required

@end


@interface ExercisePrevController : UIViewController< UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    BOOL pageControlBeginUsed;
//    BOOL didPicked;
    NSMutableArray *repsArray;
    Eercise *exercise;
    BOOL customExercise;
    BOOL doSelect;
    NSString *descrPath;
 
    
//    BOOL didLayout;
    
    UIActionSheet *actionSheet;
    
//    UIView *descrView;
//    MPMoviePlayerController *player;
}

//@property (weak, nonatomic) IBOutlet UIImageView *backgroundImg;
//@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
//@property (weak, nonatomic) IBOutlet UIView *titleView;

//@property (weak, nonatomic) IBOutlet UIScrollView *titleScroll;
@property (nonatomic, readwrite) BOOL isEditingExercise;
@property (nonatomic, readwrite) BOOL  isWorkout;
//@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *repsPicker;
@property (nonatomic, readwrite) BOOL custom;
@property (nonatomic, readwrite) BOOL isWithVideo;
@property (strong, nonatomic) NSString *titleString;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//@property (strong, nonatomic) IBOutlet UILabel *descriptLbl;
@property (weak, nonatomic) IBOutlet UIScrollView *photoSrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) NSString *exercisePath;
@property (strong, nonatomic) NSString *workTitle;
@property (nonatomic, readwrite) BOOL isCreating;
@property (nonatomic, strong) id <ExercisePrevControllerDelegate> delegate;
@property (nonatomic, readwrite) int circles;
@property (nonatomic, readwrite) int exercSort;
@property (strong, nonatomic) Workout *workout;

- (IBAction)changePage;
- (IBAction)goback:(id)sender;

-(IBAction)addExerciseToWorkout;
-(IBAction)saveExerciseCanges;

//-(IBAction)descriptionShow:(id)sender;
//-(IBAction)playVideo:(id)sender;
@end
