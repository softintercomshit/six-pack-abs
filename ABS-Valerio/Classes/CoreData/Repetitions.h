#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Eercise;

@interface Repetitions : NSManagedObject

@property (nonatomic, retain) NSNumber * repetitions;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) Eercise *exercise;

@end
