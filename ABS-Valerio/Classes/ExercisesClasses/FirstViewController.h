#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>


@interface FirstViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) int circles;
@property (nonatomic) int customType;
@property (strong, nonatomic) NSMutableArray *categoryArray;

//@property (weak, nonatomic) IBOutlet UIView *getSixPackView;
@property (nonatomic) BOOL getSixPackHideValue;
@property (weak, nonatomic) IBOutlet UIButton *getSixPackButton;

@end
