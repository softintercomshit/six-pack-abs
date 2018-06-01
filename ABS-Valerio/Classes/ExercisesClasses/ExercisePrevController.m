#import "ExercisePrevController.h"
#import "Workout.h"
#import "Eercise.h"
#import "Photos.h"
#import "Repetitions.h"
#import "CustomMoviePlayer.h"
#import "DownloadVideoController.h"
#import "GuideAppDelegate.h"

@interface ExercisePrevController () <CustomMoviePlayerDelegate, DownloadVideosDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UITextView *exerciseDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *muscleTypeLabel;
@property (weak, nonatomic) IBOutlet UIView *descriptionView;

@property (weak, nonatomic) IBOutlet UIView *pickerComponenetsView;
@property (weak, nonatomic) IBOutlet UIPickerView *durationsPickerView;

@property (weak, nonatomic) IBOutlet UIButton *saveExerciseButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playButtonHeightConstraint;

@property (nonatomic) BOOL titleSet;

@end

@implementation ExercisePrevController{
    __weak IBOutlet UILabel *setDurationLabel;
}



- (void)viewDidLoad{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(applicationDidBecomeActive)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    _titleSet = NO;
    [self resizeNavigationTitleView];
    self.managedObjectContext = [[DataAccessLayer sharedInstance] managedObjectContext];;
    [setDurationLabel setBebasFontWithType:Regular size:17];
    
    if (self.custom) {
        _addButton.hidden = NO;
        [self.addButton setAlpha:1.0];
    }else{
        [self.addButton setAlpha:0.0];
    }
    
    if (isIpad) {
        _playButtonWidthConstraint.constant = _playButtonHeightConstraint.constant = 70;
    }
    [_playButton layoutIfNeeded];
    _playButton.layer.cornerRadius = CGRectGetWidth(_playButton.frame)/2;
    
    [self setImagesToScroll];
    [self setDescription];
    
    [_muscleTypeLabel setBebasFontWithType:Regular size:isIpad? 27 : 20];
    [_exerciseDescriptionTextView setBebasFontWithType:Regular size:isIpad? 20 : 17];
    
    [_muscleTypeLabel setTextColor:RGBA(65, 62, 62, 1)];
    [_muscleTypeLabel setTextColor:RGBA(65, 62, 62, 1)];
    
    [_exerciseDescriptionTextView layoutIfNeeded];
    [_exerciseDescriptionTextView setContentOffset: CGPointMake(0,0) animated:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _saveExerciseButton.hidden = YES;
    if (self.isEditingExercise) {
        [self.backButton setAlpha:0.0];
    }else{
        [self.saveButton setAlpha:0.0];
    }
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.isEditingExercise){
        [self performSelector:@selector(shoPickerView) withObject:nil afterDelay:0.1];
    }
//    NSLog(@"%@", NSStringFromCGRect(_titleLabel.frame));
}


-(void)dealloc{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidBecomeActiveNotification];
    } @catch (NSException *exception) {}
}


-(void)applicationDidBecomeActive{
    [(GuideAppDelegate*)[[UIApplication sharedApplication] delegate] setShouldRotateVideo:NO];
    [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if(!_titleSet){
        _titleSet = YES;
        [self setTitleForExercise:self.titleString.localized];
        [self setImagesToScroll];
    }
}

-(void)resizeNavigationTitleView{
    UIView *leftBarButtonItemView = self.navigationItem.leftBarButtonItem.customView;
    float titleViewOriginX = leftBarButtonItemView.frame.size.width + leftBarButtonItemView.frame.origin.x;
    float newTitleViewWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - titleViewOriginX*2;
    
    CGRect newRect = [self.navigationItem.titleView frame];
    newRect.size.width = newTitleViewWidth;
    [self.navigationItem.titleView setFrame:newRect];
}

-(void)setImagesToScroll{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:_exercisePath error:nil];
    fileList = [fileList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    NSMutableArray *photosArray = [[NSMutableArray alloc] init];
    for (int i = 1; i < [fileList count]-1; i++)
    {
        [photosArray addObject:[self.exercisePath stringByAppendingString:[NSString stringWithFormat:@"/%@", [fileList objectAtIndex:i]]]];
    }
    if (self.isWorkout) {
        [self populateContentScrollView:self.photoSrollView WithPhotos:[self getPhotosForScrollView] andPageControl:self.pageControl];
    }else{
        [self populateContentScrollView:self.photoSrollView WithPhotos:photosArray andPageControl:self.pageControl];
    }
}

-(void)shoPickerView{
    _playButton.hidden = YES;
    [self.view layoutIfNeeded];
    //_pickerComponentsViewTopContrinaint.constant = -_descriptionView.frame.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        _pickerComponenetsView.frame = CGRectMake( 0, _descriptionView.frame.origin.y, _pickerComponenetsView.frame.size.width, _pickerComponenetsView.frame.size.height);
        [self.view updateConstraints];
    }];
    [self.navigationItem.rightBarButtonItem setTitle:@"doneKey".localized];
    
}


-(NSMutableArray*)getPhotosForScrollView{
    NSMutableArray *photosArr = [NSMutableArray array];
    for (int v = 0; v < [[_workout.exercise allObjects] count]; v++)
    {
        Eercise *detail = (Eercise*)[[_workout.exercise allObjects] objectAtIndex:v];
        if ([detail.sort intValue] == self.exercSort) {
            exercise = detail;
            repsArray = [[NSMutableArray alloc] init];
            for (int j = 0; j < [[detail.reps allObjects] count]; j++) {
                Repetitions *repsi = (Repetitions*)[[detail.reps allObjects]objectAtIndex:j];
                [repsArray addObject:repsi];
            }
            NSArray *sortedArray = [repsArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
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
            repsArray = [NSMutableArray arrayWithArray:sortedArray];
            
            if ([repsArray count]!=0)
                for (int k = 0;  k < _circles; k ++ ) {
                    if([[repsArray objectAtIndex:k] isKindOfClass:[Repetitions class]]){
                        //repetitions
                        [_durationsPickerView  selectRow:[[[repsArray objectAtIndex:k] repetitions] intValue]-1  inComponent:k animated:NO];
                    }else{
                        [_durationsPickerView  selectRow:[[repsArray objectAtIndex:k] intValue]-1  inComponent:k animated:NO];
                    }
                }
            if (![detail.isCustom boolValue]) {
                NSLog(@"NOT CUSTOM");
                customExercise = 0;
                NSString *path;
                NSArray *comps = [detail.link pathComponents];
                
                path = [[NSBundle mainBundle] resourcePath];
                path = [path stringByAppendingPathComponent:@"/Default"];
                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-2]];
                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-1]];
                
                NSFileManager *man = [NSFileManager defaultManager];
                NSArray *fileList = [man contentsOfDirectoryAtPath:path error:nil];
                fileList = [fileList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
                
                for (int k = 1; k < [fileList count]-1; k++) {
                    
                    [photosArr addObject:[path    stringByAppendingPathComponent:[fileList objectAtIndex:k]]];
                }
            }else
            {
                NSLog(@"CUSTOM");
                customExercise = 1;
                [self.playButton setAlpha:0];
                NSString *path;
                NSArray *comps = [exercise.descriptionLink pathComponents];
                if ([comps containsObject:@"Library"]) {
                    path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];

                    path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-2]];
                    path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-1]];
                    descrPath = path;
                }
                NSMutableArray *dataArray = [NSMutableArray array];
                for (int j = 0; j < [[detail.photos allObjects] count]; j++) {
                    
                    [dataArray addObject:[[detail.photos allObjects] objectAtIndex:j]];
                }
                
                NSArray *sortedArray = [dataArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
                    
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
                
                for (int k = 0; k < [sortedArray count]; k++) {
                    NSString *path;
                    NSArray *comps = [[[sortedArray objectAtIndex:k] photoLink]pathComponents];
                    if ([comps containsObject:@"Library"]) {
                        path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                        
                        path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-2]];
                        path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-1]];
                    }
                    [photosArr addObject:path];
                }
            }
            break;
        }
    }
    doSelect = YES;
    return photosArr;
}


-(void)populateContentScrollView:(UIScrollView *)scrollView WithPhotos:(NSMutableArray *)picArray andPageControl:(UIPageControl *)pageContr{
    for (UIImageView *imgView in scrollView.subviews) {
        if ([imgView isKindOfClass:[UIImageView class]]) {
            [imgView removeFromSuperview];
        }
    }
    
    NSMutableArray * array = [NSMutableArray arrayWithArray:picArray];
    CGFloat scale;
    scale = self.view.frame.size.width / 320;
    for (int i = 0; i < array.count; i++){
        UIImage* currentImage = [UIImage imageWithContentsOfFile:[array objectAtIndex:i]];
        if(currentImage){
            UIImageView *imageView = [[UIImageView alloc]  initWithFrame:CGRectMake(self.view.frame.size.width * i, 0, self.view.frame.size.width, scrollView.frame.size.height)];//initWithImage:[UIImage imageWithContentsOfFile:[array objectAtIndex:i]]] ;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = currentImage;
            [pageContr setHidden:NO];
            [scrollView addSubview:imageView];
        }else{
            [pageContr setHidden:YES];
        }
    }
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * array.count, 0);
    pageContr.currentPage = 0;
    pageContr.numberOfPages = array.count;
}


#pragma mark - Title Methods


-(void)setTitleForExercise:(NSString *)stringForTitle{
    [_titleLabel setBebasFontWithType:Bold size:29];
    if (self.custom==0 || self.isWithVideo == 1){
        [self.titleLabel setText:[self getLocalizedStringFromString:stringForTitle]];
        
    }else{
        [self.titleLabel setText:stringForTitle];
    }
//    if(isIpad)
//        _titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:26];
    
    CGSize maximumLabelSize = CGSizeMake(9999, 9999);
    CGSize expectedLabelSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:maximumLabelSize lineBreakMode:self.titleLabel.lineBreakMode];
    CGRect newFrame = _titleLabel.frame;
    newFrame.size.width = expectedLabelSize.width;
    newFrame.size.height = 44;
    self.titleLabel.frame = newFrame;
    
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    if (_titleLabel.frame.size.width > _titleLabel.superview.frame.size.width){
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self forwardLabelAnimation];
    }else
        _titleLabel.center = _titleLabel.superview.center;
}

- (NSString *)getLocalizedStringFromString:(NSString *)string{
    NSString *localizedString = nil;
    localizedString = NSLocalizedStringFromTable(string, @"content", nil);
    return localizedString;
}

-(void)forwardLabelAnimation{
    [UIView animateWithDuration:10.0f animations:^{
        [self.titleLabel setFrame:CGRectMake((self.titleLabel.superview.frame.size.width - self.titleLabel.frame.size.width), self.titleLabel.frame.origin.y, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height)];
    } completion:^(BOOL finished) {
        [self backwardLAbelAnimation];
    }];
}

-(void)backwardLAbelAnimation{
    [UIView animateWithDuration:10.0f animations:^{
        [self.titleLabel setFrame:CGRectMake(0, self.titleLabel.frame.origin.y, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height)];
    } completion:^(BOOL finished) {
        [self performSelector:@selector(forwardLabelAnimation) withObject:nil afterDelay:3.0f];
    }];
}

#pragma mark - ScrollView Delegates

- (void)scrollViewDidScroll:(UIScrollView *)sender{
    if (!pageControlBeginUsed){
        CGFloat pageWidth = self.photoSrollView.frame.size.width;
        int page = floor((self.photoSrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    pageControlBeginUsed = NO;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    pageControlBeginUsed = NO;
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return _circles;
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 100;
}
#pragma mark - UIPickerViewDelegate


-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1];
//    label.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    [label setBebasFontWithType:Regular size:18];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.text = [NSString stringWithFormat:@"%d", (int)(row+1)*2];
    return label;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d", (int)row+1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    UILabel *labelSelected = (UILabel*)[pickerView viewForRow:row forComponent:component];
    labelSelected.textColor = [UIColor whiteColor];
    repsArray = [NSMutableArray array];
    //    didPicked = 1;
    for (int i = 0; i < self.circles; i++) {
        [repsArray addObject:[NSNumber numberWithInt:(int)[self.repsPicker selectedRowInComponent:i]+1 ]];
    }
}

#pragma mark - Description

-(void)setDescription{
    NSString* str;
    if (customExercise) {
        str = [self readFile:descrPath];
        _muscleTypeLabel.text = @"";
        _exerciseDescriptionTextView.text = str;
    }else{
        str = [_titleString stringByAppendingString:@" description"].localized;
        @try {
            NSRange endRange = [str rangeOfString:@"\n\n"];
            _muscleTypeLabel.text = [str substringWithRange:NSMakeRange(0 , endRange.location)];
            _exerciseDescriptionTextView.text = [str substringWithRange:NSMakeRange(endRange.location + 2 , str.length - endRange.location -2)];
        } @catch (NSException *exception) {}
    }
    
    _exerciseDescriptionTextView.userInteractionEnabled = YES;
}

-(NSString *)readFile:(NSString *)fileName{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSURL *libraryPath = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *filePath = [libraryPath.path stringByAppendingPathComponent:fileName.lastPathComponent];
    
    if ([fileManager fileExistsAtPath:filePath]){
        NSError *error;
        NSString *resultData = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        if (!error){
            return resultData;
        }
    }
    return nil;
}

#pragma mark - Navigation

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    CustomUnwindSegue *segue = [[CustomUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    return segue;
}


#pragma mark - IBActions

- (IBAction)goback:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)playVideo:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
    
    NSString *bundle = [[NSBundle mainBundle] resourcePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString* moviePath = [[[NSString stringWithFormat:@"%@/VIDEOS", bundle] stringByAppendingPathComponent:self.titleString] stringByAppendingPathExtension:@"mp4"];
    if (![fileManager fileExistsAtPath:moviePath]) {
        NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        moviePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"videos/%@.mp4", self.titleString]];
        if (![fileManager fileExistsAtPath:moviePath]) {
            DownloadVideoController *downloadObj = [[DownloadVideoController alloc] initWithVideoName:[self.titleString stringByAppendingString:@".mp4"] containerController:self];
            [downloadObj setDelegate:self];
            [downloadObj startDownload];
        }else
            [self playVideoForPath:moviePath];
    }else
        [self playVideoForPath:moviePath];
}

-(void)didFinishDownloadingWithPath:(NSString *)path{
    [self playVideoForPath:path];
}

-(void)playVideoForPath:(NSString *)moviePath{
    CustomMoviePlayer *mpController = [[CustomMoviePlayer alloc] init];
    mpController.videoPath = moviePath;
    mpController.screenSize = self.view.window.frame.size;
    
    [mpController.moviePlayer.backgroundView setBackgroundColor:[UIColor whiteColor]];
    mpController.delegate = self;
    [self presentMoviePlayerViewControllerAnimated:mpController];
}

-(IBAction)saveExerciseCanges{
    repsArray = [NSMutableArray array];
    for (int i = 0; i < self.circles; i++) {
        [repsArray addObject:[NSNumber numberWithInt:(int)[_durationsPickerView selectedRowInComponent:i]+1]];
    }
    NSMutableSet *set = [[NSMutableSet alloc] init];
    for (int i = 0; i < [repsArray count]; i++) {
        Repetitions *reps = [NSEntityDescription insertNewObjectForEntityForName:@"Repetitions" inManagedObjectContext:self.managedObjectContext];
        reps.repetitions = [repsArray objectAtIndex:i];
        reps.sort = [NSNumber numberWithInt:i];
        [set addObject:reps];
    }
    exercise.reps = set;
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)addExerciseToWorkout{
    _addButton.hidden = YES;
    _saveExerciseButton.hidden = NO;
    [self shoPickerView];
}

- (IBAction)saveButtonAction:(id)sender {
    
    UIViewController *controller = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-4];
    [self setDelegate:controller];
    repsArray = [NSMutableArray array];
    
    for (int i = 0; i < self.circles; i++) {
        [repsArray addObject:[NSNumber numberWithInt:(int)[_durationsPickerView selectedRowInComponent:i] + 1 ]];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.exercisePath forKey:@"photos"];
    [ dict setObject:[self.exercisePath lastPathComponent] forKey:@"title"];
    [dict setObject:repsArray forKey:@"reps"];
    [_delegate addExercise:dict];
    [self.navigationController popToViewController:controller animated:YES];
    
    
}

- (IBAction)changePage{
    CGRect frame;
    frame.origin.x = self.photoSrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.photoSrollView.frame.size;
    [self.photoSrollView scrollRectToVisible:frame animated:YES];
    
    pageControlBeginUsed = YES;
}

#pragma mark - CustomPlayer Delegate


-(void)playerRemoved{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (IBAction)backButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)backButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}

- (IBAction)playButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)playButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}

@end
