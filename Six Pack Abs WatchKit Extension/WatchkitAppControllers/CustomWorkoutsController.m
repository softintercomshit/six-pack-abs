#import "CustomWorkoutsController.h"
#import "ExerciseTypesRow.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "WorkoutData.h"
#import "WorkoutData+SQL.h"
#import "AppConstants.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"


@interface CustomWorkoutsController()<WCSessionDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *exercisesTypesTable;

@end

@implementation CustomWorkoutsController{
    NSArray<WorkoutData*> *workoutDataArray;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self reloadData];
    
    [self openWatchConnection];
    
    double timestamp = [[NSUserDefaults standardUserDefaults] doubleForKey:kLastCoreDataChangeKey];
    
    [[WCSession defaultSession] sendMessage:@{@"customWorkouts": @(true), kLastCoreDataChangeKey: @(timestamp)} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setDouble:[replyMessage[kLastCoreDataChangeKey] doubleValue] forKey:kLastCoreDataChangeKey];
        [defaults synchronize];
    } errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
    
    [self setTitle: @"customItemKey".localized.capitalizedString];
}
    
- (void)willActivate {
    [super willActivate];
}

-(void)openWatchConnection{
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = self;
//        [session activateSession];
        if (session.activationState != WCSessionActivationStateActivated) {
            [session activateSession];
        }
    }
}

-(NSArray *)imagesToCopy{
    NSMutableSet *set = [NSMutableSet set];
    for (WorkoutData *workout in workoutDataArray) {
        for (ExerciseData *exercise in workout.exercises) {
            if (exercise.isCustom) {
                [set addObjectsFromArray:exercise.imagesName];
            }
        }
    }
    
    NSMutableArray *imagesNameArray = [NSMutableArray array];
    for (NSString *imageName in set.allObjects) {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *imagePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"images/%@", imageName]];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if (!image) {
            [imagesNameArray addObject:imageName];
        }
    }
    return imagesNameArray;
}

-(void)reloadData{
    workoutDataArray = [WorkoutData workOutsFromDB];
    [self configureTableWithWorkoutData:workoutDataArray];
}

-(void)session:(WCSession *)session didReceiveFile:(WCSessionFile *)file {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSArray *array = [NSArray arrayWithContentsOfURL:file.fileURL];
    
    for (NSDictionary *dict in array) {
        NSString *fileName = dict[@"name"];
        NSData *sqlData = dict[@"data"];
        [sqlData writeToFile:[documentsPath stringByAppendingPathComponent:fileName] atomically:YES];
    }
    [self reloadData];
    
    [[NSFileManager defaultManager] removeItemAtURL:file.fileURL error:nil];
}

//-(void)session:(WCSession *)session didReceiveFile:(WCSessionFile *)file {
//    NSString *fileType = file.metadata[@"fileType"];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    NSArray *array = [NSArray arrayWithContentsOfURL:file.fileURL];
//    
//    if ([fileType isEqualToString:@"image"]) {
//        [fileManager createDirectoryAtPath:[documentsPath stringByAppendingPathComponent:@"images"] withIntermediateDirectories:false attributes:nil error:nil];
//        
//        for (NSDictionary *dict in array) {
//            NSString *imageName = dict[@"name"];
//            NSData *imageData = dict[@"data"];
//            [imageData writeToFile:[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"images/%@", imageName]] atomically:YES];
//        }
//    }else{
//        for (NSDictionary *dict in array) {
//            NSString *fileName = dict[@"name"];
//            NSData *sqlData = dict[@"data"];
//            [sqlData writeToFile:[documentsPath stringByAppendingPathComponent:fileName] atomically:YES];
//        }
//        [self reloadData];
//    }
//}

- (void)configureTableWithWorkoutData:(NSArray<WorkoutData*>*)dataObjects {
    [self.exercisesTypesTable setNumberOfRows:[dataObjects count] withRowType:@"ExerciseTypesRow"];
    for (NSInteger i = 0; i < self.exercisesTypesTable.numberOfRows; i++) {
        ExerciseTypesRow* exerciseRow = [self.exercisesTypesTable rowControllerAtIndex:i];
        [exerciseRow.exerciseName setText: dataObjects[i].name];
        [exerciseRow.rowGroup setBackgroundImage:[UIImage imageNamed:@"exerciseCellRed"]];
    }
}
    
-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    [self pushControllerWithName:@"CustomWorkoutsExercisesController" context:workoutDataArray[rowIndex]];
}
    
//- (IBAction)addNewWorkout {
//    [self pushControllerWithName:@"NewWorkoutController" context:nil];
//}

@end
