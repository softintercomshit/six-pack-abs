#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Eercise;

@interface Photos : NSManagedObject

@property (nonatomic, retain) NSString * photoLink;
@property (nonatomic, retain) NSNumber * sort;
@property (nonatomic, retain) Eercise *exercise;

@end
