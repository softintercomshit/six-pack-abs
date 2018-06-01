#import <UIKit/UIKit.h>


@interface CustomCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak, nonatomic) IBOutlet UILabel *detailedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *customImage;
@property (weak, nonatomic) IBOutlet UIView *cellSeparator;
@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UIImageView *filterImageView;

@end
