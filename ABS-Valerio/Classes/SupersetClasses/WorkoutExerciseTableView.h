#import <UIKit/UIKit.h>

@interface WorkoutExerciseTableView : UIViewController
{
    NSMutableDictionary *daysDictionaryContent;
    NSMutableArray *exrciseArray;
//    NSMutableArray *exercisePhotosArr;
    NSArray *repsArray;
    NSString *repsString;
    NSIndexPath *highlightedPath;
}

@property (strong, nonatomic) NSMutableArray *exeriseAray;
@property (strong, nonatomic) NSString *exercisesPath;
@property (strong, nonatomic) NSArray *fileList;
//@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (nonatomic) NSInteger kcalories;

-(IBAction)goback:(id)sender;
@end
