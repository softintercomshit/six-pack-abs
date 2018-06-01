#import "Utilities.h"
#import "GuideAppDelegate.h"

@implementation Utilities


+ (NSString *)getLibraryDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}


+(NSMutableArray*)getSupersetsArray:(BOOL)oneExercise{
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [bundlePath stringByAppendingString:@"/GuidePrograms"];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSMutableArray *fileList = (NSMutableArray*) [manager contentsOfDirectoryAtPath:path error:nil];
    NSString *work = [fileList objectAtIndex:1];
    [fileList removeObjectAtIndex:1];
    [fileList addObject:work];
    NSMutableArray* typeArray = [NSMutableArray array];
    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
        for (int i =0 ; i<fileList.count; i++){
            if(oneExercise && [self string:fileList[i] containsString:@"99 Six Pack ABS"]){
                return [@[@{@"path":[path stringByAppendingPathComponent:[fileList objectAtIndex:i]]}] mutableCopy];
            }else if(![self string:fileList[i] containsString:@"99 Six Pack ABS"]){
                [typeArray addObject:@{@"path":[path stringByAppendingPathComponent:[fileList objectAtIndex:i]]}];
            }
        }
    }else{
        for (int i =0 ; i<fileList.count; i++){
            if(oneExercise && [fileList[i] containsString:@"99 Six Pack ABS"]){
                return [@[@{@"path":[path stringByAppendingPathComponent:[fileList objectAtIndex:i]]}] mutableCopy];
            }else if(![fileList[i] containsString:@"99 Six Pack ABS"]){
                [typeArray addObject:@{@"path":[path stringByAppendingPathComponent:[fileList objectAtIndex:i]]}];
            }
        }
    }
    return typeArray;
}


+(void)saveBOOLToUserDefaults:(BOOL)status withKey:(NSString*)key{
    [[NSUserDefaults standardUserDefaults] setBool:status forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+(BOOL)getBOOLFromUserDefaults:(NSString*)key{
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+ (BOOL)string:(NSString *)inputString containsString:(NSString*)other {
    NSRange range = [inputString rangeOfString:other];
    return range.length != 0;
}

+(BOOL)hasSafeArea {
    if (@available(iOS 11.0, *)) {
        GuideAppDelegate *appDelegate = (GuideAppDelegate *)[UIApplication sharedApplication].delegate;
        NSArray<NSNumber *> *safeArreaInsets = @[@(appDelegate.window.safeAreaInsets.top), @(appDelegate.window.safeAreaInsets.bottom), @(appDelegate.window.safeAreaInsets.left), @(appDelegate.window.safeAreaInsets.right)];
        NSNumber *maxNumber = [safeArreaInsets valueForKeyPath:@"@max.self"];
        
        return maxNumber.floatValue > 0;
    }
    
    return false;
}

@end
