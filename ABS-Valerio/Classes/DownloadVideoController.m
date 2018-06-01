#import "DownloadVideoController.h"
#import "AFNetworking.h"

#define BaseURL(exerciseName) [NSString stringWithFormat:@"http://sixpack.vgfit.com/%@", exerciseName]

@interface DownloadVideoController ()<UIAlertViewDelegate>{
    UIViewController *_containerController;
    NSMutableArray<NSString *> *exerciseNames;
    NSInteger totalExercises, downloadedExercises;
    NSMutableArray<NSURLSessionDownloadTask *> *downloadTasksArray;
}

@end

@implementation DownloadVideoController{
    __weak IBOutlet UIView *downloadingView;
    __weak IBOutlet UILabel *downloadingStateLabel;
    __weak IBOutlet UILabel *percentageLabel;
    __weak IBOutlet UIButton *cancelButtonOutlet;
    __weak IBOutlet UIProgressView *progressView;
}

-(instancetype)initWithVideoName:(NSString *)videoName containerController:(UIViewController *)containerController{
    _containerController = containerController;
    exerciseNames = [NSMutableArray array];
    [exerciseNames addObject:videoName];
    totalExercises = 1;
    
    return self;
}

-(instancetype)initWithArrayOfVideoNames:(NSArray<NSString *> *)array containerController:(UIViewController *)containerController{
    _containerController = containerController;
    exerciseNames = array.mutableCopy;
    totalExercises = exerciseNames.count;
    
    return self;
}

-(instancetype)initWithAllVideosAndContainerController:(UIViewController *)containerController{
    _containerController = containerController;
    exerciseNames = @[@"Abdominal Crunch On a Ball.mp4",@"Abdominal Crunch on Ball.mp4",@"Abdominal Reverse Curl 1.mp4",@"Abdominal Reverse Curl 2.mp4",@"Alternate Heel Touch.mp4",@"Ball Pull-In.mp4",@"Barbell Side Bend.mp4",@"Bench Leg Raise.mp4",@"Bent-Leg V-Up.mp4",@"Bodyweight Butt Ups.mp4",@"Bodyweight Crunch.mp4",@"Bodyweight Leg Raise (Legs Straight).mp4",@"Bodyweight Leg Raise with Ball.mp4",@"Bodyweight Leg Raise.mp4",@"Bodyweight Scissor Kick.mp4",@"Bodyweight Side Bend (Single Side).mp4",@"Bodyweight Superman (Alternating).mp4",@"Bodyweight Superman.mp4",@"Bodyweight Toe Touch.mp4",@"Bodyweight Twist (Russian).mp4",@"Bodyweight Twist 1.mp4",@"Bodyweight Twist 2.mp4",@"Clam.mp4",@"Crisscross.mp4",@"Decline Reverse Crunch.mp4",@"Decline Twisting Ab Crunch.mp4",@"Dip Station Bent Leg Raise with Twist.mp4",@"Dip Station Leg Raise.mp4",@"Dumbbell Bench Twist- left.mp4",@"Dumbbell Bench Twist- right.mp4",@"Dumbbell Crunch 1.mp4",@"Dumbbell Crunch 2.mp4",@"Dumbbell Side Bend- left.mp4",@"Dumbbell Side Bend- right.mp4",@"Flat Bench Lying Leg Raise.mp4",@"Hanging Knee Raise to the Side.mp4",@"Hanging Knee Raise.mp4",@"Hanging Leg Raise 1.mp4",@"Hanging Pike.mp4",@"Hanging Side Leg Raise.mp4",@"Incline Crunch.mp4",@"Jackknife Sit-Up 1.mp4",@"Jackknife Sit-Up 2.mp4",@"Kettlebell Russian Twist 1.mp4",@"Kettlebell Russian Twist 2.mp4",@"Medicine Ball Sit-Up.mp4",@"Modified Elbow to Knee Crunch- left.mp4",@"Modified Elbow to Knee Crunch- right.mp4",@"Mountain Climber 1.mp4",@"Mountain Climber 2.mp4",@"Mountain Climber 3.mp4",@"Oblique V-Up.mp4",@"One Leg Drop.mp4",@"Plank.mp4",@"Pulse Up.mp4",@"Scissor Kick.mp4",@"Seated Jackknife.mp4",@"Seated Leg Tucks.mp4",@"Side Bridge- left.mp4",@"Side Bridge- right.mp4",@"Side Crunch- right.mp4",@"Side Crunch- left.mp4",@"Stability Ball Pikes.mp4",@"Standing Torso Twist.mp4",@"Star Sit-Up.mp4",@"Straight Arm Crunch.mp4",@"Superman 1.mp4",@"Superman 2.mp4",@"Superman second side.mp4",@"Swiss-Ball Torso Twist.mp4",@"Toe Touch 1.mp4",@"Toe Touch 2.mp4",@"Traditional Crunch.mp4",@"V-Sit with Medicine Ball.mp4",@"V-Up.mp4",@"Wheel Rollout.mp4"].mutableCopy;
    totalExercises = exerciseNames.count;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setItemsFont];
    [downloadingView.layer setCornerRadius:5];
    if (totalExercises == 1) {
        [downloadingStateLabel setText:@"downloadOneVideoKey".localized];
    }else
        [downloadingStateLabel setText:[NSString stringWithFormat:@"%@ %ld / %ld",@"downloadMultipleVideoKey".localized, downloadedExercises, totalExercises]];
}

-(void)setItemsFont{
    [downloadingStateLabel setBebasFontWithType:Regular size:20];
    [percentageLabel setBebasFontWithType:Regular size:20];
    [cancelButtonOutlet setBebasFontWithType:Regular size:20];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)startDownload{
    UIView *view = self.view;
    [view setFrame:_containerController.view.bounds];
    [_containerController.view addSubview:view];
    
    if (!downloadTasksArray) {
        downloadTasksArray = [NSMutableArray array];
    }
    
    for (NSString *exerciseName in exerciseNames) {
        [downloadTasksArray addObject:[self downloadVideoWithExerciseName:exerciseName]];
    }
    
    if (![self internetIsConnected]) {
        [self showAlertWithTitle:@"internetConnectionKey".localized message:@"internetConnectionLostKey".localized];
        return;
    }
    [downloadTasksArray[0] resume];
}

-(NSURLSessionDownloadTask *)downloadVideoWithExerciseName:(NSString *)exerciseName{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *exerciseUrlString = [exerciseName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSURL *URL = [NSURL URLWithString:BaseURL(exerciseUrlString)];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    __block NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (totalExercises == 1) {
            float progress = (float)downloadProgress.completedUnitCount/(float)downloadProgress.totalUnitCount;
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressView setProgress:progress];
                [percentageLabel setText:[NSString stringWithFormat:@"%.f%%", progress*100]];
            });
        }else{
            float progress = (float)downloadProgress.completedUnitCount/(float)downloadProgress.totalUnitCount;
            progress = (float)downloadedExercises/(float)totalExercises + progress/(float)totalExercises;
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressView setProgress: progress];
                [percentageLabel setText:[NSString stringWithFormat:@"%.f%%", progress*100]];
            });
        }
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSFileManager *manager = [NSFileManager defaultManager];
        NSURL *documentsDirectoryURL = [manager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSString *videosPath = [documentsDirectoryURL.path stringByAppendingPathComponent:@"videos"];
        [manager createDirectoryAtPath:videosPath withIntermediateDirectories:false attributes:nil error:nil];
        return [NSURL fileURLWithPath:[videosPath stringByAppendingPathComponent:exerciseName]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (!error) {
            NSLog(@"File downloaded to: %@", filePath);
            downloadedExercises++;
            
            if (totalExercises > 1) {
                [downloadingStateLabel setText:[NSString stringWithFormat:@"%@ %ld / %ld",@"downloadMultipleVideoKey".localized, downloadedExercises, totalExercises]];
//                [progressView setProgress:(float)downloadedExercises/(float)totalExercises];
                
                NSInteger percents = (float)downloadedExercises/(float)totalExercises*100;
                [percentageLabel setText:[NSString stringWithFormat:@"%ld%%", percents]];
                [downloadTasksArray removeObject:downloadTask];
                if (downloadTasksArray.count > 0) {
                    if (![self internetIsConnected]) {
                        [self performSelector:@selector(cancelButtonAction:)];
                        [self showAlertWithTitle:@"internetConnectionKey".localized message:@"internetConnectionLostKey".localized];
                        return;
                    }
                    [downloadTasksArray[0] resume];
                }
                
                if (downloadedExercises == totalExercises) {
                    [self dismissController];
                    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishDownloadingWithPath:)]) {
                        [self.delegate didFinishDownloadingWithPath:nil];
                    }
                }
            }else{
                [self dismissController];
                if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishDownloadingWithPath:)]) {
                    [self.delegate didFinishDownloadingWithPath:filePath.path];
                }
            }
        }else{
            [self showAlertWithTitle:@"downloadErrorKey".localized message:@"smtWentWrongKey".localized];
            return;
        }
    }];
    return downloadTask;
}

//-(void)downloadVideoWithExerciseName:(NSString *)exerciseName{
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfiguration];
//    
//    NSString *exerciseUrlString = [exerciseName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//    NSURL *URL = [NSURL URLWithString:BaseURL(exerciseUrlString)];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    
//    __block NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
//        if (totalExercises == 1) {
//            float percents = (float)downloadProgress.completedUnitCount/(float)downloadProgress.totalUnitCount;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [progressView setProgress:percents];
//                [percentageLabel setText:[NSString stringWithFormat:@"%.f%%", percents*100]];
//            });
//        }
//    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        NSFileManager *manager = [NSFileManager defaultManager];
//        NSURL *documentsDirectoryURL = [manager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//        NSString *videosPath = [documentsDirectoryURL.path stringByAppendingPathComponent:@"videos"];
//        [manager createDirectoryAtPath:videosPath withIntermediateDirectories:false attributes:nil error:nil];
//        return [NSURL fileURLWithPath:[videosPath stringByAppendingPathComponent:exerciseName]];
//    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//        if (!error) {
//            NSLog(@"File downloaded to: %@", filePath);
//            downloadedExercises++;
//            
//            if (totalExercises > 1) {
//                [downloadingStateLabel setText:[NSString stringWithFormat:@"%@ %ld / %ld",@"Downloading videos".localized, downloadedExercises, totalExercises]];
//                [progressView setProgress:(float)downloadedExercises/(float)totalExercises];
//                
//                NSInteger percents = (float)downloadedExercises/(float)totalExercises*100;
//                [percentageLabel setText:[NSString stringWithFormat:@"%ld%%", percents]];
//                [downloadTasksArray removeObject:downloadTask];
//                
//                if (downloadedExercises == totalExercises) {
//                    [self dismissController];
//                    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishDownloadingWithPath:)]) {
//                        [self.delegate didFinishDownloadingWithPath:nil];
//                    }
//                }
//            }else{
//                [self dismissController];
//                if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishDownloadingWithPath:)]) {
//                    [self.delegate didFinishDownloadingWithPath:filePath.path];
//                }
//            }
//        }else{
//            if (totalExercises == 1) {
//                
//            }
//        }
//    }];
//    if (!downloadTasksArray) {
//        downloadTasksArray = [NSMutableArray array];
//    }
//    [downloadTasksArray addObject:downloadTask];
//    [downloadTask resume];
//}

- (IBAction)cancelButtonAction:(id)sender {
    for (NSURLSessionDownloadTask *task in downloadTasksArray) {
        [task cancel];
    }
    [self dismissController];
}

-(void)dismissController{
    [self.view removeFromSuperview];
}

- (BOOL)internetIsConnected {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

-(void)showAlertWithTitle:(NSString *)title message:(NSString *)message{
    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }else{
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:title
                                     message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okButton = [UIAlertAction
                                   actionWithTitle:@"OK".localized
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self dismissController];
                                   }];
        
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self dismissController];
}
@end
