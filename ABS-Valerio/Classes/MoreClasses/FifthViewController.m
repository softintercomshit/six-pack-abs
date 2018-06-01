//#include <sys/types.h>
//#include <sys/sysctl.h>
#import "FifthViewController.h"
#import <MessageUI/MessageUI.h>
#import "FacebookSDK/FacebookSDK.h"
#import <Twitter/Twitter.h>
#import "UIDevice-Hardware.h"
#import "iTellAFriend.h"
#import "PreviewSettingsController.h"

#import "MoreTableViewCell.h"

static NSString *kAppID = @"843233267";

@interface FifthViewController() <MoreTableViewCellDelegate, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FifthViewController{
    CGPoint initilTitleLabelPosition;
    NSArray* moreValuesArray;
}


BOOL isSelected;

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"moreItemKey".localized;
    [self.navigationController.navigationBar setBebasFont];
    isSelected = NO;
    
    moreValuesArray = @[
        @{@"icon": @"valera_icon", @"title": @"contactValerioKey".localized, @"description": @"www.vgfit.com", @"small":@1},
        @{@"icon": @"settings1", @"title": @"moreSettingsTitleKey".localized, @"small": @1},
        @{@"icon": @"send_feedback", @"title": @"sendFeedbackKey".localized, @"small": @1},
        @{@"icon": @"tellFriends", @"title": @"tellAFriendKey".localized, @"small": @1},
        @{@"icon": @"rateIt", @"title": @"rateUsKey".localized, @"small": @1, @"appId": @"843233267"},
        @{@"icon": @"ShareApp", @"title": @"Share app".localized, @"small": @1},
        @{@"icon": @"male", @"title": @"Fitness VIP", @"description":@"professionalTrainingKey".localized, @"small": @0, @"appId": @"698154775"},
        @{@"icon": @"female", @"title": @"femaleFitnessKey".localized, @"description": @"beBeautyKey".localized, @"small": @0, @"appId": @"698172579"},
        @{@"icon": @"yoga_icon", @"title": @"yogaKey".localized, @"description": @"yogaDescrKey".localized, @"small": @0, @"appId": @"1122658784"},
        @{@"icon": @"timer_icon", @"title": @"Timer Plus", @"description": @"", @"small": @0, @"appId": @"1160713176"},
        @{@"icon": @"7minutes", @"title": @"7 Minutes".localized, @"description":@"", @"small": @0, @"appId": @"1178939968"},
        @{@"icon": @"water_reminder", @"title": @"Water Reminder".localized, @"description":@"", @"small": @0, @"appId": @"1221965482"}
    ];
    [self registerCells];
}


-(void)registerCells{
    [_tableView registerNib:[UINib nibWithNibName:@"MoreMainTableViewCell" bundle:nil] forCellReuseIdentifier:@"MoreMainTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"MoreExpandableTableViewCell" bundle:nil] forCellReuseIdentifier:@"MoreExpandableTableViewCell"];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return moreValuesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString*  cellIdentifier =  indexPath.row == 0 && isSelected ?  @"MoreExpandableTableViewCell" : @"MoreMainTableViewCell";
    MoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (CGPointEqualToPoint(initilTitleLabelPosition, CGPointZero)) {
        initilTitleLabelPosition = cell.titleLabel.center;
    }
    
    [cell setMoreValues:moreValuesArray[indexPath.row]];
    if ([cellIdentifier  isEqualToString:@"MoreExpandableTableViewCell"]) {
        cell.delegate = self;
    }
    
    if(![cell.descriptionLabel.text length]){
        cell.titleLabel.center = CGPointMake(cell.titleLabel.center.x, cell.contentView.center.y);
    }else{
        [cell.titleLabel setCenter:initilTitleLabelPosition];
    }
    
    return cell;
}


#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0 && isSelected) {
        return  150;
    }
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            isSelected = !isSelected;
            if (isSelected) {
                
                [tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects:indexPath, nil] withRowAnimation: UITableViewRowAnimationFade];
                CGPoint point = CGPointMake(0, 600);
                NSLog(@"Selcted: %@", NSStringFromCGSize(self.tableView.contentSize));
                //            [tableView setContentOffset:point animated:YES];
                CGRect rect =[[tableView cellForRowAtIndexPath:indexPath] frame];
                NSLog(@"Cell frame: %@", NSStringFromCGRect(rect));
                point = rect.origin;
                point.y -= 70;
                [tableView performSelector:@selector(reloadData) withObject:self afterDelay:3.0];
            }else{
                [tableView reloadRowsAtIndexPaths: [NSArray arrayWithObjects:indexPath, nil] withRowAnimation: UITableViewRowAnimationFade];
            }
            break;
        case 1:
            {
                PreviewSettingsController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PreviewSettingsController"];
                [self.navigationController pushViewController:controller animated:true];
            }
            break;
        case 2:
            [self sendMail];
            break;
        case 3:
            [self tellAFriend];
            break;
        case 4:
            [[NSUserDefaults standardUserDefaults] setBool:true forKey:kRateUsIsPessedKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self rateApp];
            break;
        case 5:
            [ShareAppManager.shared shareAppWithAppId:kAppID
                                           controller:self
                                                 cell:[tableView cellForRowAtIndexPath:indexPath]];
            break;
        default:
        {
            NSDictionary *item = moreValuesArray[indexPath.row];
            NSString *appId = item[@"appId"];
            [self openAppId:appId];
        }
            break;
    }
}

-(void)rateApp {
    if (@available(iOS 10.3, *)) {
        [SKStoreReviewController requestReview];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@" stringByAppendingString:kAppID]]];
    }
}

-(void)openAppId:(NSString *)appId{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"itms-apps://itunes.apple.com/app/id" stringByAppendingString:appId]]];
}

#pragma mark - Sharing Methods
-(void)sendMail{
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    NSString *currDeiceVer = [[UIDevice currentDevice] deviceName];
    
    if ([MFMailComposeViewController canSendMail]) {
        NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[supportEmailAddress]];
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
        
        [composeViewController setMessageBody:[NSString stringWithFormat:@"********************\nDevice: %@\nModel: %@\nApplication Version: %@\nApplication Name: %@\n\n********************", currSysVer, currDeiceVer, currentVersion, appName] isHTML:NO];
        
        [[composeViewController navigationBar]setBarStyle:UIBarStyleBlackOpaque];
        [composeViewController .navigationBar setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:37.0f/255.0f blue:58.0f/255.0f alpha:1.0]];
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            [[composeViewController  navigationBar] setTintColor:[UIColor colorWithRed:255.0f/255.0f green:37.0f/255.0f blue:58.0f/255.0f alpha:1.0]];
            NSLog(@"ITEMS: %@", [[composeViewController navigationBar] items]);
        }else{
            [[composeViewController  navigationBar] setTintColor:[UIColor whiteColor]];
            NSLog(@"ITEMS: %@", [[[composeViewController navigationBar] items] description] );
        }
        
        composeViewController.navigationBar.translucent = YES;
        
        [self presentViewController:composeViewController animated:YES completion:nil];
    }else{
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[supportEmailAddress]];
        [self.navigationController pushViewController:composeViewController animated:YES];
    }
}

-(void)tellAFriend{
    if ([[iTellAFriend sharedInstance] canTellAFriend]) {
        UINavigationController* tellAFriendController = [[iTellAFriend sharedInstance] tellAFriendController];
        
        [[tellAFriendController navigationBar]setBarStyle:UIBarStyleBlackOpaque];
        [tellAFriendController.navigationBar setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:37.0f/255.0f blue:58.0f/255.0f alpha:1.0]];
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            [[tellAFriendController  navigationBar] setTintColor:[UIColor colorWithRed:255.0f/255.0f green:37.0f/255.0f blue:58.0f/255.0f alpha:1.0]];
            NSLog(@"ITEMS: %@", [[tellAFriendController navigationBar] items]);
        }else{
            [[tellAFriendController  navigationBar] setTintColor:[UIColor whiteColor]];
            NSLog(@"ITEMS: %@", [[[tellAFriendController navigationBar] items] description] );
        }
        
        tellAFriendController.navigationBar.translucent = YES;
        
        [self presentViewController:tellAFriendController animated:YES completion:nil];
    }else{
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[supportEmailAddress]];
        [self.navigationController pushViewController:composeViewController animated:YES];
    }
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    //Add an alert in case of failure
    [self dismissViewControllerAnimated:YES completion:nil];
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}


#pragma mark - MoreTableViewCellDelegate

-(void)mailContact{
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    NSString *currDeiceVer = [[UIDevice currentDevice] deviceName];
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[supportEmailAddress]];
//        [composeViewController setSubject:@"myfeedbackKey".localized];
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
        
        [composeViewController setMessageBody:[NSString stringWithFormat:@"********************\nDevice: %@\nModel: %@\nApplication Version: %@\nApplication Name: %@\n\n********************", currSysVer, currDeiceVer, currentVersion, appName] isHTML:NO];
//        [composeViewController setMessageBody:[NSString stringWithFormat:@"********************\nIOS Version: %@\nDevice Model: %@\nApplication Version: %@\n********************", currSysVer, currDeiceVer, currentVersion] isHTML:NO];
        [[composeViewController navigationBar]setBarStyle:UIBarStyleBlackOpaque];
        [composeViewController .navigationBar setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:37.0f/255.0f blue:58.0f/255.0f alpha:1.0]];
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            [[composeViewController  navigationBar] setTintColor:[UIColor colorWithRed:255.0f/255.0f green:37.0f/255.0f blue:58.0f/255.0f alpha:1.0]];
            NSLog(@"ITEMS: %@", [[composeViewController navigationBar] items]);
        }else{
            [[composeViewController  navigationBar] setTintColor:[UIColor whiteColor]];
            NSLog(@"ITEMS: %@", [[[composeViewController navigationBar] items] description] );
        }
        
        composeViewController.navigationBar.translucent = YES;
        [self presentViewController:composeViewController animated:YES completion:nil];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    }else
    {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[@"fitnessyourbody.com@gmail.com"]];
//        [composeViewController setSubject:@"absSupportKey".localized];
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
        
        [composeViewController setMessageBody:[NSString stringWithFormat:@"********************\nDevice: %@\nModel: %@\nApplication Version: %@\nApplication Name: %@\n\n********************", currSysVer, currDeiceVer, currentVersion, appName] isHTML:NO];
//        [composeViewController setMessageBody:[NSString stringWithFormat:@"********************\nDevice: %@\nModel: %@\nApplication Version: %@\n\n********************", currSysVer, currDeiceVer, currentVersion ] isHTML:NO];
        composeViewController.navigationController.navigationBar.translucent = NO;
        [[[composeViewController navigationController] navigationBar]setBarStyle:UIBarStyleBlackOpaque];
        [[composeViewController navigationController].navigationBar setBackgroundColor:[UIColor blueColor]];
        [[[composeViewController navigationController] navigationBar] setTintColor:[UIColor whiteColor]];
        [self.navigationController pushViewController:composeViewController animated:YES];
    }
}


-(void)fbContact{
    NSURL *appUrl = [NSURL URLWithString:@"fb://profile/378498615816626"];
    NSURL *siteUrl = [NSURL URLWithString:@"https://www.facebook.com/vgfitcom/"];
    [self openAppUrl:appUrl siteUrl:siteUrl];
}


-(void)instagramContact{
    NSURL *appUrl = [NSURL URLWithString:@"instagram://user?username=vgfitcom"];
    NSURL *siteUrl = [NSURL URLWithString:@"http://instagram.com/vgfitcom"];
    [self openAppUrl:appUrl siteUrl:siteUrl];
}

#pragma mark - folow on twiter
-(void)twitterFollow{
    NSURL *appUrl = [NSURL URLWithString:@"twitter://user?user_id=vgfitcom"];
    NSURL *siteUrl = [NSURL URLWithString:@"https://twitter.com/vgfitcom"];
    [self openAppUrl:appUrl siteUrl:siteUrl];
}

#pragma mark - open official website
-(void)openOffSite{
    NSURL *url = [NSURL URLWithString:@"http://vgfit.com/"];
    [self openAppUrl:nil siteUrl:url];
}

-(void)openAppUrl:(NSURL *)appUrl siteUrl:(NSURL * _Nonnull)siteUrl{

    UIApplication *application = [UIApplication sharedApplication];
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 10.0){

        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [application openURL:appUrl options:@{}
               completionHandler:^(BOOL success) {
                   if (!success) {
                       [application openURL:siteUrl];
                   }
               }];
        } else {
            [application openURL:siteUrl];
        }
    }
    else{
        bool can = [application canOpenURL:appUrl];
        if(can){
            [application openURL:appUrl];
        } else {
            [application openURL:siteUrl];
        }
    }
}

@end
