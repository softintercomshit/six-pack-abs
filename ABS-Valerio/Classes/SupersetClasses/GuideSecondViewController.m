#import "GuideSecondViewController.h"
#import "WorkoutExerciseTableView.h"
#import "SupersetsTableViewCell.h"
#import "DownloadVideoController.h"

@interface GuideSecondViewController () <UITableViewDelegate, UITableViewDataSource, DownloadVideosDelegate>
@property (strong, nonatomic) NSArray* caloriesArray;

@end

@implementation GuideSecondViewController{
    NSIndexPath *selectedIndexPath;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"workouts".localized;
    [self.navigationController.navigationBar setBebasFont];
    _typeArray = [[Utilities getSupersetsArray:NO] mutableCopy];
    [_tableView registerNib:[UINib nibWithNibName:@"SupersetsTableViewCell" bundle:nil] forCellReuseIdentifier:@"SupersetsTableViewCell"];
    _caloriesArray = @[@"50",@"80",@"63",@"71",@"85",@"78",@"73",@"78",@"110",@"75"];
}


#pragma mark - Get supersets information methods


-(NSDictionary *)extractDaysFoldersWithPath:(int)index{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString* pathString = [_typeArray objectAtIndex:index][@"path"];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:pathString error:nil];
    NSString *descriereFilePath = [pathString stringByAppendingPathComponent:@"DESCRIERE.txt"];
    
    NSString *descriereFileContent = [self readFile: descriereFilePath];
    NSArray* repsArray = [descriereFileContent componentsSeparatedByString:@"/"];
    float oneRoundTime = ([fileList count] - 1) * [[repsArray firstObject] intValue] * 2;
    float totalTime = (oneRoundTime * repsArray.count + (repsArray.count - 1) * 30) / 60.0 ;
    return @{@"totalTime":@(roundf(totalTime)),@"exerciseNumber": @([fileList count] - 1),@"calories":_caloriesArray[index]};
}


-(NSString *)readFile:(NSString *)filePath {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error= NULL;
        id resultData = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        if (error == NULL){
            return resultData;
        }
    }
    return NULL;
}



#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.typeArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SupersetsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SupersetsTableViewCell" forIndexPath:indexPath];
    [cell setSupersetValues:_typeArray[indexPath.row] withInformation:[self extractDaysFoldersWithPath:(int)indexPath.row]];
    return cell;
}


- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


#pragma mark - UITableViewDelegate


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  isIpad ? 150 : 100 ;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedIndexPath = indexPath;
    [self preparePushWorkoutExercise:(int)indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)pushWorkoutExercise:(int)indexPathRow{
    NSString *supersetPath = [_typeArray objectAtIndex:indexPathRow][@"path"];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WorkoutExerciseTableView *workoutExerciseControllers = [sb instantiateViewControllerWithIdentifier:@"WorkoutExerciseTableView"];
    workoutExerciseControllers.exercisesPath = supersetPath;
    NSString *title = [[_typeArray objectAtIndex:indexPathRow][@"path"] lastPathComponent];
    workoutExerciseControllers.title = title;
    [workoutExerciseControllers.navigationController.navigationBar setBebasFont];
    workoutExerciseControllers.hidesBottomBarWhenPushed = YES;
    NSDictionary *dict = [self extractDaysFoldersWithPath:indexPathRow];
    [workoutExerciseControllers setKcalories:[dict[@"calories"] integerValue]];
    [self.navigationController pushViewController:workoutExerciseControllers animated:YES];
}

-(void)preparePushWorkoutExercise:(int)indexPathRow{
    NSString *supersetPath = [_typeArray objectAtIndex:indexPathRow][@"path"];
    NSArray *missingVideosArray = [self missingExercisesFromSupersetFromPath:supersetPath];
    if (missingVideosArray.count != 0) {
        DownloadVideoController *downloadObj = [[DownloadVideoController alloc] initWithArrayOfVideoNames:missingVideosArray containerController:self];
        [downloadObj setDelegate:self];
        [downloadObj startDownload];
    }else{
        [self pushWorkoutExercise:indexPathRow];
    }
}

-(void)didFinishDownloadingWithPath:(NSString *)path{
    [self pushWorkoutExercise:(int)selectedIndexPath.row];
}

-(NSArray *)supersetexercisesArrayFromPath:(NSString *)supersetPath{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *supersetFiles = [manager contentsOfDirectoryAtPath:supersetPath error:nil];
    NSMutableArray *supersetexercisesArray = [NSMutableArray array];
    for (NSString *fileName in supersetFiles) {
        NSString *exercisePath = [supersetPath stringByAppendingPathComponent:fileName];
        bool isDir;
        if ([manager fileExistsAtPath:exercisePath isDirectory:&isDir]) {
            if (isDir) {
                NSDictionary *infopath = [NSDictionary dictionaryWithContentsOfFile:[exercisePath stringByAppendingPathComponent:@"infopath.plist"]];
                NSString *exerciseName = [infopath[@"infopath"] lastPathComponent];
                [supersetexercisesArray addObject:[exerciseName stringByAppendingString:@".mp4"]];
            }
        }
    }
    return supersetexercisesArray;
}

-(NSArray *)missingExercisesFromSupersetFromPath:(NSString *)supersetPath{
    NSArray *allExercisesFromSuperset = [self supersetexercisesArrayFromPath:supersetPath];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *documentsDirectoryURL = [manager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSString *videosPath = [documentsDirectoryURL.path stringByAppendingPathComponent:@"videos"];
    
    NSArray *videosFromBundle = @[@"Alternate Heel Touch.mp4",@"Bent-Leg V-Up.mp4",@"Bodyweight Crunch.mp4",@"Bodyweight Leg Raise.mp4",@"Plank.mp4"];
    NSMutableArray *allVideosFromDocuments = [manager contentsOfDirectoryAtPath:videosPath error:nil].mutableCopy;
    [allVideosFromDocuments addObjectsFromArray:videosFromBundle];
    
    NSMutableArray *videosToDownload = [NSMutableArray array];
    for (NSString *exerciseName in allExercisesFromSuperset) {
        if (![allVideosFromDocuments containsObject:exerciseName]) {
            [videosToDownload addObject:exerciseName];
        }
    }
    
    return videosToDownload;
}

@end
