#import <UIKit/UIKit.h>

@interface ExercisesProgressContainerViewController : UIViewController

@property (nonatomic, strong) NSArray* exercisesArray;
@property (nonatomic)int numberOfCirles;
@property (nonatomic) BOOL isLastCircle;
@property (nonatomic) BOOL isLastExercise;
@property (weak, nonatomic) IBOutlet UICollectionView *currentExercisesCollectionView;

-(void)updateCurrentExerciseProgressView:(float)currentTime withTotalExerciseTime:(float)exerciseTime;
-(void)scrollCollectionView:(int)newIndex withRound:(int)currentRound animated:(BOOL)animated;
-(void)hideViewsOnOrientationChange:(BOOL)portraitOrientation withConstraint:(float)constraintConstant;

@end
