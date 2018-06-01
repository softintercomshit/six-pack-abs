#import "WorkoutsController.h"
#import "ExerciseTypesRow.h"
#import "Utils.h"
#import "WorkoutData.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"


@interface WorkoutsController()

@property (weak, nonatomic) IBOutlet WKInterfaceTable *exercisesTypesTable;

@end

@implementation WorkoutsController{
    NSMutableArray<WorkoutData*> *workoutsArray;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    NSArray *workoutsFromPlist = [Utils extractDataFromPlist][4];
    
    for (NSDictionary *workoutDict in workoutsFromPlist) {
        if (!workoutsArray) {workoutsArray = [NSMutableArray array];}
        
        WorkoutData *workoutData = [[WorkoutData alloc] initWithDict:workoutDict];
        [workoutsArray addObject:workoutData];
    }
    
    [self configureTableWithWorkoutData:workoutsArray];
    
    [self setTitle:@"workouts".localized.capitalizedString];
}

- (void)configureTableWithWorkoutData:(NSArray<WorkoutData*>*)dataObjects {
    [self.exercisesTypesTable setNumberOfRows:[dataObjects count] withRowType:@"ExerciseTypesRow"];
    for (NSInteger i = 0; i < self.exercisesTypesTable.numberOfRows; i++) {
        ExerciseTypesRow* exerciseRow = [self.exercisesTypesTable rowControllerAtIndex:i];
        [exerciseRow.exerciseName setText: dataObjects[i].name.localized];
        [exerciseRow.rowGroup setBackgroundImage:[UIImage imageNamed:@"exerciseCellRed"]];
    }
}


-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    [self pushControllerWithName:@"WorkoutsExercisesController" context: workoutsArray[rowIndex]];
}

@end
