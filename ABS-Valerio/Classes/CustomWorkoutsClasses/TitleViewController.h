#import <UIKit/UIKit.h>
#import "TTAlertView.h"

@protocol TitleViewControllerDelegate <NSObject>

@optional
-(void)goBack:(NSString*)title;

@end

@interface TitleViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *titleView;
@property (nonatomic, retain) NSString* titleString;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (nonatomic, retain) id <TitleViewControllerDelegate> delegate;

@end
