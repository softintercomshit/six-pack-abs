#import "PlayerExerciseTableViewCell.h"

@implementation PlayerExerciseTableViewCell


-(void)awakeFromNib{
    [super awakeFromNib];
    [_exerciseNameLabel setBebasFontWithType:Bold size:isIpad? 27 : 20];
    [_exerciseDurationLabel setBebasFontWithType:Regular size:isIpad? 17 : 14];
//    if(isIpad){
//        _exerciseNameLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:23];
//        _exerciseDurationLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
//    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    [self setCurrentSelected:highlighted withFilter:YES];
}


-(void)setExerciseInformation:(NSString*)exerciseName exercisePhoto:(NSString*)photo withTime:(NSString*)exerciseDuration isCustom:(BOOL)customState{
    if(customState){
        _customImageView.image =  [UIImage imageWithContentsOfFile:photo];
        
    }else{
        _defaultExerciseImageView.image =  [UIImage imageWithContentsOfFile:photo];
    }
    
    _defaultExerciseImageView.hidden = customState;
    _customImageView.hidden = !customState;
    
    _defaultExerciseImageView.image =  [UIImage imageWithContentsOfFile:photo];
    _exerciseNameLabel.text = exerciseName;
    _exerciseDurationLabel.text = exerciseDuration;
}


-(void)setCurrentSelected:(BOOL)selectionState withFilter:(BOOL)filterState{
    if(selectionState){
        [_exerciseNameLabel setTextColor:RED_COLOR];
        [_rightLineImageView setBackgroundColor:RED_COLOR];
        _closureIndicatorImageVIew.image = [UIImage imageNamed:@"closureIndicator_red"];
        if(filterState)
            [_filterImageView setBackgroundColor:[UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:0.3]];
    }else{
        if(!_selectedCell){
            [_exerciseNameLabel setTextColor:GRAY_MAIN_TEXT_COLOR];
            _closureIndicatorImageVIew.image = [UIImage imageNamed:@"closureIndicator"];
            [_rightLineImageView setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1]];
        }
        [_filterImageView setBackgroundColor:[UIColor clearColor]];
    }
}


@end
