#import "CustomMoviePlayer.h"
#import "GuideAppDelegate.h"

@interface CustomMoviePlayer ()< UIGestureRecognizerDelegate>{
    UIView *navigationView;
    UIView *helpView;
    UIButton* changeSizeButton;
}

@end

@implementation CustomMoviePlayer


#pragma mark - Initialization


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewInitialization];
    
    NSLog(@"%@", [UIApplication sharedApplication].keyWindow.rootViewController);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"%@", [UIApplication sharedApplication].keyWindow.rootViewController);
    });
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    changeSizeButton.hidden = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self playVideo:[NSURL fileURLWithPath:_videoPath]];
}


-(void)viewInitialization{
    [self beginGeneratingDeviceOrientation];
    helpView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [helpView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:helpView];
    [self setTapGesture];

    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    self.moviePlayer.repeatMode = MPMovieRepeatModeOne;
}


-(void)playVideo:(NSURL*)movieURL{
    [self.moviePlayer setContentURL:movieURL];
    self.moviePlayer.view.frame = CGRectMake(-2, -2, [UIScreen mainScreen].bounds.size.width+4, [UIScreen mainScreen].bounds.size.height+4);
    [self.moviePlayer prepareToPlay];
    if ([self canRotate]) {
        [(GuideAppDelegate*)[[UIApplication sharedApplication] delegate] setShouldRotateVideo:YES];
        self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    }
    
    [self setNavigation];
}

#pragma mark - Gestures


-(void)setTapGesture{
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPlayerTapped:)];
    singleFingerTap.numberOfTapsRequired = 1;
    singleFingerTap.delegate = self;
    [self.view addGestureRecognizer:singleFingerTap];
}


-(void) onPlayerTapped:(UIGestureRecognizer *)gestureRecognizer {
    [UIView animateWithDuration:.5 animations:^{
        [navigationView setAlpha:!navigationView.alpha];
    }];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}


#pragma mark - Navigation


-(void)setNavigation{
    CGFloat navigationHeight = 64.0;
//    if (@available(iOS 11.0, *)) {
//        navigationHeight = 44.0;
//        GuideAppDelegate *appDelegate = (GuideAppDelegate *)[UIApplication sharedApplication].delegate;
//        if (appDelegate.window.safeAreaInsets.top > 0.0) {
//            navigationHeight = 88.0;
//        }
//    }
    
    navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, navigationHeight)];
    [navigationView setBackgroundColor:RED_COLOR];
//    [navigationView setTranslucent:false];

    UIButton* doneButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 70, navigationHeight)];
    [doneButton setTitle:@"doneKey".localized forState:UIControlStateNormal];
    [doneButton setBebasFontWithType:Regular size:17];
    doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [doneButton setBebasFontWithType:Bold size:24];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [doneButton addTarget:self action:@selector(doneButton) forControlEvents:UIControlEventTouchUpInside];
    [doneButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [doneButton addTarget:self action:@selector(buttonHighlightCancel:) forControlEvents:UIControlEventTouchDragExit];
    
    [navigationView addSubview:doneButton];
    
    if([self canRotate]){
        changeSizeButton = [[UIButton alloc] initWithFrame:CGRectMake(navigationView.frame.size.width - navigationHeight, 0, navigationHeight, navigationHeight)];
        UIImage *image = [[UIImage imageNamed:@"cropIn.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [changeSizeButton setTintColor:[UIColor whiteColor]];
        [changeSizeButton setImage:image forState:UIControlStateNormal];
        [changeSizeButton setImage:image forState:UIControlStateHighlighted];
        [changeSizeButton addTarget:self action:@selector(changeVideoAspectMode:) forControlEvents:UIControlEventTouchDown];
        [changeSizeButton addTarget:self action:@selector(changeSizeButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [changeSizeButton addTarget:self action:@selector(changeSizeButtonTouchCancel:) forControlEvents:UIControlEventTouchDragExit];
        changeSizeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        
        [navigationView addSubview:changeSizeButton];
    }
    
    [self.moviePlayer.view addSubview:navigationView];
}

- (IBAction)changeSizeButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)changeSizeButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}

- (void)buttonHighlight:(UIButton *)sender{
    [sender setTitleColor:RGBA(255, 255, 255, .4) forState:UIControlStateNormal];
    [sender setTitleColor:RGBA(255, 255, 255, .4) forState:UIControlStateHighlighted];
}

- (void)buttonHighlightCancel:(UIButton *)sender{
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

#pragma mark - Orientation


-(BOOL)canRotate{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.moviePlayer.contentURL options:nil];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if(!tracks.count){
        return NO;
    }
    AVAssetTrack *track = [tracks objectAtIndex:0];
    CGSize mediaSize = track.naturalSize;
    if (mediaSize.height<mediaSize.width) {
        return YES;
    }
    return NO;
}


- (void)beginGeneratingDeviceOrientation{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}


-(void) orientationChanged{
    CGFloat navigationHeight = 64.0;
//    if (@available(iOS 11.0, *)) {
//        navigationHeight = 44.0;
//        GuideAppDelegate *appDelegate = (GuideAppDelegate *)[UIApplication sharedApplication].delegate;
//        if (appDelegate.window.safeAreaInsets.top > 0.0) {
//            navigationHeight = 88.0;
//        }
//    }
    
    [helpView setFrame:[UIScreen mainScreen].bounds];
    [navigationView setFrame:CGRectMake(0, 0, self.view.frame.size.width, navigationHeight)];
    changeSizeButton.hidden = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;
    
//    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
//        [helpView setFrame:[UIScreen mainScreen].bounds];
////        [helpView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//        [navigationView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
//        changeSizeButton.hidden = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;
//    }else{
//        CGRect newDeviceBounds = [UIScreen mainScreen].bounds;
//        newDeviceBounds.size.width = newDeviceBounds.size.height;
//        newDeviceBounds.size.height = [UIScreen mainScreen].bounds.size.width;
////        [helpView setFrame:newDeviceBounds];
//        [helpView setFrame:[UIScreen mainScreen].bounds];
//        [navigationView setFrame:CGRectMake(0, 0, newDeviceBounds.size.width, 64)];
//        changeSizeButton.hidden = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;
//    }
}


#pragma mark - IBActions


-(IBAction)changeVideoAspectMode:(UIButton*)sender{
    [sender setImage:self.moviePlayer.scalingMode == MPMovieScalingModeAspectFit ? [UIImage imageNamed:@"cropOut.png"] : [UIImage imageNamed:@"cropIn.png"] forState:UIControlStateNormal];
    self.moviePlayer.scalingMode = self.moviePlayer.scalingMode == MPMovieScalingModeAspectFit  ?  MPMovieScalingModeAspectFill : MPMovieScalingModeAspectFit;
}


-(void)doneButton{
    [(GuideAppDelegate*)[[UIApplication sharedApplication] delegate] setShouldRotateVideo:NO];
    [self playerRemoved];
    [self dismissViewControllerAnimated:NO completion:^{
        [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    }];
}


#pragma mark - Self delegates


-(void)playerRemoved{
    if(_delegate && [_delegate respondsToSelector:@selector(playerRemoved)]){
        [_delegate playerRemoved];
    }
}


-(void)dealloc{

}

@end
