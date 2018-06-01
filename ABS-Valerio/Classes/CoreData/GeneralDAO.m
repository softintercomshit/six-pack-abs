#import "GeneralDAO.h"
#import "Workout.h"
#import "Eercise.h"

@implementation GeneralDAO


+(NSArray*)getAllexercises{
//    NSLog(@"%@",[self getEntityContent:@"Workout"]);
    return [self getEntityContent:@"Workout"];
}


+(NSArray*)getExercises{
//    NSLog(@"%@",[self getEntityContent:@"Eercise"]);
    return [self getEntityContent:@"Eercise"];
}


+(NSArray*)getEntityContent:(NSString*)entityName{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
//    [fetchRequest setPredicate:searchPredicate];
    NSArray *fetchedObjects = [[DataAccessLayer sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return  fetchedObjects;
}


@end
