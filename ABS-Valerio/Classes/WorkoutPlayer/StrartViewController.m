#import "StrartViewController.h"
#import "TimerViewController.h"
#import "GuideAppDelegate.h"
#import "ExercisesProgressContainerViewController.h"
#import "PlayerExerciseTableViewCell.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

#define SONGS_NAME_DICTIONARY @{@"restClock" : @"clock_pips_2.1_sek" ,  @"restBegin" : @"FitnessExerciseDoneSound", @"restBeginVoice":@"Exercise Vocals D",@"supersetDone": @"Exercise Vocals E", @"321GO":@"Exercise Vocals A2"}

typedef NS_ENUM(NSInteger, SpeechOrder){
    ExerciseName,
    ExerciseTime,
    SupersetDone,
    PrepareCountdown
};


@interface StrartViewController () <AVAudioPlayerDelegate, TimerViewControllerDelegate , UITableViewDelegate, UITableViewDataSource, CircleTimerDelegate, AVSpeechSynthesizerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property(nonatomic) SpeechOrder speechOrder;

@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *restSkipButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
@property (strong, nonatomic) TimerViewController* timerHandlerController;

@property (strong, nonatomic) ExercisesProgressContainerViewController* exercisesProgressContainer;

@property (strong, nonatomic) AVAudioPlayer *soundPlayer;
@property (strong, nonatomic) MPMoviePlayerController *videoPlayer;


@property (weak, nonatomic) IBOutlet UIButton *nextCollectionButton;
@property (weak, nonatomic) IBOutlet UIView *landscapeExercisesComponentsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landscapeComponentsViewWeidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landscapeComponentsViewHeightConstraint;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoPlayerTopConstraint;

@property (weak, nonatomic) IBOutlet UITableView *exercisesTableView;


@property (weak, nonatomic) IBOutlet UIView *previewComponentsView;
@property (weak, nonatomic) IBOutlet UILabel *exerciseNameLabel;
@property (weak, nonatomic) IBOutlet CircleTimer *prepareProgressCircle;
@property (weak, nonatomic) IBOutlet UILabel *startCounterLabel;
@property (strong,nonatomic) NSArray* countingArray;
@property (nonatomic) int currentCounterIndex;


@property (weak, nonatomic) IBOutlet UIView *restView;
@property (weak, nonatomic) IBOutlet UILabel *restInfoLabel;
@property (weak, nonatomic) IBOutlet UIView *clockComponentsView;
@property (weak, nonatomic) IBOutlet UIImageView *clockArrowImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *botomRestViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftRestViewConstraint;

@property (weak, nonatomic) IBOutlet UIButton *soundStateButton;

@property (weak, nonatomic) IBOutlet UITableView *playlistTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playlistTopConstraint;

@property (weak, nonatomic) IBOutlet UIButton *playlistButton;
@property (weak, nonatomic) IBOutlet UIView *mainConteiner;

@end


@implementation StrartViewController{
    __weak IBOutlet UILabel *exerciseTimeLabel;
    AVSpeechSynthesizer *synth;
    UIView *helpView;
    BOOL videoWasPaused;
    
    __weak IBOutlet UILabel *restTimeSecondsLabel;
    __weak IBOutlet UILabel *restTimeNextExerciseNameLabel;
    __weak IBOutlet UILabel *restTimeNextExerciseLabel;
    __weak IBOutlet UILabel *restTimeNextExerciseSecondsLabel;
    __weak IBOutlet UIButton *skipButton;
    __weak IBOutlet UILabel *restTimeTitlelabel;
    __weak IBOutlet UILabel *workoutDoneLabel;
    __weak IBOutlet UIView *workoutDoneView;
    __weak IBOutlet UILabel *workoutDonekcalLabel;
    __weak IBOutlet UIView *blurView;
    __weak IBOutlet UIView *playlistTopView;
    __weak IBOutlet NSLayoutConstraint *bottomContenerConstraint;
}

//NSString* currentSongName;
NSString* exerciseName;
int totalRounds;
int headerHeight;

BOOL restTime, restTimeBetwenExercise;
int workoutTimeInSeconds;

float lastGestureCoordinate;


- (void)viewDidLoad{
    [super viewDidLoad];
    [_mainConteiner addToSafeArea];

    if (@available(iOS 11.0, *)) {
        GuideAppDelegate *appDelegate = (GuideAppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.window.safeAreaInsets.top > 0.0) {

        } else {
            bottomContenerConstraint.constant = 0;
        }
    } else {
        bottomContenerConstraint.constant = 0;
    }
    
    synth = [[AVSpeechSynthesizer alloc] init];
    totalRounds = [self getRoundsNumber];
    [self initMoviePlayer];
    headerHeight = 40;
    [_exercisesTableView registerNib:[UINib nibWithNibName:@"PlayerExerciseTableViewCell" bundle:nil] forCellReuseIdentifier:@"PlayerExerciseTableViewCell"];
    [_playlistTableView registerNib:[UINib nibWithNibName:@"PlayerExerciseTableViewCell" bundle:nil] forCellReuseIdentifier:@"PlayerExerciseTableViewCell"];
    
    [self showNextExercise];
    [self initProgressCircles];
    [self calculateCurrentTotalTime:0];

    [self setTitle:@"previewKey".localized];
    
    if (isIpad) {
        [self.navigationController.navigationBar setBebasFontWithSize:50];
    }else{
        if (self.title.length > 7) {
            float fontSize = 7 * 45 / self.title.length;
            [self.navigationController.navigationBar setBebasFontWithSize:fontSize positionAdjustment:0];
        }else{
            [self.navigationController.navigationBar setBebasFontWithSize:45];
        }
    }
    
    [self changeButtonImage:[Utilities getBOOLFromUserDefaults:MUTE_STATE_KEY]];
    
    [_restInfoLabel setText:_restInfoLabel.text.uppercaseString];
    [_restInfoLabel setBebasFontWithType:Regular size:20];
    
    [self setRestTimeFonts];
    
    if (_kcalories == 0) {_kcalories = 100;}
    [workoutDonekcalLabel setText:[NSString stringWithFormat:@"%ld %@", _kcalories, @"kcalKEY".localized]];
    
    UIImage *image = [UIImage imageNamed:@"skip"];
    UIImage *templateImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [skipButton setTintColor:RED_COLOR];
    [skipButton setBackgroundImage:templateImage forState:UIControlStateNormal];
    
    [blurView setBackgroundColor:[UIColor clearColor]];

    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:blurView.bounds];
        [toolbar setBarStyle:UIBarStyleBlack];
        [toolbar setTranslucent:true];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [blurView addSubview:toolbar];
    }else{
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = blurView.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [blurView addSubview:blurEffectView];
    }
}

-(void)setRestTimeFonts{
    [restTimeTitlelabel setBebasFontWithType:Regular size:30];
    [restTimeSecondsLabel setBebasFontWithType:Regular size:300];
    [restTimeNextExerciseNameLabel setBebasFontWithType:Regular size:35];
    [restTimeNextExerciseLabel setBebasFontWithType:Regular size:30];
    [restTimeNextExerciseLabel setText:[restTimeNextExerciseLabel.text stringByAppendingString:@":"]];
    [restTimeNextExerciseSecondsLabel setBebasFontWithType:Regular size:25];
    [skipButton setBebasFontWithType:Regular size:18];
}

-(void)setCurrentRoundAndIndex:(int)currentVideoIndex withRemainedRound:(int)remainedRound{
    if(currentVideoIndex == 0 && remainedRound == 0){
        NSLog(@"Empty START");
        _remainedRounds = totalRounds = [self getRoundsNumber];
        _currentVideoIndex = 0;
    }else{
        NSLog(@"NOt Empty  START");
        _remainedRounds = remainedRound;
        _currentVideoIndex = currentVideoIndex;
    }
    
}


-(void)initLandscapePlayerControls{
    [_timerHandlerController.landscapePlayerControlsView setAlpha:0];
    helpView = [[UIView alloc] initWithFrame:_videoPlayer.view.frame];
    [_videoPlayer.view addSubview:helpView];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePlayerControls:)];
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePlayerControls:)];
    [tapGestureRecognizer setDelegate:self];
    [helpView addGestureRecognizer:tapGestureRecognizer];
    [_timerHandlerController.view addGestureRecognizer:tapGestureRecognizer2];
    
    [_timerHandlerController.previousButton setEnabled:_currentVideoIndex != 0];
    [_timerHandlerController.nextButton setEnabled:_currentVideoIndex != _exerciseArray.count-1];
}

-(void)hidePlayerControls:(UITapGestureRecognizer *)gestureRecognizer{
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        [UIView animateWithDuration:.5 animations:^{
            [_timerHandlerController.landscapePlayerControlsView setAlpha:!_timerHandlerController.landscapePlayerControlsView.alpha];
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _nextCollectionButton.hidden = YES;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self changeScreenOrientation:[[UIDevice currentDevice] orientation] rotationState:YES];
    _landscapeComponentsViewHeightConstraint.constant = self.view.frame.size.width - _timerHandlerController.view.frame.size.height + _timerHandlerController.landscapeComponentsView.frame.origin.y;
    _landscapeComponentsViewWeidthConstraint.constant = _timerHandlerController.landscapeComponentsView.frame.size.width;
    [_exercisesProgressContainer scrollCollectionView:_currentVideoIndex withRound: totalRounds - _remainedRounds animated:true];
}

#pragma mark - Geters


-(int)getRoundsNumber{
    return _isPredefined ? (int)[_repsArray count] : (int)[[[(Eercise*)[_exerciseArray objectAtIndex:_currentVideoIndex] reps]allObjects]count];
}


-(int)getExerciseLenght:(int)currentIndex withCurrentRound:(int)currentRound{
    if(_isPredefined){
        return (int)([[_repsArray firstObject] doubleValue] * 2);
    }else{
        NSArray* repetitionsArray = [[(Eercise*)[_exerciseArray objectAtIndex:currentIndex] reps] allObjects];
        for(Repetitions* currentRepetition in repetitionsArray){
            if([currentRepetition.sort intValue] == currentRound){
                return (int)([[currentRepetition repetitions] doubleValue] * 2);
            }
        }
        return 20;
    }
}


-(NSString*)getExerciseImagePath:(int)index{
    if(_isPredefined){
        return _exerciseArray[index][0][@"infopath.plist"];
    }else{
        NSString* path;
        if ([[[_exerciseArray objectAtIndex:index] isCustom] boolValue]) {
            NSArray *comps = [[self getPhotoForExercise:[_exerciseArray objectAtIndex:index]]pathComponents];
            if ([comps containsObject:@"Library"]) {
                NSLog(@"1 - %@", [comps objectAtIndex:5]);
                path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-2]];
                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-1]];
            }
        }else{
            NSFileManager *manager = [NSFileManager defaultManager];
            NSError* error;
            NSArray* foldersNameArray = [[(Eercise*)[_exerciseArray objectAtIndex:index] link] componentsSeparatedByString:@".app"];
            NSString* exercisePath = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],[foldersNameArray lastObject]];
            NSArray *fileList =[manager contentsOfDirectoryAtPath:exercisePath error:&error];
            path = [exercisePath stringByAppendingPathComponent:[fileList objectAtIndex:1]];
        }
        return path;
    }
}


#pragma mark - Start Superset Methods


-(void)setTimerHandlerControllerValues:(BOOL)restTime{
    int remainingExerciseTime = [self getExerciseLenght:_currentVideoIndex withCurrentRound:totalRounds - _remainedRounds];
    [restTimeNextExerciseSecondsLabel setText:[NSString stringWithFormat:@"%d %@", remainingExerciseTime, @"secondsKey".localized]];
    _timerHandlerController.remainingExerciseTime = remainingExerciseTime;
    [_timerHandlerController setExerciseTimer:restTime];
}




#pragma mark - Set Exercise Total Time


-(void)calculateCurrentTotalTime:(float)updateTime{
    workoutTimeInSeconds = [self getTotalWorkoutTime] - updateTime;
    [self setTotalWorkoutTime];
    
}


-(int)getTotalWorkoutTime{
    if(_isPredefined){
        return [self getExerciseLenght:_currentVideoIndex withCurrentRound:totalRounds - _remainedRounds] * (_remainedRounds * (int)[_exerciseArray count] - _currentVideoIndex);
    }else{
        int exercisesLenght = 0 ;
        for(int i = 0 ; i < _exerciseArray.count ; i++){
            NSArray* repetitionsArray = [[(Eercise*)[_exerciseArray objectAtIndex:i] reps]allObjects];
            for (int k = [self getRoundsNumber] - _remainedRounds + 1; k < [repetitionsArray count]; k++) {
                for (Repetitions* currentRepetition in repetitionsArray){
                    if([currentRepetition.sort intValue] == k){
                        exercisesLenght += [[currentRepetition repetitions] intValue] * 2;
                        break;
                    }
                }
            }
        }
        
        for(int i = _currentVideoIndex ; i < _exerciseArray.count ; i++){
            NSArray* repetitionsArray = [[(Eercise*)[_exerciseArray objectAtIndex:i] reps]allObjects];
            for (Repetitions* currentRepetition in repetitionsArray){
                if([currentRepetition.sort intValue] == [self getRoundsNumber] - _remainedRounds){
                    exercisesLenght += [[currentRepetition repetitions] intValue] * 2;
                    break;
                }
            }
        }
        
        return exercisesLenght;
    }
}


-(void)setTotalWorkoutTime{
    int seconds = workoutTimeInSeconds % 60;
    int minutes = (workoutTimeInSeconds / 60) % 60;
    _totalTimeLabel.text = [NSString stringWithFormat:@"%.2d:%.2d",minutes, seconds];
    [self setTitle:[NSString stringWithFormat:@"%.2d:%.2d",minutes, seconds]];
//    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:-2 forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setBebasFontWithSize:55];
//    [_totalTimeLabel setBebasFontWithType:Bold size:50];
}


-(NSString*)getExerciseName:(int)index{
    NSString *title;
    if(_isPredefined){
        title = [NSString stringWithFormat:@"%@", [[[[[_exerciseArray objectAtIndex:index] objectAtIndex:0]objectForKey:@"infopath.plist"] stringByDeletingLastPathComponent]lastPathComponent]];
        return title.localized;
    }else{
//        NSLog(@"%@",[[_exerciseArray objectAtIndex:index] title]);
        title = [[_exerciseArray objectAtIndex:index] title];
        return title.localized;
    }
}


#pragma mark - Uitable Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return totalRounds;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _exerciseArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PlayerExerciseTableViewCell* exerciseCell = [tableView dequeueReusableCellWithIdentifier:@"PlayerExerciseTableViewCell" forIndexPath:indexPath];
    int exerciseTime = [self getExerciseLenght:(int)indexPath.row withCurrentRound:(int)indexPath.section];
    [exerciseCell setExerciseInformation:[self getExerciseName:(int)indexPath.row] exercisePhoto:[self getExerciseImagePath:(int)indexPath.row] withTime:[NSString stringWithFormat:@"%d %@", exerciseTime, @"secondsKey".localized] isCustom:_isPredefined ? NO : [[[_exerciseArray objectAtIndex:indexPath.row] isCustom] boolValue]];
    return exerciseCell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerExerciseTableViewCell* exerciseCell = (PlayerExerciseTableViewCell*)cell;
    exerciseCell.selectedCell = _currentVideoIndex == indexPath.row && totalRounds - _remainedRounds == indexPath.section;
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentVideoIndex inSection:_repsArray.count - _remainedRounds];
    
    if(_currentVideoIndex == indexPath.row && totalRounds - _remainedRounds == indexPath.section){
        [exerciseCell setCurrentSelected:YES withFilter:NO];
        [_exercisesTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:true];
    }else{
        [exerciseCell setCurrentSelected:NO withFilter:NO];
    }
}


#pragma mark - UITable View Delegate


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return isIpad ? 120 : 90;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(totalRounds == 1){
        return 0;
    }
    return headerHeight;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _exercisesTableView.frame.size.width, headerHeight)];
    headerView.backgroundColor = [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1];
    UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, _exercisesTableView.frame.size.width - 20, headerHeight)];
    headerLabel.text = [NSString stringWithFormat:@"%@ %ld", @"roundKey".localized, (long)section + 1];
    [headerLabel setBebasFontWithType:Regular size:isIpad? 21 : 18];
    headerLabel.textColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:headerLabel];
    return headerView;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _remainedRounds = totalRounds - (int)indexPath.section;
    _currentVideoIndex = (int)indexPath.row;
    [_exercisesProgressContainer scrollCollectionView:_currentVideoIndex withRound: totalRounds - _remainedRounds animated:true];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.view.layer removeAllAnimations];
    [_timerHandlerController deallocTimer];
    
    [self showNextExercise];
    [self calculateCurrentTotalTime:0];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tableView == _playlistTableView){
        [self showHidePlaylist:self.view.frame.size.height animated:true];
        [self stopAllProgress:NO];
    }
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:true];
}


#pragma mark - Sound Handler


-(void)playSound:(NSDictionary*)songInformationDictionary{
    if(![Utilities getBOOLFromUserDefaults:MUTE_STATE_KEY]){
        [_soundPlayer stop];
        if(![songInformationDictionary[@"soundName"] isEqualToString:@"no_sound"]){
            NSURL* path2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:songInformationDictionary[@"soundName"] ofType:@"mp3"]];
            _soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:path2 error:nil];
            [_soundPlayer setDelegate: self];
//            [_soundPlayer prepareToPlay];
            [_soundPlayer setNumberOfLoops:[songInformationDictionary[@"loops"] intValue]];
            [_soundPlayer play];
        }
    }
}

-(void)playWawSoundWithName:(NSString *)soundName{
    if(![Utilities getBOOLFromUserDefaults:MUTE_STATE_KEY]){
        NSString *path = [[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"];
        NSURL *url = [NSURL fileURLWithPath: path];
        NSError *error;
        _soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [_soundPlayer setDelegate: self];
        [_soundPlayer prepareToPlay];
        [_soundPlayer play];
    }
}


#pragma mark - AVAudioPlayer delegate


-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if(restTime){
        [self playSound:@{@"soundName":SONGS_NAME_DICTIONARY[@"restClock"],@"loops":@-1}];
    }
}


#pragma mark - Video Handler


-(void)initMoviePlayer{
    _videoPlayer = [[MPMoviePlayerController alloc] init];
    _videoPlayer.view.backgroundColor = [UIColor whiteColor];
    _videoPlayer.backgroundView.backgroundColor = [UIColor whiteColor];
    _videoPlayer.controlStyle = MPMovieControlStyleNone;
    _videoPlayer.movieSourceType = MPMovieSourceTypeFile;
    _videoPlayer.scalingMode = MPMovieScalingModeAspectFill;
    _videoPlayer.repeatMode = MPMovieRepeatModeOne;
    [_videoPlayerView addSubview:_videoPlayer.view];
}


-(void)playVideo{
    [_playlistTableView reloadData];
    [_exercisesTableView reloadData];
    NSString* exercisePath;
    
    if(_isPredefined){
        exercisePath = [_exerciseArray[_currentVideoIndex] firstObject][@"infopath.plist"];
    }else{
        if ([[[_exerciseArray objectAtIndex:_currentVideoIndex] isCustom] boolValue]) {
            [self setCustomImage];
            _videoPlayer.view.hidden = YES;
            return;
        }else{
            _videoPlayer.view.hidden = NO;
            exercisePath = [self getExercisePathFromCoreData];
        }
    }
    exerciseName = [[exercisePath stringByDeletingLastPathComponent] lastPathComponent];
    
    NSString* videoPath = [[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"VIDEOS"] stringByAppendingPathComponent:exerciseName] stringByAppendingPathExtension:@"mp4"];
    BOOL videoExist = [[NSFileManager defaultManager] fileExistsAtPath:videoPath];
    if(videoExist){
        [self startVideo:videoPath];
    }else{
        NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        videoPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"videos/%@.mp4", exerciseName]];

        BOOL videoExist = [[NSFileManager defaultManager] fileExistsAtPath:videoPath];
        if (videoExist) {
            [self startVideo:videoPath];
        }
//        _exerciseImageView.image = [_exercisePhotosArray count] ? [UIImage imageWithContentsOfFile:[_exercisePhotosArray objectAtIndex:currentVideoIndex]] : [UIImage imageNamed:@"no-photo"];[[bundlePath stringByAppendingPathComponent:[contentDict objectForKey:@"infopath"]] stringByAppendingPathComponent:[plistFileContent objectAtIndex:1]]
    }
    _exerciseImageView.hidden = videoExist;
}


-(void)startVideo:(NSString*)videoPath{
    CGRect frame = _videoPlayerView.bounds;
    frame.size.height += 4;
    frame.origin.y -= 2;
    _videoPlayer.view.frame = frame;
    [_videoPlayerView setClipsToBounds:true];
    [self initLandscapePlayerControls];
    _videoPlayer.contentURL = [NSURL fileURLWithPath:videoPath];
    [_videoPlayer prepareToPlay];
    [_videoPlayer play];
    _exerciseImageView.image = nil;
}


#pragma mark - Custom Superset Methods


-(NSString*)getExercisePathFromCoreData{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray* foldersNameArray = [[(Eercise*)[_exerciseArray objectAtIndex:_currentVideoIndex] link] componentsSeparatedByString:@".app"];
    NSString* exerciseFolderPath = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],[foldersNameArray lastObject]];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:exerciseFolderPath error:nil];
    NSString* path = [exerciseFolderPath stringByAppendingPathComponent:[fileList objectAtIndex:1]];
    return path;
}


-(void)setCustomImage{
    [self initLandscapePlayerControls];
    [_videoPlayer pause];
    _exerciseImageView.hidden = NO;
    _exerciseImageView.image = [UIImage imageWithContentsOfFile:[self getCustomImagePath]];
}


-(NSString*)getCustomImagePath{
    NSString *path;
    NSArray *comps = [[self getPhotoForExercise:[_exerciseArray objectAtIndex:_currentVideoIndex]]pathComponents];
    if ([comps containsObject:@"Library"]) {
        path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-2]];
        path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-1]];
    }
    return path;
}

#pragma mark - Core Data get Values


-(NSString*)getPhotoForExercise:(Eercise*)exercise{
    NSMutableArray *dataArray = [NSMutableArray array];
    for (int k = 0; k < [[exercise.photos allObjects] count]; k++) {
        [dataArray addObject:[[exercise.photos allObjects] objectAtIndex:k]];
    }
    NSArray *sortedArray = [NSArray arrayWithArray:[self sortArray:dataArray]];
    return  [[sortedArray objectAtIndex:0] photoLink];
}


-(NSArray *)sortArray: (NSArray *)array{
    NSArray *sortedArray = [array sortedArrayUsingComparator: ^(id obj1, id obj2) {
        if ([[obj1 sort] integerValue] > [[obj2 sort] integerValue]){
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([[obj1 sort] integerValue] < [[obj2 sort] integerValue]){
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return sortedArray;
}





#pragma mark - Timer Counter Segue


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"timerSegue"]) {
        _timerHandlerController = segue.destinationViewController;
        _timerHandlerController.delegate = self;
    }else if([[segue identifier] isEqualToString:@"ExerciseContainerSegue"]){
        _exercisesProgressContainer = segue.destinationViewController;
        NSMutableArray* currentArray = [NSMutableArray new];
        for(int i =0 ; i <= _exerciseArray.count ; i++){
            if(i == _exerciseArray.count){
                [currentArray addObject:@{@"exerciseName":@"",@"imagePath":@""}];
            }else{
                [currentArray addObject:@{@"exerciseName":[self getExerciseName:i],@"imagePath":[self getExerciseImagePath:i]}];
            }
        }
        _exercisesProgressContainer.numberOfCirles = [self getRoundsNumber];
        _exercisesProgressContainer.exercisesArray = [currentArray copy];
    }
}



#pragma mark - IBActions
#pragma mark - Audio Actions


- (IBAction)nextButtonAction:(id)sender {
    [_timerHandlerController nextButtonAction:nil];
}


- (IBAction)showPlaylistButtonAction:(id)sender {
    [sender setTintColor:[UIColor whiteColor]];
    [self showHidePlaylist:_playlistTopConstraint.constant == 0 ? self.view.frame.size.height : 0 animated:true];
    [self stopAllProgress: _playlistTopConstraint.constant == 0 ? YES : NO];
}


- (IBAction)changeSoundState:(id)sender {
    BOOL muteState = ![Utilities getBOOLFromUserDefaults:MUTE_STATE_KEY];
    [Utilities saveBOOLToUserDefaults:muteState withKey:MUTE_STATE_KEY];
    [self changeButtonImage:muteState];
}



-(void)changeButtonImage:(BOOL)muteState{
    [_soundStateButton setImage:[UIImage imageNamed:muteState ? @"MusicMute" : @"MusicunMute"] forState:UIControlStateNormal];
}

#pragma mark - Palylist


-(void)showHidePlaylist:(float)value animated:(BOOL)animated{
    lastGestureCoordinate = 0;
    _playlistTopConstraint.constant = value ;
    [UIView animateWithDuration:animated ? .5 : 0 animations:^{
        [self.view layoutIfNeeded];
    }];
    videoWasPaused = _playlistTopConstraint.constant == 0;
//    if (!_timerHandlerController.isPaused) {
//        _timerHandlerController.isPaused = _playlistTopConstraint.constant == 0;
//    }
    //
    //
    //    [self stopAllProgress:value == 0 ? YES : NO];
}


-(void)stopAllProgress:(BOOL)stopValue{
    if(stopValue){
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self.view.layer removeAllAnimations];
        [_videoPlayer pause];
        [_timerHandlerController stopCircularPorgress];
    }else{
        if (!_timerHandlerController.isManualPaused) {
            [_videoPlayer play];
            [_timerHandlerController resumeCircularProgress];
        }
    }
    _timerHandlerController.isPaused = stopValue;
}


- (IBAction)playlistButtonTouchDown:(UIButton *)sender {
    [playlistTopView setBackgroundColor:RGBA(233, 233, 233, 1)];
}

- (IBAction)playlistButtonTouchCancel:(UIButton *)sender {
    [playlistTopView setBackgroundColor:[UIColor whiteColor]];
}


- (IBAction)playlistDragGestureAction:(UIPanGestureRecognizer*)recognizer {
    [playlistTopView setBackgroundColor:RGBA(233, 233, 233, 1)];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [playlistTopView setBackgroundColor:[UIColor whiteColor]];
    }
    
    UIGestureRecognizerState state = recognizer.state;
    if( state == UIGestureRecognizerStateChanged){
        CGPoint translation = [recognizer translationInView:self.view];
        float changePosittionValue = translation.y - lastGestureCoordinate;
        NSLog(@"changePosittionValuechangePosittionValue %f",changePosittionValue);
        _playlistTopConstraint.constant = _playlistTopConstraint.constant + changePosittionValue;
        [self.view layoutIfNeeded];
        if (_playlistTopConstraint.constant < 0){
            _playlistTopConstraint.constant = 0;
        }else if(_playlistTopConstraint.constant > self.view.frame.size.height){
            _playlistTopConstraint.constant = self.view.frame.size.height;
        }
        lastGestureCoordinate = translation.y;
    }else if ( state == UIGestureRecognizerStateEnded ) {
        if(_playlistTopConstraint.constant < 50){
            [self showHidePlaylist:0 animated:true];
            [self stopAllProgress:YES];
        }else{
            [self showHidePlaylist:self.view.frame.size.height animated:true];
            [self stopAllProgress:NO];
        }
    }
}


#pragma mark - Navigation


-(IBAction)backButtonAction:(id)sender{
    [sender setTintColor:[UIColor whiteColor]];
    if (!workoutDoneView.isHidden) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.exerciseImageView removeFromSuperview];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        NSString *alertMessage = @"Do you want to stop the workout?".localized;
        NSString *alertTitle = @"Confirm".localized;
        
        if (SYSTEM_VERSION_LESS_THAN(@"8")) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:@"cancelKey".localized otherButtonTitles:@"Yes".localized, nil];
            [alertView show];
        }else{
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:alertTitle
                                         message:alertMessage
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:@"Yes".localized
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           [[NSNotificationCenter defaultCenter] removeObserver:self];
                                           [self.exerciseImageView removeFromSuperview];
                                           [self.navigationController popViewControllerAnimated:YES];
                                       }];
            
            UIAlertAction* cancelButton = [UIAlertAction
                                           actionWithTitle:@"cancelKey".localized
                                           style:UIAlertActionStyleDefault
                                           handler:nil];
            
            [alert addAction:cancelButton];
            [alert addAction:okButton];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.exerciseImageView removeFromSuperview];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - TimerHandlerClass Delegate


-(void)currentTimeUpdated:(float)currentTime withTotalTime:(float)totalTime{
    if(restTime){
        if (@available(iOS 11.0, *)) {
            GuideAppDelegate *appDelegate = (GuideAppDelegate *)[UIApplication sharedApplication].delegate;
            NSArray<NSNumber *> *safeArreaInsets = @[@(appDelegate.window.safeAreaInsets.top), @(appDelegate.window.safeAreaInsets.bottom), @(appDelegate.window.safeAreaInsets.left), @(appDelegate.window.safeAreaInsets.right)];
            NSNumber *maxNumber = [safeArreaInsets valueForKeyPath:@"@max.self"];
            
            if (maxNumber.floatValue > 0) {
                _restSkipButtonBottomConstraint.constant = maxNumber.floatValue + 8;
            } else {
                _restSkipButtonBottomConstraint.constant = 8;
            }
        } else {
            _restSkipButtonBottomConstraint.constant = 8;
        }
        [restTimeSecondsLabel setText:[NSString stringWithFormat:@"%ld", (NSInteger)totalTime - (NSInteger)currentTime]];
//        float degrees = 180 * currentTime / 30;
//        _clockArrowImageView.transform = CGAffineTransformMakeRotation(degrees * M_PI/180);
    }else{
        [self calculateCurrentTotalTime:currentTime];
        [_exercisesProgressContainer updateCurrentExerciseProgressView:currentTime withTotalExerciseTime:totalTime];
    }
}


-(void)timerStarted{
    //[self playSound:@{@"soundName":currentSongName,@"loops":@(-1)}];
    [_videoPlayer play];
}


-(void)timerStopped{
    [self stopSound];
    [_videoPlayer pause];
}


-(void)nextExercise{
    if(_currentVideoIndex < _exerciseArray.count - 1){
        if(!restTimeBetwenExercise && [self checkIfRestNeeded]){
            restTime = NO;
            return;
        }
        restTimeBetwenExercise = NO;
        if(!restTime){
            _currentVideoIndex ++;
            [_exercisesProgressContainer setIsLastCircle:_remainedRounds == 1];
            [_exercisesProgressContainer setIsLastExercise:_currentVideoIndex == _exerciseArray.count - 1];
            [_exercisesProgressContainer.currentExercisesCollectionView reloadData];
        }
        [self restDone];
    }else{
        _remainedRounds--;
        if(_remainedRounds > 0){
            if(_recovery == 2 || _isPredefined){
                [self setRestTime];
            }else{
                _currentVideoIndex = 0;
                if(restTime){
                    [self restDone];
                }else{
                    [_exercisesProgressContainer scrollCollectionView:_currentVideoIndex withRound: totalRounds - _remainedRounds animated:true];
                    [self showNextExercise];
                }
                return;
            }
        }else{
            [self supersetDone];
        }
        _currentVideoIndex = 0;
    }
    [self calculateCurrentTotalTime:0];
    
    if (restTime || !workoutDoneView.isHidden) {
        _landscapeExercisesComponentsView.hidden = true;
    }else
        _landscapeExercisesComponentsView.hidden = [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait;
}


-(BOOL)checkIfRestNeeded{
    restTimeBetwenExercise = NO;
    if(!_isPredefined){
        int currentRoundCount = totalRounds - _remainedRounds;
        
        if(_recovery == 0 && ((_currentVideoIndex + 1) + (currentRoundCount * _exerciseArray.count) ) % 2 == 0){
            restTimeBetwenExercise = YES;
        }else if(_recovery == 1 && ((_currentVideoIndex + 1) + (currentRoundCount * _exerciseArray.count) ) % 3 == 0){
            restTimeBetwenExercise = YES;
        }
    }
    
    if(restTimeBetwenExercise){
        [self setRestTime];
    }
    return restTimeBetwenExercise;
}


-(void)previousExercise{
    if(_currentVideoIndex > 0 && !restTime){
        _currentVideoIndex --;
        [_exercisesProgressContainer scrollCollectionView:_currentVideoIndex withRound: totalRounds - _remainedRounds animated:true];
        [self showNextExercise];
    }else if(restTime){
        _currentVideoIndex --;
        [self restDone];
    }
    [self calculateCurrentTotalTime:0];
}


-(void)restDone{
    //    if(restTime){
    //        [self playSound:@{@"soundName":SONGS_NAME_DICTIONARY[@"restClock"],@"loops":@(-1)}];
    //    }
    if(restTimeBetwenExercise){
        _currentVideoIndex ++;
        restTimeBetwenExercise = NO;
    }
    restTime = NO;
    [_exercisesProgressContainer scrollCollectionView:_currentVideoIndex withRound: totalRounds - _remainedRounds animated:true];
    [self showNextExercise];
}


-(void)startExerciseTimer:(BOOL)isPreview{
    //   [_exercisesProgressContainer updateCurrentExerciseProgressView:0 withTotalExerciseTime:0];
    _timerHandlerController.isPreview = isPreview;
    [_timerHandlerController enableNextPreviousButton:true previousState:true];
    _nextCollectionButton.hidden = YES;
    
    [self setTimerHandlerControllerValues:NO];
    _restView.hidden = YES;
    [workoutDoneView setHidden:true];
}


-(void)setRestTime{
    //[self setRestTimeTitle];
    restTime = YES;
    [self playSound:@{@"soundName":SONGS_NAME_DICTIONARY[@"restBegin"],@"loops":@0}];
    [_timerHandlerController enableNextPreviousButton:YES previousState:NO];
    _nextCollectionButton.hidden = NO;
    [_playlistButton setEnabled:false];
    _restView.hidden = NO;
    [workoutDoneView setHidden:true];
    [self setTimerHandlerControllerValues:YES];
    
    [synth setDelegate:self];
    [self readText:[NSString stringWithFormat:@"%@ 30 %@", restTimeTitlelabel.text, @"secondsKey".localized]];
}


-(void)supersetDone{
    [_playlistButton setEnabled:false];
    [_timerHandlerController enableNextPreviousButton:NO previousState:NO];
    _nextCollectionButton.hidden = YES;
    _timerHandlerController.stopPlayButtonPortrait.enabled  = NO; //_timerHandlerController.stopPlayButtonLandscape.enabled
    _restInfoLabel.hidden = NO;
    _clockComponentsView.hidden = YES;
    _restView.hidden = true;
    [workoutDoneLabel setBebasFontWithType:Bold size:30];
    [workoutDoneView setHidden:false];
//    [self playSound:@{@"soundName":SONGS_NAME_DICTIONARY[@"supersetDone"],@"loops":@0}];
    [synth setDelegate:nil];
    [self readText:@"workout done".localized];
    [self performSelector:@selector(backButtonAction:) withObject:nil  afterDelay:3.0];
}


-(void)previewFinished{
    BOOL nextEnableState = _currentVideoIndex < _exerciseArray.count - 1;
    [_timerHandlerController enableNextPreviousButton:true previousState: _currentVideoIndex != 0];
    _nextCollectionButton.hidden = !nextEnableState;
    [self showNextExerciseAfterPrepare];
}

#pragma mark - Destructive Methods


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    synth = nil;
    
    [self.view.layer removeAllAnimations];
    [(GuideAppDelegate*)[[UIApplication sharedApplication] delegate] setShouldRotateVideo:NO];
    [self stopVideo];
    [self stopSound];
    [_timerHandlerController stopSound];
    [_timerHandlerController deallocTimer];
    _timerHandlerController.delegate = nil;
    [_timerHandlerController removeFromParentViewController];
    [self changeScreenOrientation:UIDeviceOrientationPortrait rotationState:NO];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _prepareProgressCircle.delegate = nil;
    _prepareProgressCircle = nil;
    
    [self.navigationController.navigationBar setBebasFont];
}


-(void)changeScreenOrientation:(UIDeviceOrientation)orientation rotationState:(BOOL)rotationState{
    [(GuideAppDelegate*)[[UIApplication sharedApplication] delegate] setShouldRotateVideo:rotationState];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: orientation] forKey:@"orientation"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}



-(void)dealloc{

}


-(void)stopSound{
    [_soundPlayer stop];
    _soundPlayer.delegate = nil;
    _soundPlayer = nil;
}


-(void)stopVideo{
    [_videoPlayer stop];
    _videoPlayer = nil;
}


#pragma mark - Orientation Delegate


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
        BOOL portraitValue = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
        if(portraitValue){
            [_timerHandlerController.landscapePlayerControlsView setAlpha:0];
        }
        [self.navigationController setNavigationBarHidden:!portraitValue animated:true];
        [self changeViewsOnRotation:portraitValue];
        _videoPlayerView.hidden = _exerciseImageView.hidden = YES;
    }
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
        if (videoWasPaused) {
            videoWasPaused = false;
            [self stopAllProgress:false];
        }
        
        BOOL landscapeOrientation = UIInterfaceOrientationIsPortrait(fromInterfaceOrientation);
        
        if (restTime || !workoutDoneView.isHidden) {
            _landscapeExercisesComponentsView.hidden = true;
        }else
            _landscapeExercisesComponentsView.hidden = !landscapeOrientation;
        
        [self changePlayerConstraint:!landscapeOrientation];
        [self showHidePlaylist: self.view.frame.size.height animated:false];
        _videoPlayerView.hidden = _exerciseImageView.hidden = NO;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    __block BOOL landscapeOrientation = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
    [self.navigationController setNavigationBarHidden:!landscapeOrientation animated:true];
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        landscapeOrientation = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
        [self.navigationController setNavigationBarHidden:landscapeOrientation animated:false];
        
        if(!landscapeOrientation){
            [_timerHandlerController.landscapePlayerControlsView setAlpha:0];
            if (@available(iOS 11.0, *)) {
                GuideAppDelegate *appDelegate = (GuideAppDelegate *)[UIApplication sharedApplication].delegate;
                if (appDelegate.window.safeAreaInsets.top > 0.0) {
                    bottomContenerConstraint.constant = 54;
                } else {
                    bottomContenerConstraint.constant = 0;
                }
            } else {
                bottomContenerConstraint.constant = 0;
            }
        } else {
            if (@available(iOS 11.0, *)) {
                GuideAppDelegate *appDelegate = (GuideAppDelegate *)[UIApplication sharedApplication].delegate;
                if (appDelegate.window.safeAreaInsets.top > 0.0) {
                    bottomContenerConstraint.constant = 21;
                } else {
                    bottomContenerConstraint.constant = 0;
                }
            } else {
                bottomContenerConstraint.constant = 0;
            }
        }
        [self changeViewsOnRotation:!landscapeOrientation];
        if (restTime || !workoutDoneView.isHidden) {
            _landscapeExercisesComponentsView.hidden = true;
        }else
            _landscapeExercisesComponentsView.hidden = !landscapeOrientation;

        if (videoWasPaused) {
            videoWasPaused = false;
            [self stopAllProgress:false];
        }
        
        [self showHidePlaylist: self.view.frame.size.height animated:false];
        [self changePlayerConstraint:!landscapeOrientation];
    }];
}

-(void)changeViewsOnRotation:(BOOL)portraitValue{
    _nextCollectionButton.hidden = !portraitValue;
    [_timerHandlerController hideViewsByOrientation:portraitValue];
    [_exercisesProgressContainer hideViewsOnOrientationChange:portraitValue withConstraint:(float)_timerHandlerController.landscapeComponentsView.frame.size.width];
    _leftRestViewConstraint.constant = portraitValue ? 0 : _landscapeExercisesComponentsView.frame.size.width;
    _botomRestViewConstraint.constant = portraitValue ? 0 : -_timerHandlerController.view.frame.size.height;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_currentVideoIndex inSection:_repsArray.count - _remainedRounds];
    @try {
        [_playlistTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:true];
        [_exercisesTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:true];
    } @catch (NSException *exception) {
        
    }
}


-(void)changePlayerConstraint:(BOOL)landscapeOrientation{
    _videoPlayerLeftConstraint.constant = landscapeOrientation ? 0 : _timerHandlerController.landscapeComponentsView.frame.size.width;
    _videoPlayerBottomConstraint.constant  = landscapeOrientation ? 0 : -_timerHandlerController.view.frame.size.height;
    _videoPlayerTopConstraint.constant  = landscapeOrientation ? 0 : -_exercisesProgressContainer.view.frame.size.height + 10;
    [self.view layoutIfNeeded];
    
    CGRect frame = _videoPlayerView.bounds;
    frame.size.height += 4;
    frame.origin.y -= 2;
    [_videoPlayer.view setFrame:frame];
}

#pragma mark - Preview Handlers



-(void)initProgressCircles{
    _currentCounterIndex = 0;
    _countingArray = @[@"3",@"2",@"1",[@"go".localized stringByAppendingString:@"!"]]; //playlistButton
    
    _startCounterLabel.text = _countingArray[_currentCounterIndex];
//    float startCounterLabelFontSize = CGRectGetWidth(_startCounterLabel.frame)/1.7;
    [_startCounterLabel setBebasFontWithType:Regular size:500];
    
    [_prepareProgressCircle customBaseInit: [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:0.1] activeColor: [UIColor colorWithWhite:1 alpha:0.3] inactiveColor:[UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:.1] pauseColor:[UIColor whiteColor] thickness:8];
    _prepareProgressCircle.delegate = self;
}

-(void)showNextExercise{
//    if (restTime || !workoutDoneView.isHidden) {
//        _landscapeExercisesComponentsView.hidden = true;
//    }else
//        _landscapeExercisesComponentsView.hidden = [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait;
    
    [_exercisesProgressContainer setIsLastCircle:_remainedRounds == 1];
    [_exercisesProgressContainer setIsLastExercise:_currentVideoIndex == _exerciseArray.count - 1];
    [_exercisesProgressContainer.currentExercisesCollectionView reloadData];
    
    [_timerHandlerController resetCircularProgress];
//    currentSelectedIndexPath = [NSIndexPath indexPathForRow:_currentVideoIndex inSection:_repsArray.count - _remainedRounds];
    [self stopSound];
    _playlistButton.enabled = NO;
    _speechOrder = ExerciseName;
    [synth setDelegate:_timerHandlerController.previewType == NoPreview ? self : nil];
    NSString *exerciseName = [self getExerciseName:_currentVideoIndex];
    if (_currentVideoIndex == 0) {
        [self readText:exerciseName];
    }else
        [self readText:[NSString stringWithFormat:@"%@ %@",@"nextExerciseKey".localized, exerciseName]];
    _exerciseNameLabel.text = exerciseName;
    [_exerciseNameLabel setBebasFontWithType:Regular size:40];
    
    int exerciseTime = [self getExerciseLenght:(int)_currentVideoIndex withCurrentRound:(int)_repsArray.count - _remainedRounds];
    [exerciseTimeLabel setText:[NSString stringWithFormat:@"%d %@", exerciseTime, @"secondsKey".localized]];
    [exerciseTimeLabel setBebasFontWithType:Bold size:50];
    
    _previewComponentsView.hidden = NO;
    [self hidePreviewCircle:YES];
    [UIView animateWithDuration:0.5 animations:^{
        NSLog(@"First Animation showNextExercise");
        _videoPlayerView.alpha = 0;
        [_previewComponentsView setAlpha:1];
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            _videoPlayerView.alpha = 1;
        }];
        [self playVideo];
        [self performSelector:@selector(hideExerciseInfo) withObject:nil afterDelay:_timerHandlerController.previewType == NoPreview ? 0 : 2];
    }];
    [restTimeNextExerciseNameLabel setText:[self getExerciseName:0]];
}


-(void)hideExerciseInfo{
    [self startExerciseTimer:YES];
    [UIView animateWithDuration:0.5 animations:^{
        NSLog(@"Second Animation hideExerciseInfo");
        [_previewComponentsView setAlpha:0];
    }completion:^(BOOL finished) {
        if (restTime || !workoutDoneView.isHidden) {
            _landscapeExercisesComponentsView.hidden = true;
        }else
            _landscapeExercisesComponentsView.hidden = [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait;

        if (_timerHandlerController.previewType == NoPreview) {
            _previewComponentsView.hidden = false;
        }else
            _previewComponentsView.hidden = YES;
        _playlistButton.enabled = YES;
    }];
}


-(void)hidePreviewCircle:(BOOL)hideValue{
    _exerciseNameLabel.hidden = !hideValue;
    [exerciseTimeLabel setHidden:hideValue];
    _prepareProgressCircle.hidden = hideValue;
    [_prepareProgressCircle reset];
}



#pragma mark - Circular Progress View Handlers


-(void)showNextExerciseAfterPrepare{
    _playlistButton.enabled = NO;
    _previewComponentsView.hidden = NO;
    _startCounterLabel.transform = CGAffineTransformIdentity;
    _startCounterLabel.text = _countingArray[0];
    [self hidePreviewCircle:NO];
    [UIView animateWithDuration:0.5 animations:^{
        [_previewComponentsView setAlpha:1];
    }completion:^(BOOL finished) {
        if (_timerHandlerController.previewType != NoPreview) {
            [synth setDelegate:self];
            [self readText:exerciseTimeLabel.text];
        }
    }];
}


-(void)startCircularProgress{
    NSLog(@"############ Start Circular Progress");
    _currentCounterIndex = 0;
    _startCounterLabel.text = _countingArray[_currentCounterIndex];
//    [synth setDelegate:self];
//    _speechOrder = PrepareCountdown;
//    for (int i=3; i>=0; i--) {
//        NSString *text = [NSString stringWithFormat:@"%d", i];
//        if(i==0){
//            text = @"go".localized;
//        }
//        [self performSelector:@selector(readText:) withObject:text afterDelay:abs(i-3)];
//    }
//    [self playSound:@{@"soundName":SONGS_NAME_DICTIONARY[@"321GO"],@"loops":@0}];
    [self animateStartExerciseCounter];
    _prepareProgressCircle.totalTime = 3.5;
    _prepareProgressCircle.elapsedTime = 0;
    [_prepareProgressCircle start];
}


#pragma mark - Circle timer delegate


-(void)circleCounterUpdated:(CircleTimer *)circleCounter{
    float elapsedTime = circleCounter.elapsedTime;
    if(elapsedTime > _currentCounterIndex + 1){
        _currentCounterIndex ++ ;
        [self animateStartExerciseCounter];
    }
}

-(void)circleCounterTimeDidExpire:(CircleTimer *)circleCounter{
    [UIView animateWithDuration:0.5 animations:^{
        NSLog(@"Second Animation circleCounterTimeDidExpire");
        [_previewComponentsView setAlpha:0];
    }completion:^(BOOL finished) {
        _previewComponentsView.hidden = YES;
        [_timerHandlerController setExerciseTimer:NO];
    }];
    
    _playlistButton.enabled = YES;
}


-(void)animateStartExerciseCounter{
    [_playlistButton setEnabled:false];
    if (_currentCounterIndex >= _countingArray.count-1) {
        _currentCounterIndex = (int)_countingArray.count-1;
    }
    
    _startCounterLabel.text = _countingArray[_currentCounterIndex];
    _startCounterLabel.transform = CGAffineTransformIdentity;
    [synth setDelegate:_currentCounterIndex == _countingArray.count-1 ? self : nil];
    _speechOrder = PrepareCountdown;
    
    [self readText: _startCounterLabel.text];
    
    if (!SYSTEM_VERSION_LESS_THAN(@"8")) {
        [UIView animateWithDuration:0.75 animations:^{
            _startCounterLabel.transform = CGAffineTransformScale(_startCounterLabel.transform, 0.01, 0.01);
        }];
    }
}

-(void)readText:(NSString *)text{
    BOOL isMute = [Utilities getBOOLFromUserDefaults:MUTE_STATE_KEY];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    [utterance setVolume:!isMute];
    [synth speakUtterance:utterance];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    if (restTime) {
        [synthesizer setDelegate:nil];
        NSString *text = [NSString stringWithFormat:@"%@, %@, %@", @"nextExerciseKey".localized, restTimeNextExerciseNameLabel.text, restTimeNextExerciseSecondsLabel.text];
        [self readText:text];
    }else{
        if (_timerHandlerController.previewType == NoPreview) {
            switch (_speechOrder) {
                case ExerciseName:
                {
                    _speechOrder = ExerciseTime;
                    [synthesizer setDelegate:self];
                    [self readText:exerciseTimeLabel.text];
                }
                    break;
                case ExerciseTime:
                {
                    [synthesizer setDelegate:nil];
                    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self startCircularProgress];
                        });
                    }else
                        [self startCircularProgress];
                }
                    break;
                case PrepareCountdown:
                {
                    [self playWawSoundWithName:@"Beep"];
                }
                    break;
                default:
                    break;
            }
        }else{
            if (_speechOrder == PrepareCountdown) {
                [self playWawSoundWithName:@"Beep"];
            }else
                [self startCircularProgress];
        }
    }
}

- (IBAction)skipButtonAction:(id)sender {
    [self nextExercise];
}

- (IBAction)backButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)backButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}
@end
