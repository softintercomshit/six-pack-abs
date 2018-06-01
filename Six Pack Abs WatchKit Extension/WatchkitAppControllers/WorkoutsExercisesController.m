#import "WorkoutsExercisesController.h"
#import "ExerciseTypesRow.h"
#import "WorkoutData.h"
#import "HeaderRow.h"
#import "Utils.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"


static NSString *const headerRowIdentifier = @"HeaderRow";
static NSString *const exerciseRowIdentifier = @"ExerciseTypesRow";

@interface WorkoutsExercisesController()

@property (weak, nonatomic) IBOutlet WKInterfaceTable *exercisesTypesTable;

@end

@implementation WorkoutsExercisesController{
    WorkoutData *workoutData;
    NSArray<NSString*> *arrayWithIdentifiers;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    workoutData = context;
    [self createIdentifiersArray];
    
    [self configureTableWithWorkoutData:workoutData.exercises];
    
    [self setTitle: workoutData.name.localized];
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
            
            NSString *imageName = dataObjects[exerciseIndex].imagesName[0];
            UIImage *image= [UIImage imageNamed:[imageName stringByAppendingString:@".jpg"]];
            image = [Utils changeWhiteColorTransparent:image];
            [exerciseRow.exerciseImageGroup setBackgroundImage:image];
        }
    }];
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    if ([arrayWithIdentifiers[rowIndex] isEqualToString:headerRowIdentifier]) {
        return;
    }
    NSInteger round = rowIndex/(workoutData.exercises.count/workoutData.repeats+1);
    NSInteger exerciseIndex = rowIndex-(round+1);
    [self pushControllerWithName:@"WorkoutExercise" context: @{@"workout": workoutData, @"exerciseIndex": @(exerciseIndex)}];
}
@end
