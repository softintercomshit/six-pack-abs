#import "CustomExerciseTableView.h"
#include "CustomCell.h"
#include "Eercise.h"
#include "Photos.h"
#import "Repetitions.h"
#import "GuideAppDelegate.h"
#include "ExercisePrevController.h"
#import "EditWorkoutController.h"
#import "StrartViewController.h"
#import "DownloadVideoController.h"


@interface CustomExerciseTableView () <UITableViewDataSource, UITableViewDelegate, DownloadVideosDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, retain) NSArray<Workout *> *fetchArray;
@property (nonatomic, strong) NSMutableArray<Eercise*> *exerciseInfoArray;
@property (weak, nonatomic) IBOutlet UIView *noExerciseFooterView;
@property (weak, nonatomic) IBOutlet UITableView *customWorkoutTableView;
@property (weak, nonatomic) IBOutlet UILabel *noExerciseInformativeLabel;
@property (weak, nonatomic) IBOutlet UILabel *informativeLabel;

@end

@implementation CustomExerciseTableView{
    __weak IBOutlet UIButton *startButtonOutlet;
}


NSMutableArray *pathAray;
NSMutableArray *titleArray;
int circles;
int recovery;



- (void)viewDidLoad{
    [super viewDidLoad];
    self.managedObjectContext = [[DataAccessLayer sharedInstance] managedObjectContext];
    self.exerciseInfoArray = [NSMutableArray array];
//    self.fetchArray = [GeneralDAO getAllexercises];
    titleArray = [NSMutableArray array];
    pathAray = [NSMutableArray arrayWithArray:[self fetchExercises]];
    
    [self.navigationController.navigationBar setBebasFont];
    [_noExerciseInformativeLabel setBebasFontWithType:Regular size:isIpad? 24 : 20];
    [_informativeLabel setBebasFontWithType:Regular size:isIpad? 17 : 15];
    
    [startButtonOutlet setBebasFontWithType:Regular size:30];
//    if(isIpad){
//        _noExerciseInformativeLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:24];
//        _informativeLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:17];
//    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}


-(void)viewDidAppear:(BOOL)animated{
    [_customWorkoutTableView reloadData];
}


#pragma mark - Initialize


-(NSArray*)fetchExercises
{
    NSMutableArray *dataArray = [NSMutableArray array];
    NSMutableArray *execises = [NSMutableArray array];
//    for (int i = 0; i< [self.fetchArray count]; i++) {
//        Workout *work = (Workout*)[self.fetchArray objectAtIndex:i];
//        if ([work.title isEqualToString:self.title]) {
//            circles = [work.circles intValue];
//            recovery = [work.recoveryMode intValue];
//            for (int v = 0; v < [[work.exercise allObjects] count]; v++)
//            {
//                Eercise *detail = (Eercise*)[[work.exercise allObjects] objectAtIndex:v];
//                [execises addObject:detail];
//            }
//        }
//    }
    
    circles = [_workout.circles intValue];
    recovery = [_workout.recoveryMode intValue];
    for (int v = 0; v < [[_workout.exercise allObjects] count]; v++)
    {
        Eercise *detail = (Eercise*)[[_workout.exercise allObjects] objectAtIndex:v];
        [execises addObject:detail];
    }
    
    self.exerciseInfoArray = (NSMutableArray*)[self sortArray:execises];
    for (int v = 0; v < [self.exerciseInfoArray count]; v++)
    {
        Eercise *detail = (Eercise*)[self.exerciseInfoArray objectAtIndex:v];
        [execises addObject:detail];
        [titleArray addObject: detail.title];
        if (![detail.isCustom boolValue])
        {
            NSFileManager *man = [NSFileManager defaultManager];
            NSString *path;
            NSArray *comps = [detail.link pathComponents];
            if ([comps containsObject:@"Library"]) {
                NSLog(@"1 - %@", [comps objectAtIndex:5]);
                path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                //                path = [path stringByDeletingLastPathComponent];
                //                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-3]];
                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-2]];
                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-1]];
            }else{
                NSLog(@"2 - %@", [comps objectAtIndex:5]);
                path = [[NSBundle mainBundle] resourcePath];
                path = [path stringByAppendingPathComponent:@"/Default"];
                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-2]];
                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-1]];
            }
            NSLog(@"Bundle path: %@", [[NSBundle mainBundle] resourcePath]);
            NSLog(@"PATH: %@", path);
            NSArray *fileList = [man contentsOfDirectoryAtPath:path error:nil];
            NSLog(@"File list: %@", fileList);
            [dataArray addObject:[path stringByAppendingPathComponent:[fileList objectAtIndex:1]]];
        }else
        {
            NSMutableArray *arrayToSort = [NSMutableArray array];
            for (int j = 0; j < [[detail.photos allObjects] count]; j++)
            {
                
                Photos *photos = (Photos*) [[detail.photos allObjects]objectAtIndex:j];
                
                [arrayToSort addObject:photos];
                
            }
            NSString *path;
            NSArray *comps = [[[[self sortArray:arrayToSort] objectAtIndex:0] photoLink] pathComponents];
            if ([comps containsObject:@"Library"]) {
                NSLog(@"1 - %@", [comps objectAtIndex:5]);
                path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                //                path = [path stringByDeletingLastPathComponent];
                //                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-3]];
                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-2]];
                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-1]];
            }
            if (path) {
                [dataArray addObject:path];
            }
        }
        
        
    }
    [startButtonOutlet setEnabled:dataArray.count];
    return dataArray;
}



-(NSArray *)sortArray: (NSArray *)array
{
    NSArray *sortedArray = [array sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        if ([[obj1 sort] integerValue] > [[obj2 sort] integerValue])
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([[obj1 sort] integerValue] < [[obj2 sort] integerValue])
        {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return sortedArray;
}


#pragma mark - Detail Label

-(NSString *)setDetailWithReps:(Eercise*)exercise
{
    NSString *repsStr = [NSString stringWithFormat:@"%d %@ ", (int)[[[exercise reps] allObjects] count], @"circleAndKey".localized];
    for (int i = 0; i < [[exercise.reps allObjects] count]; i++)
    {
        NSArray *repsArray = [[exercise reps] allObjects];
        for(Repetitions* currentRepetition in repsArray){
            if([currentRepetition.sort intValue] == i){
                
                if( i != [[exercise.reps allObjects] count] - 1){
                    repsStr= [repsStr stringByAppendingString:[NSString stringWithFormat:@"%d/",[currentRepetition.repetitions intValue]*2]];
                }else{
                    repsStr = [repsStr stringByAppendingString:[NSString stringWithFormat:@"%d %@", [currentRepetition.repetitions intValue]*2, @"secondsKey".localized]];
                }
                break;
            }
        }
        
    }
    return repsStr;
}

#pragma mark - Table View Data Source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [titleArray count];
}


- (CustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *title = [titleArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = title;
    
    UIImage *cellImg;
    if (indexPath.row < pathAray.count) {
        NSString *imagePath = pathAray[indexPath.row];
        cellImg = [UIImage imageWithContentsOfFile: imagePath];
    }
    
    cell.detailedLabel.text = [self setDetailWithReps:[_exerciseInfoArray objectAtIndex:indexPath.row]];
    if ([[[self.exerciseInfoArray objectAtIndex:indexPath.row] isCustom] boolValue]) {
        cell.customImage.image = cellImg;
    }else{
        cell.cellImage.image = cellImg;
    }
    return cell;
}


#pragma mark - UITableView Delegate



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return isIpad ? 120 : 80;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    [self hideStartButton:[self.exerciseInfoArray count] == 0];
    return 0;
}
//
//-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    return [UIView new];
//}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)hideStartButton:(BOOL)hideValue{
    _noExerciseFooterView.hidden = !hideValue;
}

#pragma mark - Navigation


-(IBAction)moveBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"editSegue"])
    {
        EditWorkoutController *controller = segue.destinationViewController;
        CustomCell *cell = (CustomCell*)[_customWorkoutTableView cellForRowAtIndexPath:[_customWorkoutTableView indexPathForSelectedRow]];
        controller.workoutTitle = cell.titleLabel.text;
        
    }else if ([segue.identifier isEqualToString:@"startSegue"])
    {
        ExercisePrevController *destViewController = segue.destinationViewController;
        [destViewController setWorkout:_workout];
        CustomCell *cell = (CustomCell*)sender;
        destViewController.workTitle = self.title;
        NSIndexPath *indexPath = [_customWorkoutTableView indexPathForCell:cell];
        NSString *title = [titleArray objectAtIndex:indexPath.row];
        destViewController.titleString = title;
        
        NSString *path;
        if (indexPath.row < pathAray.count) {
            path = [pathAray[indexPath.row] stringByDeletingLastPathComponent];
        }
        
        destViewController.navigationItem.backBarButtonItem.title = self.title;
        NSLog(@"path %@", path);
        
        destViewController.exercisePath = path;
        destViewController.circles = circles;
        destViewController.isWithVideo = 1;
        destViewController.custom = 0;
        destViewController.isWorkout = 1;
        destViewController.exercSort = [[(Eercise*)[self.exerciseInfoArray objectAtIndex:[_customWorkoutTableView indexPathForSelectedRow].row] sort] intValue];
    }
}

- (IBAction)startWorkoutAction:(UIButton *)sender {
    NSMutableArray<NSString *> *exercisesArray = [NSMutableArray array];
    for (Eercise *item in _workout.exercise) {
        if (!item.isCustom.boolValue) {
            [exercisesArray addObject:[item.title stringByAppendingString:@".mp4"]];
        }
    }
    
    NSArray *videosToDownload = [self videosToDownload:exercisesArray];
    
    if (videosToDownload.count > 0) {
        // download videos
        DownloadVideoController *downloadObj = [[DownloadVideoController alloc] initWithArrayOfVideoNames:videosToDownload containerController:self];
        [downloadObj setDelegate:self];
        [downloadObj startDownload];
    }else{
        [self pushToStartViewController];
    }
}

-(void)didFinishDownloadingWithPath:(NSString *)path{
    [self pushToStartViewController];
}

-(NSArray *)videosToDownload:(NSArray<NSString*> *)exercisesArray{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *documentsDirectoryURL = [manager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSString *videosPath = [documentsDirectoryURL.path stringByAppendingPathComponent:@"videos"];
    
    NSArray *videosFromBundle = @[@"Alternate Heel Touch.mp4",@"Bent-Leg V-Up.mp4",@"Bodyweight Crunch.mp4",@"Bodyweight Leg Raise.mp4",@"Plank.mp4"];
    NSMutableArray *allVideosFromDocuments = [manager contentsOfDirectoryAtPath:videosPath error:nil].mutableCopy;
    [allVideosFromDocuments addObjectsFromArray:videosFromBundle];
    
    NSMutableArray *videosToDownload = [NSMutableArray array];
    for (NSString *exerciseName in exercisesArray) {
        if (![allVideosFromDocuments containsObject:exerciseName]) {
            [videosToDownload addObject:exerciseName];
        }
    }
    
    return videosToDownload;
}

-(void)pushToStartViewController{
    StrartViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"StrartViewController"];
    controller.exerciseArray = [NSMutableArray arrayWithArray:_exerciseInfoArray];
    
    NSMutableArray *tmpRepsArray = [NSMutableArray array];
    for (int i=0; i<circles; i++) {
        [tmpRepsArray addObject:@20];
    }
    controller.repsArray = tmpRepsArray;
    [controller setCurrentRoundAndIndex:0 withRemainedRound:0];
    controller.recovery = recovery;
    controller.isPredefined = NO;
    
    [self.navigationController pushViewController:controller animated:true];
}

- (IBAction)backButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)backButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}

@end
