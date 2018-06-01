#import "WorkoutExerciseTableView.h"
#import "CustomCell.h"
#import "ExercisePrevController.h"
#import "StrartViewController.h"

@interface WorkoutExerciseTableView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) int headerSectionHeight;
@property (weak, nonatomic) IBOutlet UITableView *workoutsTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startButtonHeightConstraint;

@end

@implementation WorkoutExerciseTableView{
    __weak IBOutlet UIButton *startButtonOutlet;
}


- (void)viewDidLoad{
    
    [super viewDidLoad];
    [startButtonOutlet setBebasFontWithType:Regular size:30];
    _headerSectionHeight= 40;
    
    NSString *title = [self.title substringFromIndex:2];
    title = [title stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    self.title = title.localized;
    [self.navigationController.navigationBar setBebasFont];
    
    exrciseArray = [NSMutableArray array];
    [self fetchTypes];
    [self fetchDays];
    repsArray = [repsString componentsSeparatedByString:@"/"];
    if(isIpad){
        _startButtonHeightConstraint.constant = 75;
//        _titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:26];
    }
}


-(void)fetchTypes{
    NSFileManager *manager = [NSFileManager defaultManager];
    self.fileList = [manager contentsOfDirectoryAtPath:self.exercisesPath error:nil];
    self.fileList = [self.fileList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString *exercisename in self.fileList) {
        NSString *exercisepath = [self.exercisesPath stringByAppendingPathComponent:exercisename];
        [_exeriseAray addObject: exercisepath];
    }
}


-(void)fetchDays{
    daysDictionaryContent = [[NSMutableDictionary alloc] initWithDictionary:[self extractDaysFoldersWithPath:self.exercisesPath]];
}



-(NSString *)readFile:(NSString *)fileName{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileName]) {
        NSError *error= NULL;
        id resultData=[NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:&error];
        if (error == NULL){
            return resultData;
        }
    }
    return NULL;
}


-(NSMutableDictionary *)extractDaysFoldersWithPath:(NSString *)pathString{
    NSMutableDictionary *contentDictionary = [NSMutableDictionary dictionary];
    for (int i = 0; i < _fileList.count - 1; i++) {
        NSString *exerciseName = _fileList[i];
        NSString *exercisePath = [pathString stringByAppendingPathComponent:exerciseName];
        [exrciseArray addObject:[self dayContentInfoWithPath: exercisePath]];
    }
    
    NSString *descriereFilePath = [pathString stringByAppendingPathComponent:@"DESCRIERE.txt"];
    repsString = [self readFile: descriereFilePath];
    
    return contentDictionary;
}


-(NSMutableArray *)dayContentInfoWithPath:(NSString *)pathToFolder{
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *folderList = [manager contentsOfDirectoryAtPath:pathToFolder error:nil];
    NSArray *plistFileContent;
    NSMutableArray *contentArray = [NSMutableArray array];
    for (int j = 0; j<[folderList count]; j++){
        NSMutableDictionary *contentDict = [NSMutableDictionary dictionaryWithContentsOfFile:[pathToFolder stringByAppendingPathComponent:[folderList objectAtIndex:j]]];
        plistFileContent = [manager contentsOfDirectoryAtPath:[bundlePath stringByAppendingPathComponent:[contentDict objectForKey:@"infopath"]] error:nil];
        plistFileContent = [plistFileContent sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSMutableDictionary *contentDicts = [[NSMutableDictionary alloc] init];
        [contentDicts setObject:[[bundlePath stringByAppendingPathComponent:[contentDict objectForKey:@"infopath"]] stringByAppendingPathComponent:[plistFileContent objectAtIndex:0]] forKey:[folderList objectAtIndex:j]];
        [contentArray addObject:contentDicts];
    }
    
    [contentArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *name1=[obj1 allKeys][0];
        NSString *name2=[obj2 allKeys][0];
        if ([[name1 class] isSubclassOfClass:[NSString class]] && [[name2 class] isSubclassOfClass:[NSString class]]){
            NSArray *components1 = [name1 componentsSeparatedByString:@" "];
            NSArray *components2 = [name2 componentsSeparatedByString:@" "];
            if (components1.count<1 || components2.count<1) return NSOrderedSame;
            NSString *component1=components1[0];
            NSString *component2=components2[0];
            NSInteger int1=component1.integerValue;
            NSInteger int2=component2.integerValue;
            return int1>int2?NSOrderedDescending:int1<int2?NSOrderedAscending:NSOrderedSame;
        }
        return NSOrderedSame;
    }];
    return contentArray;
}


#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [repsArray count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.fileList count]-1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if ([[[[self fileList] objectAtIndex:indexPath.row] pathExtension] isEqualToString:@"txt"]) {
        
    }else{
        NSString *title = [self.fileList objectAtIndex:[indexPath row]];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: @"([0-9]+)" options:0 error:nil];
        title = [regex stringByReplacingMatchesInString:title options:0 range:NSMakeRange(0, 4) withTemplate:@""];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        cell.titleLabel.text = [NSString stringWithFormat:@"%ld %@", indexPath.row+1, title.localized];
        
        NSString *imagePath = exrciseArray[indexPath.row][0][@"infopath.plist"];
        cell.cellImage.image = [UIImage imageWithContentsOfFile: imagePath];

        cell.detailedLabel.text = [NSString stringWithFormat:@"%.0f %@", [[repsArray lastObject] floatValue]*2, @"secondsKey".localized];
    }
    return cell;
}


#pragma mark - Table View Delegate


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if([repsArray count] == 1){
        return 0;
    }
    return _headerSectionHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.workoutsTableView.frame.size.width, _headerSectionHeight)];
    headerView.backgroundColor = [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1];
    UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.workoutsTableView.frame.size.width- 20, _headerSectionHeight)];
    headerLabel.text = [NSString stringWithFormat:@"%@ %ld %@", @"roundKey".localized, (long)section + 1, @"rest30secKey".localized];
    [headerLabel setBebasFontWithType:Regular size:isIpad? 21 : 18];
    headerLabel.textColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:1];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:headerLabel];
    return headerView;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"startSegue" sender:@{@"currentIndex": @(indexPath.row), @"remainedRounds": @(repsArray.count - indexPath.section), @"currentIndexPath" : indexPath}];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return isIpad ? 120 : 80;
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    StrartViewController *controller = segue.destinationViewController;
    controller.exerciseArray = [NSMutableArray arrayWithArray:exrciseArray];
    controller.repsArray = [NSArray arrayWithArray:repsArray];
    controller.isPredefined = YES;
    [controller setKcalories:_kcalories];
    
    if([sender isKindOfClass:[NSDictionary class]]){
        NSLog(@"NOt Empty");
        [controller setCurrentRoundAndIndex:[sender[@"currentIndex"] intValue] withRemainedRound:[sender[@"remainedRounds"] intValue]];
    }else{
        NSLog(@"Empty");
        [controller setCurrentRoundAndIndex:0 withRemainedRound:0];
    }
}


#pragma mark - IBActions


-(IBAction)goback:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)backButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}
@end
