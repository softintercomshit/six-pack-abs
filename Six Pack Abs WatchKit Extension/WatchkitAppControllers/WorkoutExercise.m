#import "WorkoutExercise.h"
#import "WorkoutData.h"
#import "Utils.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"
#import "RestTimeController.h"
@import HealthKit;
@import UIKit;


@interface WorkoutExercise()<HKWorkoutSessionDelegate>

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

@implementation WorkoutExercise{
    NSTimer *animationTimer;
    WorkoutData *workoutData;
    ExerciseData *exerciseData;
    NSMutableArray *arrayWithImages;
    
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
    
    NSInteger exerciseTime = workoutData.duration / workoutData.exercises.count;
    workoutCurrentTime += exerciseIndex*exerciseTime;
    
    [self setExerciseImage:exerciseData.imagesName];
    
    [self setTitle:exerciseData.name.localized];
    
    [self.currentExerciseLabel setText:[NSString stringWithFormat:@"%ld", (long)exerciseIndex+1]];
    [self.currentProgressLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)exerciseIndex+1, (long)workoutData.exercises.count]];
    
    NSInteger elapsedTime = workoutData.duration - workoutCurrentTime;
    NSInteger workoutElapsedMinutes = elapsedTime / 60;
    NSInteger workoutElapsedSeconds = elapsedTime % 60;
    [self.workoutTimeLabel setText:[NSString stringWithFormat:@"%.2ld:%.2ld", (long)workoutElapsedMinutes, (long)workoutElapsedSeconds]];
    
    
    NSInteger exerciseElapsedMinutes = elapsedTime / exerciseTime / 60;
    [self.exerciseTimeLabel setText:[NSString stringWithFormat:@"%.2ld:%.2ld", (long)exerciseElapsedMinutes, (long)exerciseTime-1]];
    
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
    if (imagesName.count == 0) {return;}
    
    arrayWithImages = [NSMutableArray new];
    for (NSString *imageName in imagesName) {
        UIImage *image= [UIImage imageNamed:[imageName stringByAppendingString:@".jpg"]];
        if(image)
            [arrayWithImages addObject:image];
    }
    
    [self.exerciseImageView setImage:arrayWithImages[0]];
    
    if (animationTimer.isValid) {
        [animationTimer invalidate];
    }
    
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animateImages:) userInfo:nil repeats:true];
    [self animateImages:animationTimer];
    
    [self.playPauseButton setTitle:exercisePaused ? @"Play" : @"Pause"];
}

-(void)animateImages:(NSTimer *)timer{
    currentImageIndex++;
    if (currentImageIndex == arrayWithImages.count) {
        currentImageIndex = 0;
    }
    
    [self.exerciseImageView setImage:arrayWithImages[currentImageIndex]];
    workoutCurrentTime++;
    
    if (workoutCurrentTime == workoutData.duration) {
        //workout done
        [timer invalidate];
        [self presentControllerWithName:@"WorkoutDoneController" context:@(workoutData.kcal)];
        return;
    }
    
    NSInteger elapsedTime = workoutData.duration - workoutCurrentTime;
    NSInteger workoutElapsedMinutes = elapsedTime / 60;
    NSInteger workoutElapsedSeconds = elapsedTime % 60;
    [self.workoutTimeLabel setText:[NSString stringWithFormat:@"%.2ld:%.2ld", (long)workoutElapsedMinutes, (long)workoutElapsedSeconds]];
    
    NSInteger exerciseTime = workoutData.duration / workoutData.exercises.count;
    NSInteger exerciseElapsedMinutes = elapsedTime / exerciseTime / 60;
    NSInteger exerciseElapsedSeconds = elapsedTime % exerciseTime;
    [self.exerciseTimeLabel setText:[NSString stringWithFormat:@"%.2ld:%.2ld", (long)exerciseElapsedMinutes, (long)exerciseElapsedSeconds]];
    
    NSInteger screenWidth = [Utils sharedInstance].isWatch48MM ? 66 : 46;
    
    float percents = (float)abs(exerciseElapsedSeconds-exerciseTime) / (float)exerciseTime;
    CGFloat exerciseProgress = (float)screenWidth * percents;
    [self.exerciseProgressGroup setWidth:exerciseProgress];
    
    CGFloat currentProgress = (float)screenWidth * (float)workoutCurrentTime / (float)workoutData.duration;
    [self.currentProgressGroup setWidth:currentProgress];
    
    if (workoutCurrentTime % (workoutData.duration/workoutData.repeats) == 0) {
        // rest time
        [timer invalidate];
        NSString *nextExerciseName = workoutData.exercises[0].name;
        [self presentControllerWithName:@"RestTimeController" context:nextExerciseName.localized];
        [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeNotification];
    }else if(exerciseElapsedSeconds == 0){
        [self moveToNextExercise];
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
    NSInteger exerciseIndex = (workoutCurrentTime / (workoutData.duration / workoutData.exercises.count)) - 1;
    
    if (exerciseIndex < 0) {
        //return if first round and exercise
        return;
    }
    
    [self setNewExercise:exerciseIndex];
}

- (IBAction)nextExerciseAction {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    currentImageIndex = 0;
    NSInteger exerciseIndex = (workoutCurrentTime / (workoutData.duration / workoutData.exercises.count)) + 1;
    
    if (exerciseIndex > workoutData.exercises.count-1) {
        //return if last round and exercise
        return;
    }
    
    [self setNewExercise:exerciseIndex];
}

-(void)moveToNextExercise{
    [[WKInterfaceDevice currentDevice] playHaptic:WKHapticTypeNotification];
    
    currentImageIndex = 0;

    NSInteger exerciseIndex = (workoutCurrentTime / (workoutData.duration / workoutData.exercises.count));
    
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
    NSInteger exerciseTime = workoutData.duration / workoutData.exercises.count;
    workoutCurrentTime = exerciseTime * exerciseIndex;
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
        
        [self.exerciseImageView setImage:arrayWithImages[currentImageIndex]];
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
