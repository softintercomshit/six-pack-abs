#import <UIKit/UIKit.h>

@interface AdviceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *openBlogButton;

-(void)setAdviceValues:(NSDictionary*)adviceValuesDictioanry isExpandable:(BOOL)expandableValue;


@property (strong, nonatomic) NSString* blogUrl;
    
@end
