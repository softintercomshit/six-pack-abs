#import "ExercisesTableViewCell.h"

@interface ExercisesTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;

@property (weak, nonatomic) IBOutlet UILabel *categoryExercisesCountLabel;

@property (weak, nonatomic) IBOutlet UIImageView *filterImageView;

@end

@implementation ExercisesTableViewCell


-(void)awakeFromNib{
    [super awakeFromNib];
    _separatorLineImageView.frame = CGRectMake(_separatorLineImageView.frame.origin.x, _separatorLineImageView.frame.origin.y, _separatorLineImageView.frame.size.width, 1/[UIScreen mainScreen].scale);
    
    [_categoryNameLabel setBebasFontWithType:Bold size:isIpad? 31 : SYSTEM_VERSION_LESS_THAN(@"8") ? 19 : 28];
    [_categoryExercisesCountLabel setBebasFontWithType:Regular size:isIpad? 20 : SYSTEM_VERSION_LESS_THAN(@"8") ? 12 : 15];

//    [_categoryNameLabel setTextColor:RGBA(65, 62, 62, 1)];
    [_categoryExercisesCountLabel setTextColor:RGBA(151, 151, 151, .8)];
    
//    if(isIpad){
//        _categoryNameLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:28];
//        _categoryExercisesCountLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:17];
//    }
}


-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    _categoryImageView.alpha = highlighted ? 0.7 : 1;
    _categoryNameLabel.textColor =  highlighted ? RED_COLOR : RGBA(65, 62, 62, 1);
}


-(void)setCategoryValues:(NSDictionary*)categoryInformationDictionary{
    NSString *imageName = categoryInformationDictionary[@"categoryImage"];
    imageName = [imageName stringByDeletingPathExtension];
    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
        [_categoryImageView setContentMode:UIViewContentModeScaleAspectFit];
    }else
        [_categoryImageView setContentMode:UIViewContentModeScaleAspectFill];
    
    [_categoryImageView setImage:[UIImage imageNamed:imageName]];
    _categoryExercisesCountLabel.text = [NSString stringWithFormat:@"%@ %@",categoryInformationDictionary[@"exerciseNumbers"], @"exercisesItemKey".localized];
//     _categoryNameLabel.text = [categoryInformationDictionary[@"path"] lastPathComponent];
}


@end
