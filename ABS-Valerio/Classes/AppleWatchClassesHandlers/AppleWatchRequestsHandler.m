#import "AppleWatchRequestsHandler.h"
#import "Eercise.h"
#import "Workout.h"
#import "Repetitions.h"
#import "Photos.h"

@implementation AppleWatchRequestsHandler

+(void)getDictWithImagesForWathcKit:(NSString*)imagesPath withCompletionHandler:(void(^)(id result))completionMethod{
      completionMethod([self getImagesFromPath:imagesPath]);
}

#pragma mark - Super Sets Parsers

+(void)getSuperSetsInformation:(NSArray*)workoutSets withCompletionHandler:(void(^)(id result))completionMethod{
    NSMutableArray* arrayWithSetsInformation=[NSMutableArray new];
    for(int i=0;i<[workoutSets count];i++){
        [arrayWithSetsInformation addObject:[self getWorkoutInfo:workoutSets[i]]];
    }
    completionMethod(arrayWithSetsInformation);
}

+(NSDictionary*)getWorkoutInfo:(Workout*)currentWorkout{
    NSDictionary* workoutInfo=@{@"name":currentWorkout.title,@"circles":currentWorkout.circles,@"recoveyMode":currentWorkout.recoveryMode};
    NSMutableArray* exercisesArray=[NSMutableArray new];
    for(Eercise* currentExercise in currentWorkout.exercise){
        NSMutableDictionary* dictWithImages=[NSMutableDictionary new];
        if(currentExercise.descriptionLink){
            for(Photos* photo in currentExercise.photos){
                dictWithImages=[self getCustomImage:photo.photoLink];
                break;
            }
        }else{
           dictWithImages=[self getImagesFromPath:[self getPartialPath:currentExercise.link]];
        }
        NSMutableDictionary* repetitionInfoDict=[NSMutableDictionary new];
        for(Repetitions* rep in currentExercise.reps){
            repetitionInfoDict[rep.sort]=rep.repetitions;
          
        }
        NSDictionary* exerciseInfo=@{@"customType":currentExercise.isCustom,@"images":dictWithImages,@"sort":currentExercise.sort,@"name":currentExercise.title,@"repetitions":repetitionInfoDict};
        [exercisesArray addObject:exerciseInfo];
    }
    NSDictionary* currentWorkoutInfoDict=@{@"workout":workoutInfo,@"exercises":exercisesArray};
    return currentWorkoutInfoDict;
}

+(NSString*)getPartialPath:(NSString*)completePath{
    NSRange r1 =[completePath rangeOfString:@"/Default/"];
    NSRange rSub = NSMakeRange(r1.location, [completePath length]-r1.location);
    NSString *subString = [completePath substringWithRange:rSub];
    return subString;
}

#pragma mark - Get Images Methods

+(NSMutableDictionary*)getImagesFromPath:(NSString*)imagesPath{
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [bundlePath stringByAppendingString:imagesPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:path error:nil];
    NSMutableDictionary* dictWithImages=[NSMutableDictionary new];
    for (int i =0 ; i<fileList.count-2; i++){ //filelist.count-2  couse last image is description of muscles that works + description.txt || on super setes i=1 dont forget
        if ([[fileList[i] pathExtension] isEqualToString:@"jpg"]) {
            UIImage* tempImage=[UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:fileList[i]]];
            NSData* data=UIImageJPEGRepresentation(tempImage, 0.3);
            NSString* imageName=[[fileList[i] lastPathComponent]stringByDeletingPathExtension];
            dictWithImages[[imageName stringByReplacingOccurrencesOfString:@"@2x" withString:@""]]=data;
        }
    }
    return dictWithImages;
}

+(NSMutableDictionary*)getCustomImage:(NSString*)path{
    NSMutableDictionary* dictWithImages=[NSMutableDictionary new];
    UIImage* tempImage=[UIImage imageWithContentsOfFile:path];
    if(!tempImage){
        tempImage=[UIImage imageNamed:@"no-photo.png"];
    }
    NSData* data=UIImageJPEGRepresentation(tempImage, 1);
    NSString* imageName=[[path lastPathComponent]stringByDeletingPathExtension];
    dictWithImages[[imageName stringByReplacingOccurrencesOfString:@"@2x" withString:@""]]=data;
    return dictWithImages;
}

+(void)getCustomWorkoutsWithCompletionHandler:(void (^)(id))completionMethod{
//    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *urlPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSData *sqlData = [NSData dataWithContentsOfFile:[urlPath.path stringByAppendingPathComponent:@"ABS-Valerio-DB.sqlite"]];
    NSData *shmData = [NSData dataWithContentsOfFile:[urlPath.path stringByAppendingPathComponent:@"ABS-Valerio-DB.sqlite-shm"]];
    NSData *walData = [NSData dataWithContentsOfFile:[urlPath.path stringByAppendingPathComponent:@"ABS-Valerio-DB.sqlite-wal"]];

//    completionMethod(@{@"sql": sqlData,
//                       kLastCoreDataChangeKey: @([[NSUserDefaults standardUserDefaults] doubleForKey:kLastCoreDataChangeKey]),
//                       @"path": urlPath.path});
    completionMethod(@{@"sql": sqlData,
                       @"shm": shmData,
                       @"wal": walData,
                       kLastCoreDataChangeKey: @([[NSUserDefaults standardUserDefaults] doubleForKey:kLastCoreDataChangeKey]),
                       @"path": urlPath.path});
}

//-(void)showExercie:(id)workout{
//
//    Workout* work=workout;
//    NSLog(@" WORKOUT ###################: %@ \n %@ \n%@ ",work.circles,work.title,work.recoveryMode);
//
//    for(Eercise* exe in work.exercise){
//         NSLog(@"EXERCISE #################: %@ \n%@\n %@\n %@ \n%@",exe.descriptionLink,exe.isCustom,exe.link,exe.sort,exe.title);
//        for(Repetitions* rep in exe.reps){
//            NSLog(@"REPETITION ################: %@ \n%@\n",rep.repetitions,rep.sort);
//        }
//        for(Photos* photo in exe.photos)
//            NSLog(@"PHOTOS ##############: %@\n %@ ",photo.photoLink,photo.sort);
//
//
//    }
//
//}

@end
