#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>


#import "Eercise.h"
#import "Repetitions.h"
#import "Photos.h"
#import "Workout.h"


@interface StrartViewController : UIViewController

#pragma mark - Navigation Elements


//@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *numberOfExerciseLabel;


@property (weak, nonatomic) IBOutlet UIImageView *exerciseImageView;
@property (nonatomic) NSInteger kcalories;

@property (strong, nonatomic) NSMutableArray *exerciseArray;
//@property (strong, nonatomic) NSMutableArray *exercisePhotosArray;
@property (strong, nonatomic) NSArray *repsArray;

@property (nonatomic, readwrite) int  recovery;
@property (nonatomic, readwrite) BOOL isPredefined;

//@property (weak, nonatomic) IBOutlet UIButton *soundsMenuButton;


#pragma mark - Sounds Elements

//@property (weak, nonatomic) IBOutlet UIView *buttonsSoundsView;
//@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *soundButtonsArray;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsViewHeightConstraint;


@property (nonatomic) int currentVideoIndex;
@property (nonatomic) int remainedRounds;
//@property (nonatomic, retain) NSArray *fetchArray;

//@property (nonatomic,strong) NSString* titleName;


-(void)setCurrentRoundAndIndex:(int)currentVideoIndex withRemainedRound:(int)remainedRound;
    
    
    
@end
