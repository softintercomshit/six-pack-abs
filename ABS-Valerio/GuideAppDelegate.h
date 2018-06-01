#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import <Appirater/Appirater.h>

@interface GuideAppDelegate : UIResponder <UIApplicationDelegate, WCSessionDelegate, AppiraterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL shouldRotateVideo;

//-(void)reloadApp;

@end
