#import <UIKit/UIKit.h>

@interface PlayerExerciseTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *defaultExerciseImageView;
@property (weak, nonatomic) IBOutlet UIImageView *customImageView;
@property (weak, nonatomic) IBOutlet UILabel *exerciseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseDurationLabel;

@property (weak, nonatomic) IBOutlet UIImageView *closureIndicatorImageVIew;

@property (weak, nonatomic) IBOutlet UIImageView *filterImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightLineImageView;

@property (nonatomic) BOOL selectedCell;

-(void)setExerciseInformation:(NSString*)exerciseName exercisePhoto:(NSString*)photo withTime:(NSString*)exerciseDuration isCustom:(BOOL)customState;
-(void)setCurrentSelected:(BOOL)selectionState withFilter:(BOOL)filterState;


@end
