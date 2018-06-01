#import "CustomWorkoutsExercisesController.h"
#import "WorkoutData.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"
#import "HeaderRow.h"
#import "ExerciseTypesRow.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "Utils.h"

static NSString *const headerRowIdentifier = @"HeaderRow";
static NSString *const exerciseRowIdentifier = @"ExerciseTypesRow";

@interface CustomWorkoutsExercisesController()

@property (weak, nonatomic) IBOutlet WKInterfaceTable *exercisesTypesTable;

@end

@implementation CustomWorkoutsExercisesController{
    WorkoutData *workoutData;
    NSInteger selectedRowIndex;
    NSArray<NSString*> *arrayWithIdentifiers;
    BOOL didSelectWasPressed;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressControllerDismissed) name:@"progressControllerDismissed" object:nil];
    
    workoutData = context;
    [self createIdentifiersArray];
    
    [self configureTableWithWorkoutData:workoutData.exercises];
    
    [self setTitle: workoutData.name.localized];
    
    NSArray *imagesToCopy = [self imagesToCopy];
    if (imagesToCopy.count > 0) {
        [self presentControllerWithName:@"ImagesProgressController" context:imagesToCopy];
    }
}

-(void)createIdentifiersArray{
    NSMutableArray<NSString*> *array = [NSMutableArray array];
    
    for (int i=0; i<workoutData.repeats; i++) {
        [array addObject:headerRowIdentifier];
        for (int y=0; y<workoutData.exercises.count/workoutData.repeats; y++) {
            [array addObject:exerciseRowIdentifier];
        }
    }
    arrayWithIdentifiers = array;
}

- (void)configureTableWithWorkoutData:(NSArray<ExerciseData*>*)dataObjects{
    [self.exercisesTypesTable setRowTypes:arrayWithIdentifiers];
    
    [arrayWithIdentifiers enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger round = idx/(workoutData.exercises.count/workoutData.repeats+1);
        
        if ([obj isEqualToString:headerRowIdentifier]) {
            HeaderRow *headerRow = [self.exercisesTypesTable rowControllerAtIndex:idx];
            [headerRow.roundLabel setText:[NSString stringWithFormat:@"%@ %d",@"roundKey".localized, round+1]];
        }else{
            ExerciseTypesRow* exerciseRow = [self.exercisesTypesTable rowControllerAtIndex:idx];
            NSInteger exerciseIndex = idx-(round+1);
            [exerciseRow.exerciseName setText: dataObjects[exerciseIndex].name.localized];
//            [exerciseRow.rowGroup setBackgroundImage:[UIImage imageNamed:@"exerciseCell"]];
            
            NSArray *imagesName = dataObjects[exerciseIndex].imagesName;
            NSString *imageName;
            if (imagesName.count > 0) {
                imageName = imagesName[0];
            }
            UIImage *image;
            if (!dataObjects[exerciseIndex].isCustom) {
                image = [UIImage imageNamed:[imageName stringByAppendingString:@".jpg"]];
                image = [Utils changeWhiteColorTransparent:image];
            }else{
                NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                NSString *imagePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"images/%@", imageName]];
                image = [UIImage imageWithContentsOfFile:imagePath];
            }
            if (image) {
                [exerciseRow.exerciseImageGroup setBackgroundImage:image];
            }
        }
    }];
}

-(NSArray *)imagesToCopy{
    NSMutableSet *set = [NSMutableSet set];
    for (ExerciseData *exercise in workoutData.exercises) {
        if (exercise.isCustom) {
            [set addObjectsFromArray:exercise.imagesName];
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

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    selectedRowIndex = rowIndex;
    didSelectWasPressed = true;
    
    NSArray *imagesToCopy = [self imagesToCopy];
    if (imagesToCopy.count > 0) {
        [self presentControllerWithName:@"ImagesProgressController" context:imagesToCopy];
    }else{
        if ([arrayWithIdentifiers[rowIndex] isEqualToString:headerRowIdentifier]) {
            return;
        }
        NSInteger round = rowIndex/(workoutData.exercises.count/workoutData.repeats+1);
        NSInteger exerciseIndex = rowIndex-(round+1);
        [self pushControllerWithName:@"CustomWorkoutExercise" context: @{@"workout": workoutData, @"exerciseIndex": @(exerciseIndex)}];
    }
}

-(void)progressControllerDismissed{
    if (didSelectWasPressed) {
        if ([arrayWithIdentifiers[selectedRowIndex] isEqualToString:headerRowIdentifier]) {
            return;
        }
        NSInteger round = selectedRowIndex/(workoutData.exercises.count/workoutData.repeats+1);
        NSInteger exerciseIndex = selectedRowIndex-(round+1);
        [self pushControllerWithName:@"CustomWorkoutExercise" context: @{@"workout": workoutData, @"exerciseIndex": @(exerciseIndex)}];
    }else{
        [self configureTableWithWorkoutData:workoutData.exercises];
    }
}
@end
