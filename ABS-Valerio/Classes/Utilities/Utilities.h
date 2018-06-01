#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+ (NSString *)getLibraryDirectory;
+(NSMutableArray*)getSupersetsArray:(BOOL)oneExercise;

+(void)saveBOOLToUserDefaults:(BOOL)status withKey:(NSString*)key;
+(BOOL)getBOOLFromUserDefaults:(NSString*)key;
+(BOOL)hasSafeArea;


@end
