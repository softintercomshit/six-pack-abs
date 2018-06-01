#import <UIKit/UIKit.h>


@protocol MoreTableViewCellDelegate <NSObject>

-(void)mailContact;
-(void)fbContact;
-(void)instagramContact;
-(void)twitterFollow;
-(void)openOffSite;

@end

@interface MoreTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, weak) id <MoreTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *disclosureIndicatorImageView;


-(void)setMoreValues:(NSDictionary*)moreValuesDictionary;
- (void) centerTitleIfNeeded;

@end
