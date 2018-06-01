#import "TimerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "GuideAppDelegate.h"


#define SOUNDS_NAME_DICTIONARY @{ @"tenSeconds":@"Exercise Vocals B", @"next" :@"Exercise Vocals C", @"restEnding" : @"clock_pips" }
#define BETWEEN(value, min, max) (value < max && value > min)


@interface TimerViewController () <CircleTimerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *landscapeAspectRatioCosntraint;

@end

@implementation TimerViewController{
    AVSpeechSynthesizer *synth;
    NSString *lastLabelValue;
    AVAudioPlayer *_soundPlayer;
    __weak IBOutlet NSLayoutConstraint *skipButtonPortraitheightConstraint;
    __weak IBOutlet NSLayoutConstraint *skipButtonLandscapeHeightConstraint;
    __weak IBOutlet UILabel *prepareLabel;
    __weak IBOutlet NSLayoutConstraint *landscapeBottomConstraint;
    __weak IBOutlet NSLayoutConstraint *timeLabelTopConstraint;
    __weak IBOutlet NSLayoutConstraint *circleWidthConstraint;
    __weak IBOutlet NSLayoutConstraint *circleHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *landscapeViewConstraint;
    __weak IBOutlet NSLayoutConstraint *timerLabelTopConstraint;
}


NSTimer *exerciseTimer;
AVAudioPlayer *informativePlayer;

BOOL isPlayingState;
BOOL restoreMode;

float totalTime;

float previewTime;

float lastValue;

- (void)viewDidLoad {
    [super viewDidLoad];
    [_portraitComponentsView addToSafeArea];
    
    if (@available(iOS 11.0, *)) {
        GuideAppDelegate *appDelegate = (GuideAppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.window.safeAreaInsets.top > 0.0) {

        } else {
            landscapeBottomConstraint.constant = 0;
            timeLabelTopConstraint.constant = 0;
            circleWidthConstraint.constant = circleHeightConstraint.constant = 100;
        }
    } else {
        landscapeBottomConstraint.constant = 0;
        timeLabelTopConstraint.constant = 0;
        circleWidthConstraint.constant = circleHeightConstraint.constant = 100;
    }
    
    synth = [[AVSpeechSynthesizer alloc] init];
    _isPaused = NO;
    [self initProgressCircles];
    
    @try {
        [_timeLabelPortrait addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    } @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
    [_timeLabelPortrait setBebasFontWithType:Bold size:60];
    [_timeLabelPortrait setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    [_skipButtonPortrait setBebasFontWithType:Regular size:21];
    
    [_timeLabelLandscape setBebasFontWithType:Bold size:200];
    [_skipButtonLandscape setBebasFontWithType:Regular size:21];
    
    
    if (_skipButtonPortrait.titleLabel.text.length <= 4) {
        skipButtonPortraitheightConstraint.constant = 30;
        skipButtonLandscapeHeightConstraint.constant = 25;
    }else{
        skipButtonPortraitheightConstraint.constant = 50;
        skipButtonLandscapeHeightConstraint.constant = 45;
    }
    
    _skipButtonPortrait.titleLabel.numberOfLines = 0;
    _skipButtonPortrait.titleLabel.minimumScaleFactor = 0.1;
    _skipButtonPortrait.titleLabel.adjustsFontSizeToFitWidth = YES;
    _skipButtonPortrait.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    _skipButtonLandscape.titleLabel.numberOfLines = 0;
    _skipButtonLandscape.titleLabel.minimumScaleFactor = 0.1;
    _skipButtonLandscape.titleLabel.adjustsFontSizeToFitWidth = YES;
    _skipButtonLandscape.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    if(isIpad){
        _landscapeAspectRatioCosntraint.constant = 150;
    }
}

-(void)initProgressCircles{
    [_circularProgressBarViewPortrait customBaseInit:[UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1]
                                         activeColor:[UIColor colorWithRed:255/255.0 green:77/255.0 blue:71/255.0 alpha:0.5]
                                       inactiveColor:[UIColor colorWithRed:251/255.f green:251/255.f blue:251/255.f alpha:1]
                                          pauseColor: RED_COLOR
                                           thickness:6];
    
    _circularProgressBarViewPortrait.delegate = self;
    [_circularProgressBarViewLandscape customBaseInit: [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:0.1] activeColor: [UIColor colorWithWhite:1 alpha:0.3] inactiveColor:[UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:0.1] pauseColor:[UIColor whiteColor] thickness:6];
}

-(void)playWawSoundWithName:(NSString *)soundName{
    if(![Utilities getBOOLFromUserDefaults:MUTE_STATE_KEY]){
        NSString *path = [[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"];
        NSURL *url = [NSURL fileURLWithPath: path];
        NSError *error;
        _soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
//        [_soundPlayer setDelegate: self];
        [_soundPlayer prepareToPlay];
        [_soundPlayer play];
    }
}

#pragma mark - Timer methods
-(PreviewType)previewType{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _previewType = [defaults integerForKey:kExercisePreviewKey];
    return _previewType;
}

-(void)setExerciseTimer:(BOOL)restMode{
    [self deallocTimer];
    if (_isPreview){
        [_timeLabelPortrait setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
//        _timeLabelPortrait.text = _timeLabelLandscape.text = @"prepareKey".localized;
        _timeLabelPortrait.text = @"prepareKey".localized;
        _timeLabelLandscape.text = @"";
        [prepareLabel setHidden:false];
        [prepareLabel setBebasFontWithType:Bold size:80];
        [prepareLabel setText:@"prepareKey".localized];
        
        previewTime = _previewType;
        exerciseTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    }else{
        isPlayingState = !restMode;
        restoreMode = restMode;
        if(restoreMode){
            _remainingExerciseTime = 30;
        }
        totalTime = _remainingExerciseTime;
        lastValue = INT32_MAX;
        [self startCircularProgress];
    }
    
    [self hideSkipButtons];
    [self changePlayButtonState];
}


-(void)hideSkipButtons{
    _skipButtonPortrait.hidden = _skipButtonLandscape.hidden = !_isPreview;
}


-(void)changePlayButtonState{
    _stopPlayButtonPortrait.enabled = !restoreMode && !_isPreview; //_stopPlayButtonLandscape.enabled =
    _playPauseButton.enabled = !restoreMode && !_isPreview;
    
    if(restoreMode){
        [_stopPlayButtonPortrait setImage:[UIImage imageNamed:@"btnPauseBig"] forState:UIControlStateNormal];
        [_playPauseButton setImage:[UIImage imageNamed:@"btnPauseBig"] forState:UIControlStateNormal];
    }else{
        if(isPlayingState || _isPreview){
            [_stopPlayButtonPortrait setImage:[UIImage imageNamed:@"btnPauseBig"] forState:UIControlStateNormal];
            [_playPauseButton setImage:[UIImage imageNamed:@"btnPauseBig"] forState:UIControlStateNormal];
        }else{
            [_stopPlayButtonPortrait setImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateNormal];
            [_playPauseButton setImage:[UIImage imageNamed:@"btnPlay"] forState:UIControlStateNormal];
        }
    }
}


-(void)updateTime{
    //    if(_isPreview){
    
    if(!_isPaused){
        previewTime -= (exerciseTimer.timeInterval);
        float roundedValueRemainingTime = round (previewTime * 100.0) / 100.0 ;
        if(roundedValueRemainingTime <= 0){
            [self skipPreviewButtonAction:nil];
        }
    }
}

//-(void)setIsPaused:(BOOL)isPaused{
//    _isPaused = isPaused;
//    [self changePlayButtonState];
//}

#pragma mark - Circular Progress View Handlers

-(void)startCircularProgress{
    _circularProgressBarViewPortrait.totalTime = _circularProgressBarViewLandscape.totalTime = totalTime;
    _circularProgressBarViewPortrait.elapsedTime = _circularProgressBarViewLandscape.elapsedTime = totalTime - _remainingExerciseTime;
    [_circularProgressBarViewPortrait start];
    [_circularProgressBarViewLandscape start];
    [_timeLabelPortrait setBebasFontWithType:Bold size:80];
    [_timeLabelPortrait setBaselineAdjustment:UIBaselineAdjustmentNone];
}


-(void)stopCircularPorgress{
    [_circularProgressBarViewPortrait stop];
    [_circularProgressBarViewLandscape stop];
}


-(void)resumeCircularProgress{
    [_circularProgressBarViewPortrait resume];
    [_circularProgressBarViewLandscape resume];
}


-(void)resetCircularProgress{
    [_circularProgressBarViewPortrait reset];
    [_circularProgressBarViewLandscape reset];
}


#pragma mark - UI


-(void)enableNextPreviousButton:(BOOL)enableNext previousState:(BOOL)enablePrevious{
    _nextButtonLandscape.enabled = _nextButtonPortrait.enabled = enableNext;
    _previousButtonLandscape.enabled = _previousButtonPortrait.enabled = enablePrevious;
    
    _nextButton.enabled = _nextButtonPortrait.enabled = enableNext;
    _previousButton.enabled = _previousButtonPortrait.enabled = enablePrevious;
}


#pragma mark - Sound Methods


-(void)playSound:(NSDictionary*)songInformationDictionary{//(NSString*)soundName numberOfLoops:(int)loopsNumber{
    if( ![Utilities getBOOLFromUserDefaults:MUTE_STATE_KEY]){
        [informativePlayer stop];
        NSURL* path2 = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:songInformationDictionary[@"soundName"] ofType:@"mp3"]];
        informativePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:path2 error:nil];
        [informativePlayer prepareToPlay];
        [informativePlayer setNumberOfLoops:[songInformationDictionary[@"loops"] intValue]];
        [informativePlayer play];
    }
}


#pragma mark - IBAction


- (IBAction)previousButtonAction:(id)sender {
    [self stopSound];
    [self deallocTimer];
    [self sendPreviousDelegate];
}


- (IBAction)nextButtonAction:(id)sender {
    [self stopSound];
    [self deallocTimer];
    
    restoreMode = true;
    if (restoreMode) {
        _isPreview = NO;
    }
    [self sendNextDelegate];
}


- (IBAction)stopPlayButtonAction:(id)sender {
    _isManualPaused = !_isManualPaused;
    isPlayingState = !isPlayingState;
    if(isPlayingState){
        // [self setExerciseTimer:NO];
        [self sendPlayDelegate];
        [self resumeCircularProgress];
    }else{
        [self stopCircularPorgress];
        // [self deallocTimer];
        [self sendStopDelegate];
    }
    [self changePlayButtonState];
}


- (IBAction)skipPreviewButtonAction:(id)sender {
    _isPreview = NO;
    [self sendPreviewFinished];
}

#pragma mark - Orientation Change Handlers


-(void)hideViewsByOrientation:(BOOL)portrait{
    _portraitComponentsView.hidden = !portrait;
    _landscapeComponentsView.hidden = portrait;
}


#pragma  mark - Delegates

-(void)sendStopDelegate{
    if(_delegate && [_delegate respondsToSelector:@selector(timerStopped)]){
        [_delegate timerStopped];
    }
}

-(void)sendPlayDelegate{
    if(_delegate && [_delegate respondsToSelector:@selector(timerStarted)]){
        [_delegate timerStarted];
    }
}

-(void)sendPreviousDelegate{
    [self resetCircularProgress];
    if(_delegate && [_delegate respondsToSelector:@selector(previousExercise)]){
        [_delegate previousExercise];
    }
}

-(void)sendNextDelegate{
    [self resetCircularProgress];
    if(_delegate && [_delegate respondsToSelector:@selector(nextExercise)]){
        [_delegate nextExercise];
    }
}

-(void)sendRestTerminatedDelegate{
    [self resetCircularProgress];
    if(_delegate && [_delegate respondsToSelector:@selector(restDone)]){
        [_delegate restDone];
    }
}

-(void)sendCurrentTimerTime{
    if(_delegate && [_delegate respondsToSelector:@selector(currentTimeUpdated: withTotalTime:)]){
        [_delegate currentTimeUpdated:totalTime - _remainingExerciseTime withTotalTime:totalTime];
    }
}


-(void)sendPreviewFinished{
    [self deallocTimer];
    [self resetCircularProgress];
    [self hideSkipButtons];
    if(_delegate && [_delegate respondsToSelector:@selector(previewFinished)]){
        [_delegate previewFinished];
    }
}

#pragma mark - Circle Timer delegate


-(void)circleCounterUpdated:(CircleTimer *)circleCounter{
    _remainingExerciseTime =  totalTime - circleCounter.elapsedTime;
    _timeLabelPortrait.text =  _timeLabelLandscape.text = [NSString stringWithFormat:@"%0.f",fabs(_remainingExerciseTime)];
    [prepareLabel setHidden:true];
    
    if(lastValue >= 0 && _remainingExerciseTime < 0){
        restoreMode ? [self sendRestTerminatedDelegate] : [self sendNextDelegate];
    }
    
    if(lastValue >= 4 && _remainingExerciseTime < 4 && restoreMode){
        [self playSound:@{@"soundName":SOUNDS_NAME_DICTIONARY[@"restEnding"],@"loops":@0}];
    }
    
    lastValue = _remainingExerciseTime;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"text"]) {
        NSString *str = [NSString stringWithFormat:@"%@", change[@"new"]];
        if (str.length > 2) {
            _timeLabelLandscape.minimumScaleFactor = .1;
        }else{
            _timeLabelLandscape.minimumScaleFactor = .35;
        }
        
        if (![lastLabelValue isEqualToString:change[@"new"]]) {

            NSCharacterSet* digits = [NSCharacterSet decimalDigitCharacterSet];
            if ([_timeLabelPortrait.text rangeOfCharacterFromSet:digits].location == NSNotFound) {
                timerLabelTopConstraint.constant = 0;
            } else {
                timerLabelTopConstraint.constant = 15;
                if (CGRectGetWidth([UIScreen mainScreen].bounds) >= 414) {
                    timerLabelTopConstraint.constant = 0;
                }
            }
            
            if(!_isPreview){
                [self sendCurrentTimerTime];
            }
            
            lastLabelValue = change[@"new"];
            if (!restoreMode) {
                NSInteger currentValue = [lastLabelValue integerValue];
                switch (currentValue) {
                    case 10:
                    {
                        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"x more seconds", nil), [NSString stringWithFormat:@"%d", 10]];
                        [self readText:text];
                    }
                        break;
                    case 5:case 4:case 3:case 2:case 1:
                        [self readText:lastLabelValue];
                        break;
                    case 0:
                    {
                        if (![change[@"new"] isEqualToString:@"prepareKey".localized]) {
                            [self playWawSoundWithName:@"Beep"];
                        }
                    }
                        break;
                    default:
                    {
                        if (totalTime/2 == currentValue) {
                            [self readText:@"halfWayThereKey".localized];
                        }
                    }
                        break;
                }
            }
        }
    }
}

#pragma mark - Destructive


-(void)deallocTimer{
    [exerciseTimer invalidate];
    exerciseTimer = nil;
}


-(void)stopSound{
    [informativePlayer stop];
    informativePlayer = nil;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _circularProgressBarViewPortrait.delegate = nil;
    _circularProgressBarViewLandscape.delegate =nil;
    _circularProgressBarViewPortrait = nil;
    _circularProgressBarViewLandscape =nil;
    [self deallocTimer];
    [self stopSound];
}

-(void)readText:(NSString *)text{
    BOOL isMute = [Utilities getBOOLFromUserDefaults:MUTE_STATE_KEY];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];
    [utterance setVolume:!isMute];
    [synth speakUtterance:utterance];
}

-(void)dealloc{
    @try {
        [_timeLabelPortrait removeObserver:self forKeyPath:@"text"];
    } @catch (NSException *exception) {}
}

@end
