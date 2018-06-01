#import "SuperSetImagesGuideInterfaceController.h"
#import "Utils.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"


@interface SuperSetImagesGuideInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceImage *superSetImageView;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *timerLabel;
@end

@implementation SuperSetImagesGuideInterfaceController

NSDictionary* workoutInfoDict;
NSArray* workoutExercisesArray;
NSTimer* timer;
int timerCountSeconds;
int timerCountMinutes;
int totalTimeSeconds;
int currentExerciseRepeatSeconds;
int currentExercise=0;
int currentCircleCount;
int maxCircles;
int restTimerCount;
- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    workoutInfoDict=context;
    maxCircles=[workoutInfoDict[@"workout"][@"circles"]intValue];
    workoutExercisesArray=workoutInfoDict[@"exercises"];
}

- (void)willActivate {
    [super willActivate];
    [self resetExercisesCount];
    [self resetTimerCounts];
    [self startTimerForExercise];
    [self setExercise];
}


//[self setExerciseImage:exercisesArray];

- (void)didDeactivate {
    [super didDeactivate];
    [self stopTimer];
}

-(void)setExerciseImage:(NSDictionary*)currentExerciseDict{
    [self.superSetImageView  stopAnimating];
    NSDictionary* dictWithImagesInfo=currentExerciseDict[@"images"];
    NSArray* arrayWithImagesKey= [[dictWithImagesInfo allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray* arrayWithImages=[NSMutableArray new];
    for(int i = 0; i < [arrayWithImagesKey count]; i++){
        NSData* imageData=dictWithImagesInfo[arrayWithImagesKey[i]];
        UIImage *image= [UIImage imageWithData:imageData];
        if(image)
            [arrayWithImages addObject:image];
    }
    UIImage* animatedImage=[UIImage animatedImageWithImages:arrayWithImages duration:0];
    [self.superSetImageView setImage:animatedImage];
    long numberOfImages=[arrayWithImages count];
    [self.superSetImageView startAnimatingWithImagesInRange:NSMakeRange(0, numberOfImages) duration:numberOfImages repeatCount:-1];
}

-(void)setExercise{
    NSDictionary* currentExerciseDict=workoutExercisesArray[currentExercise];
    [self setExerciseImage:currentExerciseDict];
    
    NSDictionary* repetitionsDict=currentExerciseDict[@"repetitions"];
    currentExerciseRepeatSeconds=[[repetitionsDict objectForKey:[NSNumber numberWithInt:currentCircleCount]]intValue]*2;
    NSLog(@"%@",[repetitionsDict objectForKey:[NSNumber numberWithInt:currentCircleCount]]);
    currentExercise++;
}

#pragma mark - Timer methods Handle

- (void)startTimerForExercise{
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(increaseTimerCount) userInfo:nil repeats:YES];
}

- (void)startTimerForRest{
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(increseRestTimer) userInfo:nil repeats:YES];
}

- (void)stopTimer{
    [timer invalidate];
}

-(void)resetTimerCounts{
    timerCountSeconds=0;
    timerCountMinutes=0;
    totalTimeSeconds=0;
    restTimerCount=0;
}

-(void)resetExercisesCount{
    currentExerciseRepeatSeconds=0;
    currentCircleCount=0;
    currentExercise=0;
}

- (void)increaseTimerCount{
    timerCountSeconds++;
    totalTimeSeconds++;
    if(timerCountSeconds>59){
        timerCountSeconds=0;
        timerCountMinutes++;
    }
    if(totalTimeSeconds>currentExerciseRepeatSeconds){
        if(currentExercise>[workoutExercisesArray count]-1){
            [self stopTimer];
            [self resetTimerCounts];
            [self.timerLabel setText:nil];
            currentExercise=0;
            currentCircleCount++;
            if(currentCircleCount>maxCircles-1){
                [self setFinalInfo];
                return;
            }else{
                [self setRestInfoRmation];
                return;
            }
        }else{
            [self setExercise];
            [self resetTimerCounts];
        }
    }
    [self.timerLabel setText:[NSString stringWithFormat:@"%02d:%02d",timerCountMinutes,timerCountSeconds]];
}

-(void)setFinalInfo{
    [self.superSetImageView stopAnimating];
    [self.superSetImageView setImage:nil];
    [self.timerLabel setText:@"successKey".localized];
}

-(void)setRestInfoRmation{
    [self.superSetImageView stopAnimating];
    [self.superSetImageView setImage:nil];
    [self startTimerForRest];
}

-(void)increseRestTimer{
    restTimerCount++;
    [self.timerLabel setText:[NSString stringWithFormat:@"00:%02d",restTimerCount]];
    if(restTimerCount>29){
        [self stopTimer];
        [self resetTimerCounts];
        totalTimeSeconds=currentExerciseRepeatSeconds+1;
        [self startTimerForExercise];
    }
}
@end



