#import "ExerciseTableView.h"
#import "FirstViewController.h"
#import "ExercisesTableViewCell.h"
#import "WorkoutExerciseTableView.h"
#import "NSBundle+Language.h"
#import "GuideAppDelegate.h"

@interface FirstViewController  ()

@end


@implementation FirstViewController{
    IBOutletCollection(NSLayoutConstraint) NSArray *sixPackButtonConstraints;
    __weak IBOutlet NSLayoutConstraint *startWorkoutButtonHeight;
}


#pragma mark - Initialization

NSArray* newNames;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"navTitleKey".localized;
    [self.navigationController.navigationBar setBebasFont];
    
    if (CGRectGetWidth([UIScreen mainScreen].bounds) == 320) {
        for (NSLayoutConstraint *item in sixPackButtonConstraints) {
            item.constant = 20;
        }
    }
    
    [_getSixPackButton.layer setCornerRadius:5];
    [_getSixPackButton setBebasFontWithType:Bold size:35];
    [_getSixPackButton layoutIfNeeded];
    
//    [_getSixPackButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    
    _getSixPackButton.titleLabel.numberOfLines = 1;
    _getSixPackButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _getSixPackButton.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    [self getCategoryFolderList];
    [self registerCells];
    [_getSixPackButton setBackgroundImage:[ImageUtility imageWithColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:.2]] forState:UIControlStateHighlighted];
    newNames = @[@"Beginner".localized ,@"Intermediate".localized ,@"Advanced".localized, @"Strong ABS".localized];
}

-(void)registerCells{
    [_tableView registerNib:[UINib nibWithNibName:@"ExercisesTableViewCellLeft" bundle:nil] forCellReuseIdentifier:@"ExercisesTableViewCellLeft"];
    [_tableView registerNib:[UINib nibWithNibName:@"ExercisesTableViewCellRight" bundle:nil] forCellReuseIdentifier:@"ExercisesTableViewCellRight"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _getSixPackButton.hidden = _getSixPackHideValue;
    
    if (_getSixPackHideValue) {
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"HLPHelpBack"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction)];
        [self.navigationItem setLeftBarButtonItem:newBackButton];
    }
}

-(void)backButtonAction{
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - Geters Methods


-(void)getCategoryFolderList{
    NSArray* categoryNames = @[@"Beginner.png",@"Advanced.png",@"Intermediate.png",@"StrongABS.png"];
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [bundlePath stringByAppendingString:@"/Default"];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:path error:nil];
    _categoryArray = [NSMutableArray array];
    
    for (int i =0 ; i<fileList.count; i++){
        NSString* categoryPath = [path stringByAppendingPathComponent:[fileList objectAtIndex:i]];
        NSArray *exercisesArray = [manager contentsOfDirectoryAtPath:categoryPath error:nil];
        [_categoryArray addObject:@{@"path":categoryPath,@"categoryImage":categoryNames[i], @"exerciseNumbers":@(exercisesArray.count)}];
    }
    [_categoryArray insertObject:[_categoryArray objectAtIndex:2] atIndex:1];
    [_categoryArray removeObjectAtIndex:3];
}


#pragma mark - UITable View Datasource


//-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//    return 2;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 2;
    return _categoryArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = indexPath.row % 2 ?  @"ExercisesTableViewCellRight" : @"ExercisesTableViewCellLeft";
    ExercisesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setCategoryValues:_categoryArray[indexPath.row]];
    cell.separatorLineImageView.hidden = indexPath.row == _categoryArray.count -1 || indexPath.row == 1;
    cell.categoryNameLabel.text = newNames[indexPath.row];
//    if (indexPath.section == 0) {
//        [cell setCategoryValues:_categoryArray[indexPath.row]];
//        cell.separatorLineImageView.hidden = indexPath.row == _categoryArray.count -1;
//        cell.categoryNameLabel.text = newNames[indexPath.row];
//    }else{
//        [cell setCategoryValues:_categoryArray[indexPath.row+2]];
//        cell.separatorLineImageView.hidden = indexPath.row == _categoryArray.count -1;
//        cell.categoryNameLabel.text = newNames[indexPath.row+2];
//    }
    return cell;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 1) {
//        return 52;
//    }
//    return 0;
//}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    if (section == 1) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 52)];
//        [_getSixPackButton setFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - 16*2, 52)];
//        [_getSixPackButton setCenter:view.center];
//        [view addSubview:_getSixPackButton];
//        return view;
//    }
//    return nil;
//}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
        CGFloat cellHeight = _tableView.frame.size.height / _categoryArray.count;
        if (indexPath.row == 1 || indexPath.row == 2) {
            return cellHeight + 20;
        }
        return cellHeight - 20;
    }
    CGFloat cellHeight = _tableView.frame.size.height / _categoryArray.count;
    if (indexPath.row == 1 || indexPath.row == 2) {
        return cellHeight + 15;
    }
    return cellHeight - 15;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self pushExerciseController:(int)indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)pushExerciseController:(int)indexPathRow{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ExerciseTableView *exercisesController = [sb instantiateViewControllerWithIdentifier:@"ExerciseTableView"];
    NSString* categoryName = [_categoryArray[indexPathRow][@"path"] lastPathComponent];
    exercisesController.title = newNames[indexPathRow];
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *path = [bundlePath stringByAppendingString:[NSString stringWithFormat:@"/Default/%@", categoryName]];
    exercisesController.exercisePath = path;
    exercisesController.hidesBottomBarWhenPushed = YES;
    exercisesController.circles = _circles;
    exercisesController.customType = _customType;
    [self.navigationController pushViewController:exercisesController animated:YES];
}


#pragma mark - IBActions


- (IBAction)sixPackButtonAction:(id)sender {
    WorkoutExerciseTableView *workoutExerciseControllers = [self.storyboard instantiateViewControllerWithIdentifier:@"WorkoutExerciseTableView"];
    NSMutableArray* supersetArray = [Utilities getSupersetsArray:YES];
    NSString *supersetPath = supersetArray[0][@"path"];
    
    workoutExerciseControllers.exercisesPath = supersetPath;
    workoutExerciseControllers.title = [[supersetArray firstObject][@"path"] lastPathComponent];
    workoutExerciseControllers.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:workoutExerciseControllers animated:YES];
}




@end
