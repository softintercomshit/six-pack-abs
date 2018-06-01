#import <UIKit/UIKit.h>
#import "CircleTimer.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@protocol TimerViewControllerDelegate <NSObject, AVAudioPlayerDelegate>


-(void)timerStopped;
-(void)timerStarted;
-(void)nextExercise;
-(void)previousExercise;
-(void)restDone;
-(void)previewFinished;

-(void)currentTimeUpdated:(float)currentTime withTotalTime:(float)totalTime;

@end



@interface TimerViewController : UIViewController

@property (nonatomic) BOOL isPreview;

@property (weak, nonatomic) IBOutlet UIView *landscapePlayerControlsView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;

@property (weak, nonatomic) IBOutlet UIView *landscapeComponentsView;
@property (weak, nonatomic) IBOutlet UIView *portraitComponentsView;


@property (weak, nonatomic) IBOutlet UILabel *timeLabelPortrait;


@property (weak, nonatomic) IBOutlet UIButton *previousButtonPortrait;
@property (weak, nonatomic) IBOutlet UIButton *nextButtonPortrait;
@property (weak, nonatomic) IBOutlet UIButton *stopPlayButtonPortrait;
@property (weak, nonatomic) IBOutlet CircleTimer *circularProgressBarViewPortrait;
@property (weak, nonatomic) IBOutlet UIButton *skipButtonPortrait;





@property (weak, nonatomic) IBOutlet UILabel *timeLabelLandscape;


@property (weak, nonatomic) IBOutlet UIButton *previousButtonLandscape;
@property (weak, nonatomic) IBOutlet UIButton *nextButtonLandscape;
//@property (weak, nonatomic) IBOutlet UIButton *stopPlayButtonLandscape;
@property (weak, nonatomic) IBOutlet CircleTimer *circularProgressBarViewLandscape;
@property (weak, nonatomic) IBOutlet UIButton *skipButtonLandscape;




@property (weak, nonatomic) id <TimerViewControllerDelegate> delegate;
@property (nonatomic) PreviewType previewType;

@property (nonatomic) BOOL isPaused;
@property (nonatomic) BOOL isManualPaused;

@property (nonatomic) float remainingExerciseTime;

-(void)enableNextPreviousButton:(BOOL)enableNext previousState:(BOOL)enablePrevious;
-(void)setExerciseTimer:(BOOL)restMode;

-(void)deallocTimer;
-(void)stopSound;
-(void)resetCircularProgress;

- (IBAction)nextButtonAction:(id)sender;
- (IBAction)previousButtonAction:(id)sender;
- (IBAction)stopPlayButtonAction:(id)sender;


-(void)hideViewsByOrientation:(BOOL)portrait;


-(void)stopCircularPorgress;
-(void)resumeCircularProgress;

@end
