#import "RateButton.h"
#import "AFNetworking.h"
#import <MessageUI/MessageUI.h>
#import "UIDevice-Hardware.h"

@interface RateButton()<MFMailComposeViewControllerDelegate>

@end

@implementation RateButton{
    SEL okActionGlobal, cancelActionGlobal;
}

-(instancetype)init{
    if (self = [super init]) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        float width = isIpad ? 120 : 90;
        float height = isIpad ? 30 : 22;
        float originX = screenSize.width - width;
        float originY = screenSize.height - 49 - height;
        
        [self setFrame:CGRectMake(originX, originY, width, height)];
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    [self setImage:[UIImage imageNamed:@"fiveStars"] forState:UIControlStateNormal];
    [self addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    [super drawRect:rect];
}

-(void)showAlertWithTitle:(NSString *)title
                  message:(NSString *)message
             okBottonText:(NSString *)okButtonText
         cancelButtonText:(NSString *)cancelButtonText
                 okAction:(SEL)okAction
             cancelAction:(SEL)cancelAction
{
    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:okButtonText otherButtonTitles:cancelButtonText, nil];
        [alertView show];
        okActionGlobal = okAction;
        cancelActionGlobal = cancelAction;
    }else{
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:title
                                     message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:okButtonText.localized
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       if (okAction) {
                                           [self performSelector:okAction];
                                       }
                                   }];
        
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:cancelButtonText.localized
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           if (cancelAction) {
                                               [self performSelector:cancelAction];
                                           }
                                       }];
        
        [alert addAction:okButton];
        [alert addAction:cancelButton];
        
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if (okActionGlobal) {
            [self performSelector:okActionGlobal];
        }
    }else{
        if (cancelActionGlobal) {
            [self performSelector:cancelActionGlobal];
        }
    }
}

-(void)buttonAction{
    [self showAlertWithTitle:@"5-Stars".localized
                     message:@"To improve the app, please Leave a Rating or Review.".localized
                okBottonText:@"Not now".localized
            cancelButtonText:@"Rate us".localized
                    okAction:@selector(notNowAction)
                cancelAction:@selector(leaveAReview)];
//    okAction = leaveAReview;
}

#pragma mark - alert controller selectors

-(void)likeTheApp{
    [self showAlertWithTitle:@"Wow great!".localized
                     message:@"Would you mind leaving us a review on the App Store? Review will help us to improvethe app.".localized
                okBottonText:@"Not now".localized
            cancelButtonText:@"Leave Us a Review".localized
                    okAction:nil
                cancelAction:@selector(leaveAReview)];
}

-(void)notNowAction{
    [self showAlertWithTitle:@"Oh Dear!".localized
                     message:@"We would be grateful if you could consider giving us some ideas to improve the app. Thank you!".localized
                okBottonText:@"Not now".localized
            cancelButtonText:@"Email Us".localized
                    okAction:nil
                cancelAction:@selector(emailUs)];
}

-(void)leaveAReview{
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:kRateUsIsPessedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/6-pack-abs-by-valerio-gucci/id843233267?mt=8"]];
}

-(void)emailUs{
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    NSString *currDeiceVer = [[UIDevice currentDevice] deviceName];
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
    [composeViewController setMailComposeDelegate:self];
    [composeViewController setToRecipients:@[supportEmailAddress]];
    
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
    
    [composeViewController setMessageBody:[NSString stringWithFormat:@"********************\nDevice: %@\nModel: %@\nApplication Version: %@\nApplication Name: %@\n\n********************", currSysVer, currDeiceVer, currentVersion, appName] isHTML:NO];
    
    if ([MFMailComposeViewController canSendMail]) {
        [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:composeViewController animated:true completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    //Add an alert in case of failure
    [controller dismissViewControllerAnimated:YES completion:nil];
}
@end
