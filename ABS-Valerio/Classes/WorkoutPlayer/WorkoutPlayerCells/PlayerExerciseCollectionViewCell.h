#import <UIKit/UIKit.h>


@interface PlayerExerciseCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nextExerciseLabel;
-(void)setLabelOnCenter:(BOOL)labelOnCenter separatorOriginX:(float)originX;
-(void)setLabelOnCenter:(BOOL)labelOnCenter;

-(void)setExercisesInfo:(NSString*)currentExerciseName andNextExercise:(NSString*)nextExerciseName;


@end
