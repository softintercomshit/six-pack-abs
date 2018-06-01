#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@protocol UtilsDelegate <NSObject>

//-(void)

@end


@interface Utils : NSObject

+(instancetype)sharedInstance;
+(NSArray*)extractDataFromPlist;
+(UIImage *)changeWhiteColorTransparent: (UIImage *)image;

-(BOOL)isWatch48MM;
-(void)getImagesFromMainAPP:(NSString*)imagePath withBlock:(void (^)(id result))completionHandler;
-(void)getSuperSetsValues:(void (^)(id result))completionHandler;

@end
