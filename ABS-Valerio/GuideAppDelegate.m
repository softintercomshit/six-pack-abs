#import "GuideAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "AppleWatchRequestsHandler.h"
#import "NSBundle+Language.h"
#import "RateButton.h"
#import "AFNetworking.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "UIImage+LaunchImage.h"

static NSString *const kIsOldUser = @"kIsOldUser";

static UIWindow *windowForScreens;
static NSString *const appIsRatedKey = @"appisrated";

@implementation GuideAppDelegate{
    RateButton *topButton;
    BOOL backgroundTaskStopCondition;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
//    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    NSLog(@"%@", documentsPath);
    
    [Fabric with:@[[Crashlytics class]]];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [self registerOldUsers];

    if (!SYSTEM_VERSION_LESS_THAN(@"8")) {
        [self showSplash];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
/* for screens
    windowForScreens = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
    [windowForScreens setBackgroundColor:RED_COLOR];
    [windowForScreens setRootViewController:[UIViewController new]];
    [windowForScreens makeKeyAndVisible];
    [[UIApplication sharedApplication] setStatusBarHidden:true];
    CGRect newRect = self.window.frame;
    newRect.size.height -=20;
    newRect.origin.y += 20;
    [self.window setFrame:newRect];
 */
    
    [self setDefaultExercisePreview];
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];

    [self openWatchSession];
    [self initApiRater];
    
    [self.window setBackgroundColor:RED_COLOR];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(ubiquitousKeyValueStoreDidChange:)
//                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
//                                               object:[NSUbiquitousKeyValueStore defaultStore]];
//    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    
    return YES;
}

//- (void)ubiquitousKeyValueStoreDidChange:(NSNotification*)notification {
//    NSUbiquitousKeyValueStore *ubiquitousKeyValueStore = notification.object;
//    [ubiquitousKeyValueStore synchronize];
//}

- (void)registerOldUsers {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL isOldUserLocal = [defaults boolForKey:kIsOldUser];
    BOOL isOldUserCloud = [[NSUbiquitousKeyValueStore defaultStore] boolForKey:kIsOldUser];
    
    if (!isOldUserLocal){
        [defaults setBool:true forKey:kIsOldUser];
        [defaults synchronize];
    }
    
    if (!isOldUserCloud){
        [[NSUbiquitousKeyValueStore defaultStore] setBool:true forKey:kIsOldUser];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    }
}

-(void)initApiRater{
    BOOL appIsRatedCloud = [[NSUbiquitousKeyValueStore defaultStore] boolForKey:appIsRatedKey];
    BOOL appIsRatedLocaly = [[NSUserDefaults standardUserDefaults] boolForKey:appIsRatedKey];
    BOOL isRated = appIsRatedCloud || appIsRatedLocaly;
    
    if (!isRated) {
        [Appirater setDebug:false];
        [Appirater appLaunched:YES];
        [Appirater setDelegate:self];
        
        [Appirater setAppId:@"843233267"];
        [Appirater setDaysUntilPrompt:2];
        [Appirater setUsesUntilPrompt:2];
        [Appirater setSignificantEventsUntilPrompt:-1];
        [Appirater setTimeBeforeReminding:2];
    }
}

- (void)showSplash {
    UIViewController *modalViewController = [[UIViewController alloc] init];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imgView.image = UIImage.launchImage;
    [modalViewController.view addSubview:imgView];
    [self.window setRootViewController:modalViewController];
    [self performSelector:@selector(hideSplash:) withObject:modalViewController afterDelay:2];
}

-(void)hideSplash:(UIViewController *)controller{
    UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self.window setRootViewController:[mainSB instantiateInitialViewController]];
}

-(void)setDefaultExercisePreview{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"setDefaultExercisePreview"]) {
        [defaults setBool:true forKey:@"setDefaultExercisePreview"];
        [defaults setInteger:ShortPreview forKey:kExercisePreviewKey];
        [defaults synchronize];
    }
}

//-(void)reloadApp{
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    [self.window setRootViewController:[sb instantiateInitialViewController]];
//}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"didEnterBackground" object: nil userInfo: nil];
    
    BOOL rateUsIsPessed = [[NSUserDefaults standardUserDefaults] boolForKey:kRateUsIsPessedKey];
    if (rateUsIsPessed) {
        [self handleBackground:application];
    }
}

-(void)handleBackground:(UIApplication *)application{
    __block UIBackgroundTaskIdentifier background_task;
    background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
        
        //Clean up code. Tell the system that we are done.
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
    
    backgroundTaskStopCondition = true;
    //To make the code block asynchronous
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //### background task starts
        NSLog(@"Running in the background\n");
        while(backgroundTaskStopCondition)
        {
            NSTimeInterval interval = [[UIApplication sharedApplication] backgroundTimeRemaining];
            if (interval <= 175) {
                NSLog(@"interval---->%f", interval);
                backgroundTaskStopCondition = false;
                [[NSUserDefaults standardUserDefaults] setBool:true  forKey:appIsRatedKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSUbiquitousKeyValueStore defaultStore] setBool:true forKey:appIsRatedKey];
                [[NSUbiquitousKeyValueStore defaultStore] synchronize];
                
                [application endBackgroundTask: background_task];
                background_task = UIBackgroundTaskInvalid;
            }
//            [NSThread sleepForTimeInterval:1]; //wait for 1 sec
        }
        
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    });
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    backgroundTaskStopCondition = false;
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:kRateUsIsPessedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self createTopButton];
    
    BOOL appIsRatedCloud = [[NSUbiquitousKeyValueStore defaultStore] boolForKey:appIsRatedKey];
    BOOL appIsRatedLocaly = [[NSUserDefaults standardUserDefaults] boolForKey:appIsRatedKey];
    
    if (appIsRatedCloud || appIsRatedLocaly) {
        [topButton removeFromSuperview];
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self appCheck:^(BOOL isOK) {
                if (isOK) {
                    [self.window addSubview:topButton];
                }
            }];
        });
    }
}


-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    if (_shouldRotateVideo) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Facebook Sharing

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
        NSString *query = [url fragment];
        if (!query) {
            query = [url query];
        }
        NSDictionary *params = [self parseURLParams:query];
        NSString *targetURLString = [params valueForKey:@"target_url"];
        if (targetURLString) {
            [[[UIAlertView alloc] initWithTitle:@"recevedLinkKey".localized message:targetURLString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
    return urlWasHandled;
}

// A function for parsing URL parameters
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

#pragma mark - Apple Watch delegate


-(void)openWatchSession{
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}


-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler{
    if(message[@"imagesPath"]){
        NSString* imagesPath = message[@"imagesPath"];
        [AppleWatchRequestsHandler getDictWithImagesForWathcKit:imagesPath withCompletionHandler:^(id result) {
            if (result) {
                NSDictionary* dictForReply=@{@"images":result};
                replyHandler(dictForReply);
            }
        }];
    }else if (message[@"superSetsInfo"]){
        [AppleWatchRequestsHandler getSuperSetsInformation:[GeneralDAO getAllexercises] withCompletionHandler:^(id result) {
            if (result) {
                NSDictionary* dictForReply=@{@"superSetsInfo":result};
                replyHandler(dictForReply);
            }
        }];
    }else if (message[@"customWorkouts"]){
        NSURL *documentsPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        double timestampFromWatch = [message[kLastCoreDataChangeKey] doubleValue];
        double timestampFromDevice = [[NSUserDefaults standardUserDefaults] doubleForKey:kLastCoreDataChangeKey];
        
        if (timestampFromWatch != timestampFromDevice || timestampFromWatch == 0) {
            NSNumber *lastCoreDataChange = [NSNumber numberWithDouble:[[NSUserDefaults standardUserDefaults] doubleForKey:kLastCoreDataChangeKey]];
            replyHandler(@{kLastCoreDataChangeKey: lastCoreDataChange});
            
            NSMutableArray *array = [NSMutableArray array];
            NSArray *fileNamesArray = @[@"ABS-Valerio-DB.sqlite", @"ABS-Valerio-DB.sqlite-shm", @"ABS-Valerio-DB.sqlite-wal"];
            for (NSString *fileName in fileNamesArray) {
                NSString *filePath = [documentsPath.path stringByAppendingPathComponent:fileName];
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                NSDictionary *dict = @{@"data": data, @"name": fileName};
                [array addObject:dict];
            }
            NSString *plistPath = [documentsPath.path stringByAppendingPathComponent:@"coredata.plist"];
            [[NSFileManager defaultManager] removeItemAtPath:plistPath error:nil];
            [array writeToFile:plistPath atomically:true];
            [session transferFile:[NSURL fileURLWithPath:plistPath] metadata:@{@"fileType": @"coredata"}];
        }
    }else if (message[@"getImages"]){
        NSArray<NSString*> *imagesNameArray = message[@"imagesNameArray"];
        NSURL *cachePath = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
        if (imagesNameArray.count > 0) {
            WCSession *session = [WCSession defaultSession];
            
            for (NSString *imageName in imagesNameArray) {
                NSURL *imageUrl = [cachePath URLByAppendingPathComponent:imageName];
                UIImage *image = [UIImage imageWithContentsOfFile:imageUrl.path];
                if (image) {
//                    image = [self imageWithImage:image scaledToWidth:150];
                    image = [self imageWithImage:image scaledToSize:CGSizeMake(200, 200)];
                    NSData *imageData = UIImagePNGRepresentation(image);
                    NSString *newImagePath = [cachePath.path stringByAppendingPathComponent:[@"copy" stringByAppendingString:imageName]];
                    [[NSFileManager defaultManager] removeItemAtPath:newImagePath error:nil];
                    [imageData writeToFile:newImagePath atomically:true];
                    [session transferFile:[NSURL fileURLWithPath: newImagePath] metadata:@{@"fileType": @"image", @"name": imageName}];
                }
            }
        }
    }
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = newSize.width;
    CGFloat targetHeight = newSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, newSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
        {
            scaleFactor = widthFactor; // scale to fit height
        }
        else
        {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
        {
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }
    
    UIGraphicsBeginImageContext(newSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil)
    {
        NSLog(@"no scale image");
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

//-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width{
//    float oldWidth = sourceImage.size.width;
//    float scaleFactor = i_width / oldWidth;
//    
//    float newHeight = sourceImage.size.height * scaleFactor;
//    float newWidth = oldWidth * scaleFactor;
//    
//    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
//    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//}

-(void)createTopButton{
    if (!topButton) {
        topButton = [RateButton new];
    }
}

-(void)appCheck:(void(^)(BOOL isOK))complition{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appBundleString = [[NSBundle mainBundle] bundleIdentifier];
    NSString *appVersionString = [info objectForKey:@"CFBundleShortVersionString"];
    NSString *bundleAndVersionString = [appBundleString stringByAppendingString:appVersionString];
//#warning need to remove test from bundleAndVersionString
//    bundleAndVersionString = @"test";
    NSString *urlString = [NSString stringWithFormat:@"http://secret.zemralab.com/api/%@/version",bundleAndVersionString];
    
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setSecurityPolicy:securityPolicy];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([responseString isEqualToString:bundleAndVersionString]) {
            if (complition) {
                complition(true);
            }
        }else{
            if (complition) {
                complition(false);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if (complition) {
            complition(false);
        }
    }];
}

//-(void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply{
//    if(userInfo[@"imagesPath"]){
//        NSString* imagesPath=userInfo[@"imagesPath"];
//        [AppleWatchRequestsHandler getDictWithImagesForWathcKit:imagesPath withCompletionHandler:^(id result) {
//            NSDictionary* dictForReply=@{@"images":result};
//            reply(dictForReply);
//        }];
//    }else{
//        [AppleWatchRequestsHandler getSuperSetsInformation:[GeneralDAO getAllexercises] withCompletionHandler:^(id result) {
//            NSDictionary* dictForReply=@{@"superSetsInfo":result};
//            reply(dictForReply);
//        }];
//    }
//}

#pragma mark - Appirater Delegates
-(void)appiraterDidOptToRate:(Appirater *)appirater{
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:kRateUsIsPessedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
