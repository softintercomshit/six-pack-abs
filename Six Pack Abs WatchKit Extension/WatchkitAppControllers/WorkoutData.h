#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RecoveryMode){
    Every2Exercises,
    Every3Exercises,
    EveryCircle,
    NoRecovery
};

@interface ExerciseData : NSObject

@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSArray<NSString*> *imagesName;
@property(nonatomic) BOOL isCustom;
@property(nonatomic) NSInteger duration;

-(ExerciseData *)initWithDict:(NSDictionary *)dict exerciseName:(NSString *)exerciseName;

@end


@interface WorkoutData : NSObject

@property(strong, nonatomic) NSString *name;
@property(nonatomic) NSInteger duration;
@property(nonatomic) NSInteger repeats;
@property(nonatomic) NSInteger kcal;
@property(nonatomic) RecoveryMode recoveryMode;
@property(strong, nonatomic) NSArray<ExerciseData*> *exercises;

-(WorkoutData *)initWithDict:(NSDictionary *)dict;

@end
