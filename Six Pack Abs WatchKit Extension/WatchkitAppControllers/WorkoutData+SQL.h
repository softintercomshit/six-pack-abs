#import "WorkoutData.h"

@interface WorkoutData (SQL)

+(NSArray<WorkoutData*>*)workOutsFromDB;

@end
