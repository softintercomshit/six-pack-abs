#import "RestTimeController.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"


@interface RestTimeController()

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *timerLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *restTimeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *nextExerciseTitleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *nextExerciseLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *skipButton;
@property (weak, nonatomic) NSTimer *restTimer;

@end

@implementation RestTimeController{
    NSInteger currentTime;
}

-(void)awakeWithContext:(id)context{
    [_restTimeLabel setText:@"rest30secKey".localized];
    [_skipButton setTitle:@"skipKey".localized];
    [_nextExerciseTitleLabel setText:@"nextExerciseKey".localized];
    [_nextExerciseLabel setText:context];
}

-(void)willActivate{
    _restTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerHandler:) userInfo:nil repeats:true];
}

-(void)timerHandler:(NSTimer *)timer{
    currentTime++;
    [_timerLabel setText:[NSString stringWithFormat:@"00:%.02ld", 30-(long)currentTime]];
    
    if (currentTime == 30) {
        [self performSelector:@selector(skipAction)];
    }
}

- (IBAction)skipAction {
    [_restTimer invalidate];
    [self dismissController];
}

-(void)willDisappear{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restControllerDismissed" object:nil];
}
@end
