#import "WorkoutData+SQL.h"
#import "FMDB.h"

@implementation WorkoutData (SQL)

+(NSArray<WorkoutData *> *)workOutsFromDB{
    FMDatabase *db = [[FMDatabase alloc] initWithPath: [self dbPath]];
    if (![db open]) {
        [db open];
    }
    NSMutableArray<WorkoutData*> *resultArray = [NSMutableArray array];
    
    NSString *query = @"select * from ZWORKOUT";
    FMResultSet *result = [db executeQuery:query];
    while ([result next]) {
        NSDictionary *dict = [result resultDictionary];
        WorkoutData *workoutData = [WorkoutData new];
        
        workoutData.name = dict[@"ZTITLE"];
        workoutData.repeats = [dict[@"ZCIRCLES"] integerValue];
        workoutData.recoveryMode = [dict[@"ZRECOVERYMODE"] integerValue];
        NSNumber *workoutId = dict[@"Z_PK"];
        workoutData.duration = [self workoutDurationForId:workoutId];
        workoutData.exercises = [self exercisesForWorkoutId:workoutId repeats:workoutData.repeats];
        
        [resultArray addObject: workoutData];
    }
    
    [db close];
    return resultArray;
}

+(NSArray<ExerciseData*> *)exercisesForWorkoutId:(NSNumber *)workoutId repeats:(NSInteger)repeats{
    NSMutableArray *exercisesArray = [NSMutableArray array];
    
    FMDatabase *db = [[FMDatabase alloc] initWithPath: [self dbPath]];
    if (![db open]) {
        [db open];
    }
    
    NSString *exerciseQuery = [NSString stringWithFormat:@"select * from ZEERCISE where ZWORKOUT=%@", workoutId];
    FMResultSet *result = [db executeQuery:exerciseQuery];
    while ([result next]) {
        NSDictionary *dict = [result resultDictionary];
        NSNumber *exerciseId = dict[@"Z_PK"];
        NSArray<ExerciseData*> *exercises = [self createExerciseDataForExerciseId:exerciseId exerciseDict:dict];
        for (ExerciseData *exerciseData in exercises) {
            if (!exerciseData.isCustom) {
                NSArray<NSString*> *images = [self imagesForExercisePath:dict[@"ZLINK"]];
                exerciseData.imagesName = images;
            }else{
                NSArray<NSString*> *images = [self imagesForCustomExercise:exerciseId];
                exerciseData.imagesName = images;
            }
        }
        [exercisesArray addObjectsFromArray:exercises];
    }
    
    [db close];
    
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (int i=0; i<repeats; i++) {
        for (int y=0; y<exercisesArray.count/repeats; y++) {
            NSInteger newIndex = i + y * repeats;
            [resultArray addObject:exercisesArray[newIndex]];
        }
    }
    
    return resultArray;
}

+(NSArray<ExerciseData*> *)createExerciseDataForExerciseId:(NSNumber *)exerciseId exerciseDict:(NSDictionary *)exerciseDict{
    NSMutableArray<ExerciseData*> *resultArray = [NSMutableArray array];
    
    FMDatabase *db = [[FMDatabase alloc] initWithPath: [self dbPath]];
    if (![db open]) {
        [db open];
    }
    
    NSString *exerciseQuery = [NSString stringWithFormat:@"select * from ZREPETITIONS where ZEXERCISE=%@ order by ZSORT", exerciseId];
    FMResultSet *result = [db executeQuery:exerciseQuery];
    while ([result next]) {
        NSDictionary *dict = [result resultDictionary];
        
        ExerciseData *exerciseData = [ExerciseData new];
        exerciseData.name = exerciseDict[@"ZTITLE"];
        exerciseData.isCustom = [exerciseDict[@"ZISCUSTOM"] boolValue];
        exerciseData.duration = [dict[@"ZREPETITIONS"] integerValue] * 2;
        [resultArray addObject:exerciseData];
    }
    
    [db close];
    return resultArray;
}

+(NSInteger)workoutDurationForId:(NSNumber *)workoutId{
    NSInteger workoutDuration = 0;
    FMDatabase *db = [[FMDatabase alloc] initWithPath: [self dbPath]];
    if (![db open]) {
        [db open];
    }
    
    NSString *exerciseQuery = [NSString stringWithFormat:@"select sum(R.ZREPETITIONS)*2 as duration from ZWORKOUT as W inner join  ZEERCISE as E on W.Z_PK=E.ZWORKOUT inner join ZREPETITIONS as R on E.Z_PK=R.ZEXERCISE where W.Z_PK=%@", workoutId];
    FMResultSet *result = [db executeQuery:exerciseQuery];
    while ([result next]) {
        NSDictionary *dict = [result resultDictionary];
        @try {
            workoutDuration = [dict[@"duration"] integerValue];
        } @catch (NSException *exception) {}
    }
    
    [db close];
    return workoutDuration;
}

+(NSArray<NSString*> *)imagesForExercisePath:(NSString *)exercisePath{
    NSString *exerciseName = exercisePath.lastPathComponent;
    NSString *categoryName = exercisePath.stringByDeletingLastPathComponent.lastPathComponent;
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Exercises" ofType:@"plist"];
    NSArray *exercisesFromPlist = [NSDictionary dictionaryWithContentsOfFile:plistPath][@"ExercisesType"];
    
    NSArray *imagesArray;
    for (id obj in exercisesFromPlist) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = obj;
            imagesArray = dict[[self newPlistKey:categoryName]][exerciseName];
            if (imagesArray.count>0) {
                break;
            }
        }
    }
    
    return imagesArray;
}

+(NSArray<NSString*> *)imagesForCustomExercise:(NSNumber *)exerciseId{
    NSMutableArray *imagesArray = [NSMutableArray array];
    
    FMDatabase *db = [[FMDatabase alloc] initWithPath: [self dbPath]];
    if (![db open]) {
        [db open];
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT ZPHOTOLINK FROM ZPHOTOS where ZEXERCISE=%@ order by ZSORT", exerciseId];
    FMResultSet *result = [db executeQuery:query];
    while ([result next]) {
        NSDictionary *dict = [result resultDictionary];
        NSString *pathImage = dict[@"ZPHOTOLINK"];
        NSString *imageName = pathImage.lastPathComponent;
        if ([imageName isEqualToString:@"no-photo.png"]) {
            continue;
        }
        [imagesArray addObject:imageName];
    }
    
    [db close];
    return imagesArray;
}

+(NSString *)newPlistKey:(NSString *)key{
    NSDictionary *keys = @{@"Easy": @"Beginner", @"Hard": @"Advanced", @"Medium": @"Intermediate", @"With Accessories": @"Strong ABS"};
    return keys[key];
}

+(NSString *)dbPath{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"ABS-Valerio-DB.sqlite"];
}

@end
