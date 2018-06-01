#import "Utils.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface Utils () <WCSessionDelegate>

@end

@implementation Utils
BOOL watchIs48MM;


+(instancetype)sharedInstance{
    static Utils *sharedInstance = nil;
    static dispatch_once_t onceToken;dispatch_once(&onceToken, ^{
        sharedInstance=[Utils new];
        [sharedInstance openWatchConnection];
        watchIs48MM=[self setWatchType];
    });
    return sharedInstance;
}

+(BOOL)setWatchType{
    CGRect watchScreenRect=[[WKInterfaceDevice currentDevice] screenBounds];
    if(watchScreenRect.size.width>136){
        return YES;
    }
    return NO;
}

-(void)openWatchConnection{
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

-(void)getImagesFromMainAPP:(NSString*)imagePath withBlock:(void (^)(id result))completionHandler{
    NSDictionary* userInfo=@{@"imagesPath":imagePath};
    [self getInformationFromParentApp:userInfo withReciveBlock:^(NSDictionary *dataDictionary) {
        completionHandler(dataDictionary[@"images"]);
    }];
}

-(void)getSuperSetsValues:(void (^)(id result))completionHandler{
    NSDictionary* userInfo=@{@"superSetValue":@"1"};
    [self getInformationFromParentApp:userInfo withReciveBlock:^(NSDictionary *dataDictionary) {
        completionHandler(dataDictionary[@"superSetsInfo"]);
    }];
}

-(void)getInformationFromParentApp:(NSDictionary*)userInfo withReciveBlock:(void (^)(NSDictionary* dataDictionary))getInfoDict{
   [[WCSession defaultSession] sendMessage:userInfo replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
       getInfoDict(replyMessage);
   } errorHandler:^(NSError * _Nonnull error) {
       
   }];
}



+(NSArray*)extractDataFromPlist{
    NSDictionary *exercisesData = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Exercises" ofType:@"plist"]];
    return exercisesData[@"ExercisesType"];// Put dict to array for sorting
}

-(BOOL)isWatch48MM{
    return watchIs48MM;
}

+(UIImage *)changeWhiteColorTransparent: (UIImage *)image{
    CGImageRef rawImageRef=image.CGImage;
    
    const float colorMasking[6] = {222, 255, 222, 255, 222, 255};
    
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        //if in iphone
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();
    return result;
}

@end
