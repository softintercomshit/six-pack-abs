#import <UIKit/UIKit.h>

@protocol DescriptionViewControllerDelegate <NSObject>

@optional
-(void)returnDescription:(NSString*)description;

@end

@interface DescriptionViewController : UIViewController
{
    UILabel *lbl;
}
@property (weak, nonatomic) IBOutlet UITextView *descriptionView;
@property (nonatomic, retain) NSString *descrString;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (nonatomic, retain) id <DescriptionViewControllerDelegate> delegate;

@end
