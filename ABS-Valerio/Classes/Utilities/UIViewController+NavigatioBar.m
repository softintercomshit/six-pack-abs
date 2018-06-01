#import "UIViewController+NavigatioBar.h"

@implementation UIViewController (NavigatioBar)

-(void)viewDidLoad{
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:RED_COLOR];
    [self.navigationController.navigationBar  setTranslucent:NO];
}

@end
