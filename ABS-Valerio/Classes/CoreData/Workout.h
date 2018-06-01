#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Eercise;

@interface Workout : NSManagedObject

@property (nonatomic, retain) NSNumber * circles;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * recoveryMode;
@property (nonatomic, retain) NSSet *exercise;

@end

@interface Workout (CoreDataGeneratedAccessors)

- (void)addExerciseObject:(Eercise *)value;
- (void)removeExerciseObject:(Eercise *)value;
- (void)addExercise:(NSSet *)values;
- (void)removeExercise:(NSSet *)values;

@end
