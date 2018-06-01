#import "PlayerExerciseCollectionViewCell.h"

@interface PlayerExerciseCollectionViewCell ()


@property (weak, nonatomic) IBOutlet UILabel *currentExerciseLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextExerciseNameSpacing;
@property (weak, nonatomic) IBOutlet UILabel *centeredLabel;


@end


@implementation PlayerExerciseCollectionViewCell


-(void)awakeFromNib{
    [super awakeFromNib];
//    [_currentExerciseLabel setBebasFontWithType:Bold size:isIpad? 20 : 17];
//    [_nextExerciseLabel setBebasFontWithType:Bold size:isIpad? 20 : 17];
    
    [_currentExerciseLabel setBebasFontWithType:Nike size:isIpad? 23 : 20];
    [_nextExerciseLabel setBebasFontWithType:Nike size:isIpad? 23 : 20];
    [_centeredLabel setBebasFontWithType:Nike size:isIpad? 23 : 20];
}

-(void)setExercisesInfo:(NSString*)currentExerciseName andNextExercise:(NSString*)nextExerciseName{
//    [self setLetterSpacingWithString:currentExerciseName label:_currentExerciseLabel];
//    [self setLetterSpacingWithString:nextExerciseName label:_nextExerciseLabel];
    _currentExerciseLabel.text = currentExerciseName;
    _nextExerciseLabel.text = nextExerciseName;
    _centeredLabel.text = nextExerciseName;
}

-(void)setLabelOnCenter:(BOOL)labelOnCenter{
    [self.nextExerciseLabel setHidden:labelOnCenter];
    [self.centeredLabel setHidden:!labelOnCenter];
}

-(void)setLabelOnCenter:(BOOL)labelOnCenter separatorOriginX:(float)originX{
    if (labelOnCenter) {
        float space = CGRectGetWidth([UIScreen mainScreen].bounds) - originX;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_nextExerciseLabel setCenter:CGPointMake((float)space/2+originX, _nextExerciseLabel.center.y)];
            [_nextExerciseLabel translatesAutoresizingMaskIntoConstraints];
        });
        [self.nextExerciseLabel setTextAlignment:NSTextAlignmentCenter];
    }else{
//        _nextExerciseNameSpacing.constant = 85;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _nextExerciseNameSpacing.constant = 85+1;
//            [_nextExerciseLabel setCenter:CGPointMake((float)space/2+originX, _nextExerciseLabel.center.y)];
        });
        [self.nextExerciseLabel setTextAlignment:NSTextAlignmentLeft];
    }
}
@end
