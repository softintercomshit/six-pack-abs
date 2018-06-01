#import <Foundation/Foundation.h>

@interface AppleWatchRequestsHandler : NSObject

+(void)getDictWithImagesForWathcKit:(NSString*)imagesPath withCompletionHandler:(void(^)(id result))completionMethod;
+(void)getSuperSetsInformation:(NSArray*)workoutSets withCompletionHandler:(void(^)(id result))completionMethod;
+(void)getCustomWorkoutsWithCompletionHandler:(void(^)(id result))completionMethod;

@end
