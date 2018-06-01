#import "GuideFirstViewController.h"
#import "EditWorkoutController.h"
#import "CustomExerciseTableView.h"
#import "CustomCell.h"
#import "CustomExerciseTableView.h"
#import "DataInputController.h"
#import "GuideAppDelegate.h"
#import "Workout.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@interface GuideFirstViewController ()
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *fetchArray;

@property (weak, nonatomic) IBOutlet UIView *navigationBarView;
@property (nonnull, strong) IBOutlet UIButton* addCustomWorkoutButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *informativeLabel;

@end

@implementation GuideFirstViewController

#pragma mark - Viw controller life cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    swipeChecker = NO;
    editButtonChecker = NO;
    _titleLabel.text = @"customItemKey".localized;
    [_titleLabel setBebasFontWithType:Bold size:29];
    [_informativeLabel setBebasFontWithType:Bold size:isIpad ? 27 : 20];
    
    self.managedObjectContext = [[DataAccessLayer sharedInstance] managedObjectContext];
    self.fetchArray = [GeneralDAO getAllexercises].mutableCopy;
    editButtonChecker = NO;
    [self setAddButtonImagesState];
    _navigationViewHeightConstraint.constant = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}


-(void)reloadDataInTableView{
    [self.tableView reloadData];
}




-(void)setAddButtonImagesState{
    _addCustomWorkoutButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_addCustomWorkoutButton setBackgroundImage:[ImageUtility imageWithColor:RED_COLOR] forState:UIControlStateNormal];
    [_addCustomWorkoutButton setBackgroundImage:[ImageUtility imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
}




-(void)viewDidAppear:(BOOL)animated{
    self.managedObjectContext = [[DataAccessLayer sharedInstance] managedObjectContext];
    self.fetchArray = [GeneralDAO getAllexercises].mutableCopy;
    [self.tableView reloadData];
}

//-(void)viewDidLayoutSubviews{
//    [super viewDidLayoutSubviews];
//}


#pragma mark -
#pragma mark - UItableview Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    self.managedObjectContext = [[DataAccessLayer sharedInstance] managedObjectContext];
    self.fetchArray = [GeneralDAO getAllexercises].mutableCopy;
    [self.navigationItem.leftBarButtonItem setEnabled:[self.fetchArray count] > 0];
    return [self.fetchArray count];
}


- (CustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier" forIndexPath:indexPath];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 10)];
    Workout *record = (Workout*)[self.fetchArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = record.title.localized;
   // cell.titleLabel.textColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0];
   // [cell.titleLabel setFont:[UIFont systemFontOfSize:16]];
    return cell;
}


#pragma mark - UItableview Delegate


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0;
}


-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"deleteKey".localized handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        _addCustomWorkoutButton.hidden = NO;
        NSManagedObjectContext *context = [[DataAccessLayer sharedInstance] managedObjectContext];
        
        Workout *workout = _fetchArray[indexPath.row];
        [context deleteObject:workout];
        [_fetchArray removeObject:workout];
        
        NSError *error;
        [context save:&error];
        if (!error) {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }];
    
    UITableViewRowAction *edit = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:[@"editKey".localized stringByAppendingString:@"     "]  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        [self performSegueWithIdentifier:@"editSegue" sender:indexPath];
        [self performSelector:@selector(reloadDataInTableView) withObject:nil afterDelay:0.3];
    }];
    
    edit.backgroundColor = GREEN_COLOR;
    
    return @[delete, edit];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (UITableViewCellEditingStyle)tableView: (UITableView *)tableView editingStyleForRowAtIndexPath: (NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row!=0) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        highlightedPath = index;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"openExercisesSegue" sender:indexPath];
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}


#pragma mark - IBActions


-(IBAction)editWorkout{
    if (!editButtonChecker) {
        editButtonChecker = YES;
        [_editButton setTitle:@"doneKey".localized forState:UIControlStateNormal];
        [_editButton setBebasFontWithType:Regular size:17];
        
        [self.editButton setImage:nil forState:UIControlStateNormal];
        [self.editButton setImage:nil forState:UIControlStateHighlighted];
        _addCustomWorkoutButton.hidden = YES;
    }else{
        editButtonChecker = NO;
        [self.editButton setImage:[UIImage imageNamed:@"editBtn"] forState:UIControlStateNormal];
        [self.editButton setImage:[UIImage imageNamed:@"editBtn"] forState:UIControlStateHighlighted];
        [self.editButton setTintColor:[UIColor whiteColor]];
        [_editButton setTitle:@"" forState:UIControlStateNormal];
        _addCustomWorkoutButton.hidden = NO;
    }
    
    [_tableView setEditing:editButtonChecker animated:YES];
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (![segue.identifier isEqualToString:@"dataInputSegue"]) {
        NSIndexPath *indexpath = sender;
        Workout *workout = _fetchArray[indexpath.row];
        NSString *title = workout.title.localized;
        
        if ([segue.identifier isEqualToString:@"editSegue"]){
            EditWorkoutController *controller = segue.destinationViewController;
            controller.workoutTitle = title;
            [controller setWorkout: workout];
            controller.hidesBottomBarWhenPushed = YES;
        }else{
            CustomExerciseTableView *destViewController = segue.destinationViewController;
            [destViewController setWorkout:workout];
            destViewController.title = title;
            
            destViewController.hidesBottomBarWhenPushed = YES;
        }
    }
}

- (IBAction)editButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)editButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}

@end
