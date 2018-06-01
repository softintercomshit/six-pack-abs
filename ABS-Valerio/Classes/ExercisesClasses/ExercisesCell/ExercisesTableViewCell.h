#import <UIKit/UIKit.h>

@interface ExercisesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *separatorLineImageView;
-(void)setCategoryValues:(NSDictionary*)categoryInformationDictionary;


@end
