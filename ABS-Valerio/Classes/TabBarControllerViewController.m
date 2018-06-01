#import "TabBarControllerViewController.h"

#import "FirstViewController.h"

@interface TabBarControllerViewController ()

@end

@implementation TabBarControllerViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSArray* tabBarImagesArray = @[@"exercises.png",@"workouts.png",@"custom.png",@"advice.png",@"more.png"]; // pressed
    for(int i = 0; i < [self.tabBar items].count; i++){
        UITabBarItem *currentItem = [[self.tabBar items] objectAtIndex:i];
        [currentItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: RGBA(65, 62, 62, 1), NSForegroundColorAttributeName, [UIFont fontWithName:@"BebasNeueBold" size:10.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
        [currentItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor colorWithRed:250/255 green:90/255 blue:85/255 alpha:0.7], NSForegroundColorAttributeName, [UIFont fontWithName:@"BebasNeueBold" size:10.0], NSFontAttributeName, nil] forState:UIControlStateHighlighted];
        [currentItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: RED_COLOR, NSForegroundColorAttributeName, [UIFont fontWithName:@"BebasNeueBold" size:10.0], NSFontAttributeName, nil] forState:UIControlStateSelected];
        [currentItem setSelectedImage:[[UIImage imageNamed:[NSString stringWithFormat:@"pressed_%@",tabBarImagesArray[i]]]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [currentItem setImage:[[UIImage imageNamed:tabBarImagesArray[i]]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        
        switch (i) {
            case 1:
                [currentItem setImageInsets:UIEdgeInsetsMake(0, 5, 0, -5)];
                break;
            case 2:
                [currentItem setImageInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
                break;
            default:
                break;
        }
    }
    
    [self.tabBar setBackgroundImage:[ImageUtility imageWithColor:[UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1]]];
    [self.tabBar setTranslucent:NO];
}


-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    if(item.tag == 1){
        UINavigationController* firstItemNavigationController = [self.viewControllers objectAtIndex:0];
        FirstViewController *yourViewController= (FirstViewController*)firstItemNavigationController.topViewController;
        yourViewController.getSixPackHideValue = NO;
    }
}

@end
