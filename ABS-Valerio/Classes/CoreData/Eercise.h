#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photos, Repetitions, Workout;

@interface Eercise : NSManagedObject

@property (nonatomic, retain) NSString * descriptionLink;
@property (nonatomic, retain) NSNumber * isCustom;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *reps;
@property (nonatomic, retain) Workout *workout;

@end

@interface Eercise (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photos *)value;
- (void)removePhotosObject:(Photos *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addRepsObject:(Repetitions *)value;
- (void)removeRepsObject:(Repetitions *)value;
- (void)addReps:(NSSet *)values;
- (void)removeReps:(NSSet *)values;

@end
