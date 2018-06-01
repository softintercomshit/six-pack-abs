#import "CustomWorkoutExercise.h"
#import "WorkoutData.h"
#import "Utils.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"
#import "RestTimeController.h"
@import HealthKit;


@interface CustomWorkoutExercise()<HKWorkoutSessionDelegate>

@property (weak, nonatomic) IBOutlet WKInterfaceImage *exerciseImageView;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *previousExerciseButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *playPauseButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *nextExerciseButton;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *workoutTimeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *exerciseTimeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *currentExerciseLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *currentProgressLabel;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *currentProgressGroup;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *exerciseProgressGroup;

@end

@implementation CustomWorkoutExercise{
    NSTimer *animationTimer;
    WorkoutData *workoutData;
    ExerciseData *exerciseData;
    NSMutableArray<UIImage*> *arrayWithImages;
    
    BOOL exercisePaused;
    NSInteger workoutCurrentTime, currentImageIndex;
    
    HKHealthStore *healthStore;
    HKWorkoutConfiguration *workoutConfiguration;
    HKWorkoutSession *workoutSession;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    healthStore = [[HKHealthStore alloc] init];
    workoutConfiguration = [[HKWorkoutConfiguration alloc] init];
    workoutConfiguration.activityType = HKWorkoutActivityTypeOther;
    NSError *error;
    workoutSession = [[HKWorkoutSession alloc] initWithConfiguration:workoutConfiguration error:&error];
    [workoutSession setDelegate:self];
    if (!error) {
        [healthStore startWorkoutSession:workoutSession];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restControllerDismissed) name:@"restControllerDismissed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(workoutDoneControllerDismissed) name:@"workoutDoneControllerDismissed" object:nil];
    
    NSInteger exerciseIndex = [context[@"exerciseIndex"] integerValue];
    workoutData = context[@"workout"];
    exerciseData = workoutData.exercises[exerciseIndex];
    
    workoutCurrentTime = [self finalExerciseTime] - exerciseData.duration;
    
    [self setExerciseImage:exerciseData.imagesName];
    
    [self setTitle:exerciseData.name.localized];
    
    [self.currentExerciseLabel setText:[NSString stringWithFormat:@"%ld", (long)exerciseIndex+1]];
    [self.currentProgressLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)exerciseIndex+1, (long)workoutData.exercises.count]];
    
    NSInteger elapsedTime = workoutData.duration - workoutCurrentTime;
    NSInteger workoutElapsedMinutes = elapsedTime / 60;
    NSInteger workoutElapsedSeconds = elapsedTime % 60;
    [self.workoutTimeLabel setText:[NSString stringWithFormat:@"%.2ld:%.2ld", (long)workoutElapsedMinutes, (long)workoutElapsedSeconds]];
    
    
    NSInteger exerciseElapsedMinutes = elapsedTime / exerciseData.duration / 60;
    [self.exerciseTimeLabel setText:[NSString stringWithFormat:@"%.2ld:%.2ld", (long)exerciseElapsedMinutes, (long)exerciseData.duration]];
    
    [self.exerciseProgressGroup setWidth:0];
    
//    NSInteger screenWidth = [Utils sharedInstance].isWatch48MM ? 66 : 46;
//    CGFloat currentProgress = (exerciseIndex+1) * screenWidth / workoutData.exercises.count;
//    [self.currentProgressGroup setWidth:currentProgress];
    
    [self.currentProgressGroup setWidth:0];
}

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    [super didDeactivate];

    if (WKExtension.sharedExtension.applicationState == WKApplicationStateActive) {
        if (animationTimer.isValid) {
            [healthStore endWorkoutSession:workoutSession];
            [animationTimer invalidate];
        }
    }
}

-(void)setExerciseImage:(NSArray<NSString *> *)imagesName{
    [self.exerciseImageView setImage:nil];
    arrayWithImages = [NSMutableArray new];
    
    for (NSString *imageName in imagesName) {
        UIImage *image;
        if (exerciseData.isCustom) {
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *imagePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"images/%@", imageName]];
            image = [UIImage imageWithContentsOfFile:imagePath];
        }else
            image = [UIImage imageNamed:[imageName stringByAppendingString:@".jpg"]];
        
        if(image)
            [arrayWithImages addObject:image];
    }
    
    if (arrayWithImages.count > 0) {
        [self.exerciseImageView setImage:arrayWithImages[0]];
    }else{
        [self.exerciseImageView setImage:[UIImage imageNamed:@"noImageBig"]];
    }
    
    if (animationTimer.isValid) {
        [animationTimer invalidate];
    }
    
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animateImages:) userInfo:nil repeats:true];
    
    [self.playPauseButton setTitle:exercisePaused ? @"Play" : @"Pause"];
}

-(void)animateImages:(NSTimer *)timer{
    currentImageIndex++;
    if (currentImageIndex == arrayWithImages.count) {
        currentImageIndex = 0;
    }
    
    if (arrayWithImages.count > 0) {
        [self.exerciseImageView setImage:arrayWithImages[currentImageIndex]];
    }else{
        [self.exerciseImageView setImage:[UIImage imageNamed:@"noImageBig"]];
    }
    
    workoutCurrentTime++;
    
    if (workoutCurrentTime == workoutData.duration) {
        //workout done
        [timer invalidate];
        [self presentControllerWithName:@"CustomWorkoutDoneController" context:nil];
        return;
    }
    
    NSInteger elapsedTime = workoutData.duration - workoutCurrentTime;
    NSInteger workoutElapsedMinutes = elapsedTime / 60;
    NSInteger workoutElapsedSeconds = elapsedTime % 60;
    [self.workoutTimeLabel setText:[NSString stringWithFormat:@"%.2ld:%.2ld", (long)workoutElapsedMinutes, (long)workoutElapsedSeconds]];
    
    NSInteger exerciseElapsedMinutes = elapsedTime / exerciseData.duration / 60;
    NSInteger finalExerciseTime = [self finalExerciseTime];
    NSInteger exerciseElapsedSeconds = finalExerciseTime - workoutCurrentTime;
    [self.exerciseTimeLabel setText:[NSString stringWithFormat:@"%.2ld:%.2ld", (long)exerciseElapsedMinutes, (long)exerciseElapsedSeconds]];
    
    NSInteger screenWidth = [Utils sharedInstance].isWatch48MM ? 66 : 46;
    
    float percents = (float)abs(exerciseElapsedSeconds-exerciseData.duration) / (float)exerciseData.duration;
    CGFloat exerciseProgress = (float)screenWidth * percents;
    [self.exerciseProgressGroup setWidth:exerciseProgress];
    
    CGFloat currentProgress = (float)screenWidth * (float)workoutCurrentTime / (float)workoutData.duration;
    [self.currentProgressGroup setWidth:currentProgress];
    
    [self handleRestTime];
}

-(NSInteger)finalExerciseTime{
    NSInteger finalExerciseTime = 0;
    NSInteger exerciseIndex = [workoutData.exercises indexOfObject:exerciseData];
    
    for (int i=0; i<=exerciseIndex; i++) {
        finalExerciseTime += workoutData.exercises[i].duration;
    }
    
    return finalExerciseTime;
}

-(void)handleRestTime{
    NSInteger exerciseIndex = [workoutData.exercises indexOfObject:exerciseData];
    if (exerciseIndex == workoutData.exercises.count-1) {
        //return if last exercise and round
        return;
    }
    
    void (^handleRestTime)(NSInteger) = ^void(NSInteger circles) {
        [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeNotification];
        
        NSInteger finalExerciseTime = [self finalExerciseTime];
        
        BOOL finalSecond = finalExerciseTime == workoutCurrentTime;
        
        if (finalSecond && (exerciseIndex+1)%circles==0) {
            [animationTimer invalidate];
            NSString *nextExerciseName = workoutData.exercises[exerciseIndex+1].name;
            [self presentControllerWithName:@"RestTimeController" context:nextExerciseName.localized];
        }else if(finalSecond){
            [self moveToNextExercise];
        }
    };
    
    switch (workoutData.recoveryMode) {
        case Every2Exercises:
            handleRestTime(2);
            break;
            
        case Every3Exercises:
            handleRestTime(3);
            break;
            
        case EveryCircle:
            handleRestTime(workoutData.repeats);
            break;
            
        case NoRecovery:
            handleRestTime(workoutData.exercises.count);
            break;
            
        default:
            break;
    }
}

#pragma mark - buttons action
-(void)restControllerDismissed{
    [self moveToNextExercise];
}

-(void)workoutDoneControllerDismissed{
    [self popController];
    [healthStore endWorkoutSession:workoutSession];
    [animationTimer invalidate];
}

- (IBAction)previousExerciseAction {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    currentImageIndex = 0;
    NSInteger exerciseIndex = [workoutData.exercises indexOfObject:exerciseData] - 1;
    
    if (exerciseIndex < 0) {
        //return if first round and exercise
        return;
    }
    
    [self setNewExercise:exerciseIndex];
}

- (IBAction)nextExerciseAction {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    currentImageIndex = 0;
    NSInteger exerciseIndex = [workoutData.exercises indexOfObject:exerciseData] + 1;
    
    if (exerciseIndex > workoutData.exercises.count-1) {
        //return if last round and exercise
        return;
    }
    
    [self setNewExercise:exerciseIndex];
}

-(void)moveToNextExercise{
    [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeNotification];
    
    currentImageIndex = 0;
    
    NSInteger exerciseIndex = [workoutData.exercises indexOfObject:exerciseData] + 1;
    
    if (exerciseIndex > workoutData.exercises.count-1) {
        //return if last round and exercise
        return;
    }
    
    [self setNewExercise:exerciseIndex];
}

-(void)setNewExercise:(NSInteger)exerciseIndex{
    [self.exerciseProgressGroup setWidth:0];
    
    exerciseData = workoutData.exercises[exerciseIndex];
    [self setTitle:exerciseData.name];
    
    [animationTimer invalidate];
    
    workoutCurrentTime = 0;
    for (int i=0; i<exerciseIndex; i++) {
        workoutCurrentTime += workoutData.exercises[i].duration;
    }
    
    [self setExerciseImage:exerciseData.imagesName];
    
    [self.currentExerciseLabel setText:[NSString stringWithFormat:@"%ld", (long)exerciseIndex+1]];
    [self.currentProgressLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)exerciseIndex+1, (long)workoutData.exercises.count]];
    
//    NSInteger screenWidth = [Utils sharedInstance].isWatch48MM ? 66 : 46;
//    CGFloat currentProgress = (exerciseIndex+1) * screenWidth / workoutData.exercises.count;
//    [self.currentProgressGroup setWidth:currentProgress];
}

- (IBAction)playPauseAction {
    if (exercisePaused) {
        currentImageIndex++;
        if (currentImageIndex == arrayWithImages.count) {
            currentImageIndex = 0;
        }
        
        if (arrayWithImages.count > 0) {
            [self.exerciseImageView setImage:arrayWithImages[currentImageIndex]];
        }
        
        animationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animateImages:) userInfo:nil repeats:true];
        [self animateImages:animationTimer];
    }else{
        [animationTimer invalidate];
    }
    exercisePaused = !exercisePaused;
    [self.playPauseButton setTitle:exercisePaused ? @"Play" : @"Pause"];
}

- (void)workoutSession:(HKWorkoutSession *)workoutSession
      didChangeToState:(HKWorkoutSessionState)toState
             fromState:(HKWorkoutSessionState)fromState
                  date:(NSDate *)date{
    NSLog(@"------>%ld", (long)toState);
}

- (void)workoutSession:(HKWorkoutSession *)workoutSession didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}
@end
