#import "WorkoutData.h"

@implementation WorkoutData

-(WorkoutData *)initWithDict:(NSDictionary *)dict{
    self.name = dict.allKeys.firstObject;
    NSDictionary *workoutDict = dict[self.name];
    
    NSMutableArray *tmpExercisesArray = [NSMutableArray array];
    if (workoutDict[@"exercises"]) {
        self.exercises = [[self exercisesArrayFromDict:workoutDict[@"exercises"]] mutableCopy];
    }
    
    if (workoutDict[@"duration"]) {
        self.duration = [workoutDict[@"duration"] integerValue];
    }
    
    if (workoutDict[@"kcal"]) {
        self.kcal = [workoutDict[@"kcal"] integerValue];
    }
    
    if (workoutDict[@"repeats"]) {
        self.repeats = [workoutDict[@"repeats"] integerValue];
    }
    
    for (int i = 0; i<self.repeats; i++) {
        [tmpExercisesArray addObjectsFromArray:self.exercises];
    }
    self.exercises = tmpExercisesArray;

    return self;
}

-(NSArray<ExerciseData*>*)exercisesArrayFromDict:(NSDictionary *)dict{
    NSMutableArray<ExerciseData*> *resultArray = [NSMutableArray array];
    
    for (NSString *key in dict) {
        NSDictionary *exerciseDict = dict[key];
        ExerciseData *exerciseData = [[ExerciseData alloc] initWithDict:exerciseDict exerciseName:key];
        [resultArray addObject:exerciseData];
    }
    
    return resultArray;
}

@end


@implementation ExerciseData

-(ExerciseData *)initWithDict:(NSDictionary *)dict exerciseName:(NSString *)exerciseName{
    self.name = exerciseName;
    self.imagesName = dict[@"images"];
    return self;
}

@end
