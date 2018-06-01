#import "EditExercisesController.h"
#import "Workout.h"
#import "Eercise.h"
#import "Photos.h"
#import "Repetitions.h"
#import "ExercisePrevController.h"
#import "CustomProgramCreatorViewController.h"
#import "FirstViewController.h"
#define DegreesToRadians(x) ((x) * M_PI / 180.0)


@interface EditExercisesController ()

@property (strong, nonatomic) IBOutlet UITableView *exercisesTableView;

@end



@implementation EditExercisesController


- (void)viewDidLoad{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBebasFont];
    swipeChecker = NO;
    editing = NO;
    self.managedObjectContext = [[DataAccessLayer sharedInstance] managedObjectContext];
//    self.fetchArray = [GeneralDAO getAllexercises];
    self.exerciseArray = [NSMutableArray arrayWithArray:[self fetchExercises]];
    self.clearsSelectionOnViewWillAppear = YES;
    [self.backButton setEnabled:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}


-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
    [_exercisesTableView reloadData];
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSIndexPath*    selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
}


#pragma mark - FetchExercises


-(NSArray *)fetchExercises{
    NSMutableArray *dataArray = [NSMutableArray array];
    circles = [_workout.circles intValue];
    for (int v = 0; v < [[_workout.exercise allObjects] count]; v++) {
        Eercise *exercise = (Eercise*)[[_workout.exercise allObjects] objectAtIndex:v];
        [dataArray addObject:exercise];
    }
//    for (int i = 0; i < [self.fetchArray count]; i++){
//        Workout *workout = (Workout*)[self.fetchArray objectAtIndex:i];
//        if ([workout.title isEqualToString:self.workoutTitle]) {
//            circles = [workout.circles intValue];
//            for (int v = 0; v < [[workout.exercise allObjects] count]; v++) {
//                Eercise *exercise = (Eercise*)[[workout.exercise allObjects] objectAtIndex:v];
//                [dataArray addObject:exercise];
//            }
//        }
//    }
    return [self sortArray:dataArray];
}


-(NSArray *)sortArray: (NSArray *)array{
    NSArray *sortedArray = [array sortedArrayUsingComparator: ^(id obj1, id obj2) {
        
        if ([[obj1 sort] integerValue] > [[obj2 sort] integerValue]){
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([[obj1 sort] integerValue] < [[obj2 sort] integerValue]){
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return sortedArray;
}


#pragma mark - Table view data source


-(void)reloadDataIntableView{
    [self.tableView reloadData];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return isIpad ? 120 :  80;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 100;
}


-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UILabel *footerLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 50)];
    if (self.exerciseArray.count == 0) {
        [self.tableView setEditing:NO];
        editing = NO;
        [self.editBtn setEnabled:NO];
        [footerLbl setText:@"pressButtonKey".localized];
        [footerLbl setNumberOfLines:2];
        [footerLbl setTextAlignment:NSTextAlignmentCenter];
        [footerLbl setAlpha:0.5];
    }else{
        [self.editBtn setEnabled:YES];
    }
    [footerLbl setTextColor:[UIColor colorWithRed:194/255.0 green:194/255.0 blue:194/255.0 alpha:1]];
    [footerLbl setBackgroundColor:[UIColor clearColor]];
    [footerLbl setBebasFontWithType:Regular size:16];
    return footerLbl;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    self.exerciseArray = [NSMutableArray arrayWithArray:[self fetchExercises]];
    return [self.exerciseArray count];
}


- (CustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *title = [[self.exerciseArray objectAtIndex:indexPath.row] title];
    cell.titleLabel.text = title.localized;
    cell.customImage.image = nil;
    UIImage *cellImg = [UIImage imageWithContentsOfFile:[self getImageFromExercise:[self.exerciseArray objectAtIndex:indexPath.row]]];
    UIImage *newImage;
    if ([[[self.exerciseArray objectAtIndex:indexPath.row] isCustom] boolValue]) {
        CGRect clippedRect  = CGRectMake(0, 0, 320, 320 );
        CGImageRef imageRef = CGImageCreateWithImageInRect([cellImg CGImage], clippedRect);
        newImage   = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        cell.cellImage.image = [UIImage imageNamed:@"customSet_icon@2x.png"];
        cell.customImage.image = newImage;
        CALayer *imageLayer = cell.customImage.layer;
        [imageLayer setCornerRadius:cell.customImage.frame.size.width / 2];
        [imageLayer setBorderWidth:0];
        [imageLayer setBorderColor:[[UIColor clearColor] CGColor]];
        [imageLayer setMasksToBounds:YES];
    }else{
        cell.cellImage.image = [UIImage imageWithContentsOfFile:[self getImageFromExercise:[self.exerciseArray objectAtIndex:indexPath.row]]];
    }
    
    UIImageView *selectedBackView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,370, 80)];
    selectedBackView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    cell.selectedBackgroundView = selectedBackView;
    return cell;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return true;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    Eercise *row = _exerciseArray[sourceIndexPath.row];
    [_exerciseArray removeObjectAtIndex:sourceIndexPath.row];
    [_exerciseArray insertObject:row atIndex:destinationIndexPath.row];
    
    int i = 1;
    for(Eercise *row in _exerciseArray) {
        row.sort = [NSNumber numberWithInt:i++];
    }
    NSManagedObjectContext *context = [[DataAccessLayer sharedInstance] managedObjectContext];
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Can't replace! %@ %@", error, [error localizedDescription]);
        return;
    }

}


-(NSString*)getImageFromExercise:(Eercise*)exercise
{
    NSMutableArray *pArray = [NSMutableArray new];
    if (exercise.isCustom)
    {
        for (int i = 0; i < [[exercise.photos allObjects] count]; i++) {
            Photos *photo = [[exercise.photos allObjects] objectAtIndex:i];
            [pArray addObject:photo];
        }
        if ([[exercise.photos allObjects] count]!= 0) {
            pArray = (NSMutableArray*)[self sortArray:pArray];
            NSString *path;
            NSArray *comps = [[[pArray objectAtIndex:0] photoLink] pathComponents];
            if ([comps containsObject:@"Library"]) {
                NSLog(@"1 - %@", [comps objectAtIndex:5]);
                path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                //                path = [path stringByDeletingLastPathComponent];
                //                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-3]];
                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-2]];
                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-1]];
            }
            
            
            return path;
        }
        
    }
    NSFileManager *man = [NSFileManager defaultManager];
    NSString *path;
    NSArray *comps = [exercise.link pathComponents];
    //                        path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-3]];
    path = [[NSBundle mainBundle] resourcePath];
    path = [path stringByAppendingPathComponent:@"/Default"];
    path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-2]];
    path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-1]];
    NSLog(@"DEFAULT PATH: %@", path);
    
    NSArray *fileList = [man contentsOfDirectoryAtPath:path error:nil];
    return [path stringByAppendingPathComponent:[fileList objectAtIndex:1]];
    
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.addButton setEnabled:YES];
        // Delete the row from the data source
        NSManagedObjectContext *context = [[DataAccessLayer sharedInstance] managedObjectContext];
//        CustomCell *cell = (CustomCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        NSString *exerciseTitle = [[self.exerciseArray objectAtIndex:indexPath.row] title];
        for (int j = 0; j < [_workout.exercise allObjects].count; j++) {
            Eercise *exercise = (Eercise*)[[_workout.exercise allObjects] objectAtIndex:j];
            if ([exercise.title isEqualToString:exerciseTitle]) {
                [self.exerciseArray removeObject:exercise];
                [context deleteObject:exercise];
                break;
            }
        }
//        for (NSManagedObject *product in self.fetchArray) {
//            Workout *workout = (Workout*)product;
//            
//            if ([self.title isEqualToString:workout.title])
//            {
//                for (int j = 0; j < [workout.exercise allObjects].count; j++) {
//                    Eercise *exercise = (Eercise*)[[workout.exercise allObjects] objectAtIndex:j];
//                    if ([exercise.title isEqualToString:exerciseTitle]) {
//                        [self.exerciseArray removeObject:exercise];
//                        [context deleteObject:exercise];
//                        break;
//                    }
//                }
//            }
//        }
        NSError *error;
        [context save:&error];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //        [self.tableView reloadData];
//        [self performSelector:@selector(reloadDataIntableView) withObject:nil afterDelay:0.3];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[self.exerciseArray objectAtIndex:indexPath.row] isCustom].boolValue){
        [self performSegueWithIdentifier:@"customSegue" sender:indexPath];
    }else{
        [self performSegueWithIdentifier:@"notCustomSegue" sender:indexPath];
    }
}


#pragma mark - ExercisePrevControllerDelegate

-(void)addExercise:(NSDictionary *)exercise{
    Eercise *lastEx = [_exerciseArray lastObject];
    NSLog(@"Last obj: %@", lastEx.sort);
    Eercise *exercise1 = [NSEntityDescription insertNewObjectForEntityForName:@"Eercise" inManagedObjectContext:self.managedObjectContext];
    exercise1.title = [exercise objectForKey:@"title"];
    //     NSLog(@"Check 1");
    if (![exercise objectForKey:@"descriptionPath"]){
        exercise1.link = [exercise objectForKey:@"photos"];
        exercise1.isCustom = [NSNumber numberWithBool:NO];
        
    }else{
        NSMutableArray *pArray = [NSMutableArray array];
        for (int j = 0; j < [[exercise objectForKey:@"photo"] count]; j++) {
            Photos *photos = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.managedObjectContext];
            photos.photoLink = [[exercise objectForKey:@"photo"] objectAtIndex:j];
            photos.sort = [NSNumber numberWithInt:j];
            [pArray addObject:photos];
            
        }
        exercise1.photos = [NSSet setWithArray:pArray];
        exercise1.descriptionLink = [exercise objectForKey:@"descriptionPath"];
        exercise1.isCustom = [NSNumber numberWithBool:YES];
    }
    
    [self.exerciseArray addObject:exercise1];
    //    NSLog(@"exercises: %@", self.exerciseArray);
    NSMutableArray *rArray = [NSMutableArray array];
    for (int j = 0; j < [[exercise objectForKey:@"reps"] count]; j++) {
        Repetitions *reps = [NSEntityDescription insertNewObjectForEntityForName:@"Repetitions" inManagedObjectContext:self.managedObjectContext];
        reps.repetitions = [[exercise objectForKey:@"reps"] objectAtIndex:j];
        reps.sort = [NSNumber numberWithInt:j];
        //        NSLog(@"j = %d", [self.exerciseArray count]);
        [rArray addObject:reps];
    }
    exercise1.reps = [NSSet setWithArray:rArray];
    exercise1.sort = [NSNumber numberWithInt:(int)[lastEx.sort integerValue]+1];
    if ([_workout.title isEqualToString:self.workoutTitle]) {
        circles = [_workout.circles intValue];
        _workout.exercise = [NSSet setWithArray:[self exerciseArray]];
    }
//    for (int i = 0; i < [self.fetchArray count]; i++){
//        Workout *workout = (Workout*)[self.fetchArray objectAtIndex:i];
//        if ([workout.title isEqualToString:self.workoutTitle]) {
//            circles = [workout.circles intValue];
//            workout.exercise = [NSSet setWithArray:[self exerciseArray]];
//        }
//    }
    
    
    NSError *error;
    if ([self.managedObjectContext save:&error]) {
        //    NSLog(@"Error %@", error);
    }
    
}


#pragma mark - CustomProgramCreatorControllerDelegate


-(void)sendExercise:(NSDictionary*)exerciseData{
    Eercise *lastEx = [self.exerciseArray lastObject];
    Eercise *exercise1 = [NSEntityDescription insertNewObjectForEntityForName:@"Eercise" inManagedObjectContext:self.managedObjectContext];
    exercise1.title = [exerciseData objectForKey:@"title"];
    //    NSLog(@"Check 1");
    if (![exerciseData objectForKey:@"descriptionPath"])
    {
        exercise1.link = [exerciseData objectForKey:@"photos"];
        exercise1.isCustom = [NSNumber numberWithBool:NO];
        
    }else{
        NSMutableArray *pArray = [NSMutableArray array];
        for (int j = 0; j < [[exerciseData objectForKey:@"photo"] count]; j++) {
            Photos *photos = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.managedObjectContext];
            photos.photoLink = [[exerciseData objectForKey:@"photo"] objectAtIndex:j];
            photos.sort = [NSNumber numberWithInt:j];
            [pArray addObject:photos];
            
        }
        exercise1.photos = [NSSet setWithArray:pArray];
        exercise1.descriptionLink = [exerciseData objectForKey:@"descriptionPath"];
        exercise1.isCustom = [NSNumber numberWithBool:YES];
    }
    
    [self.exerciseArray addObject:exercise1];
    
    NSMutableArray *rArray = [NSMutableArray array];
    for (int j = 0; j < [[exerciseData objectForKey:@"reps"] count]; j++) {
        Repetitions *reps = [NSEntityDescription insertNewObjectForEntityForName:@"Repetitions" inManagedObjectContext:self.managedObjectContext];
        reps.repetitions = [[exerciseData objectForKey:@"reps"] objectAtIndex:j];
        reps.sort = [NSNumber numberWithInt:j];
        [rArray addObject:reps];
        
    }
    exercise1.reps = [NSSet setWithArray:rArray];
    
    NSLog(@"last ex.sort: %@", lastEx.title);
    exercise1.sort = [NSNumber numberWithInt:(int)[lastEx.sort integerValue]+1];

    circles = [_workout.circles intValue];
    _workout.exercise = [NSSet setWithArray:[self exerciseArray]];
//    for (int i = 0; i < [self.fetchArray count]; i++)
//    {
//        Workout *workout = (Workout*)[self.fetchArray objectAtIndex:i];
//        if ([workout.title isEqualToString:self.workoutTitle]) {
//            circles = [workout.circles intValue];
//            workout.exercise = [NSSet setWithArray:[self exerciseArray]];
//        }
//    }
    NSError *error;
    if ([self.managedObjectContext save:&error]) {
        //        NSLog(@"Error %@", error);
    }
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"customSegue"]) {
        if ([sender class] == NULL) {
            CustomProgramCreatorViewController *controller = segue.destinationViewController;
            controller.delegate = self;
            controller.circles = circles;
            controller.editing = NO;
            controller.workout = _workout;
        }else if ([sender isKindOfClass:[NSIndexPath class]]) {
            CustomCell *cell = (CustomCell*)[self.tableView cellForRowAtIndexPath:sender];
            CustomProgramCreatorViewController *controller = segue.destinationViewController;
            controller.editing = YES;
            controller.exerciseTitle = cell.titleLabel.text;
            controller.workoutTitle = self.title;
            controller.workout = _workout;
        }
        
    }else if ([segue.identifier isEqualToString:@"categorySegue"]){
        //        NSLog(@"Segue performed");
        FirstViewController *controller = segue.destinationViewController;
        controller.getSixPackHideValue = YES;
        controller.circles = circles;
        controller.customType = 1;
    }else{
        CustomCell *cell = (CustomCell*)[self.tableView cellForRowAtIndexPath:sender];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSString *title = [[self.exerciseArray objectAtIndex:indexPath.row] title];
        
        ExercisePrevController *controller = segue.destinationViewController;
        [controller setWorkout:_workout];
        controller.isEditingExercise = YES;
        controller.titleString = title; //controller.titleString = cell.titleLabel.text;
        if ([[[self.exerciseArray objectAtIndex:[[self.tableView indexPathForSelectedRow] row]] isCustom] boolValue]) {
            NSString *path;
            NSArray *comps = [[[self.exerciseArray objectAtIndex:[[self.tableView indexPathForSelectedRow] row]] link] pathComponents];
            if ([comps containsObject:@"Library"]) {
                NSLog(@"1 - %@", [comps objectAtIndex:5]);
                path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                //                path = [path stringByDeletingLastPathComponent];
                //                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-3]];
                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-2]];
                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-1]];
            }
            
            controller.exercisePath = path;
        }else{
            NSString *path;
            NSArray *comps = [[[self.exerciseArray objectAtIndex:[[self.tableView indexPathForSelectedRow] row]] link] pathComponents];
            //                        path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-3]];
            path = [[NSBundle mainBundle] resourcePath];
            path = [path stringByAppendingPathComponent:@"/Default"];
            path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-2]];
            path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-1]];
            NSLog(@"DEFAULT PATH: %@", path);
            
            controller.exercisePath = path;
        }
        
        controller.exercSort = [[(Eercise*)[self.exerciseArray objectAtIndex:[[[self tableView] indexPathForSelectedRow] row]] sort] intValue];
        controller.circles = circles;
        controller.isWorkout = YES;
        controller.workTitle = self.workoutTitle;
    }
}

#pragma mark - IBActions


-(IBAction)moveBack:(id)sender{
    if (self.isNew) {
        UIViewController *controller = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-3];
        [self.navigationController popToViewController:controller animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


-(IBAction)seteditingTableiew:(id)sender{
    [self.addButton setEnabled:editing];
    if(editing){
        [_editBtn setTitle:@"" forState:UIControlStateNormal];
        [_editBtn setTitle:@"" forState:UIControlStateHighlighted];
        [_editBtn setImage:[UIImage imageNamed:@"editBtn.png"] forState:UIControlStateNormal];
        [_editBtn setImage:[UIImage imageNamed:@"editBtn.png"] forState:UIControlStateHighlighted];
        [_editBtn setTintColor:[UIColor whiteColor]];
    }else{
        [_editBtn setTitle:@"doneKey".localized forState:UIControlStateNormal];
        [_editBtn setTitle:@"doneKey".localized forState:UIControlStateHighlighted];
        [_editBtn setBebasFontWithType:Regular size:17];
        
        [_editBtn setImage:nil forState:UIControlStateNormal];
        [_editBtn setImage:nil forState:UIControlStateHighlighted];
        
        [_editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }
    editing = !editing;
    [_exercisesTableView setEditing:editing animated:YES];
}



#pragma mark - Action Sheets IBActions


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self performSegueWithIdentifier:@"categorySegue" sender:nil];
    }if (buttonIndex == 1) {
        [self performSegueWithIdentifier:@"customSegue" sender:nil];
    }
}


-(IBAction)showActionSheet:(id)sender{
    actionSh = [[UIActionSheet alloc]initWithTitle:@"optionsKey".localized delegate:self cancelButtonTitle:@"cancelKey".localized destructiveButtonTitle:nil otherButtonTitles:@"navTitleKey".localized ,@"cameraGaleryKey".localized, nil];
    actionSh.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSh showInView:self.view];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
    [view setBackgroundColor:[UIColor whiteColor]];
    UIButton *exBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *camButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [exBtn addTarget:self action:@selector(exBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [camButton addTarget:self action:@selector(camBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [exBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [exBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [camButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [camButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    
    [exBtn setTitle:@"navTitleKey".localized forState:UIControlStateNormal];
    [camButton setTitle:@"libraryAndCameraKey".localized forState:UIControlStateNormal];
    [cancelBtn setTitle:@"cancelKey".localized forState:UIControlStateNormal];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [exBtn setFrame:CGRectMake(35, 35, 250, 35)];
        [camButton setFrame:CGRectMake(35, 90, 250, 35)];
        [cancelBtn setFrame:CGRectMake(35, 160, 250, 35)];
        
    }else{
        [exBtn setFrame:CGRectMake(35, 25, 250, 35)];
        [camButton setFrame:CGRectMake(35, 75, 250, 35)];
        [cancelBtn setFrame:CGRectMake(35, 140, 250, 35)];
        
    }
    
    [exBtn setBackgroundImage:[UIImage imageNamed:@"actionSheet_frame@2x.png"] forState:UIControlStateNormal];
    [exBtn setBackgroundImage:[UIImage imageNamed:@"pressed_actionSheet_btn@2x.png"] forState:UIControlStateHighlighted];
    [camButton setBackgroundImage:[UIImage imageNamed:@"actionSheet_frame@2x.png"] forState:UIControlStateNormal];
    [camButton setBackgroundImage:[UIImage imageNamed:@"pressed_actionSheet_btn@2x.png"] forState:UIControlStateHighlighted];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"actionSheet_cancel@2x.png"] forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"pressed_actionSheet_cancel@2x.png"] forState:UIControlStateHighlighted];
    [view addSubview:exBtn];
    [view addSubview:camButton];
    [view addSubview:cancelBtn];
    [actionSh addSubview:view];
    //    [actionSh setAlpha:0.0];
}


-(IBAction)exBtnAction:(id)sender{
    [self performSegueWithIdentifier:@"categorySegue" sender:nil];
    [actionSh dismissWithClickedButtonIndex:0 animated:YES];
}


-(IBAction)camBtnAction:(id)sender{
    [self performSegueWithIdentifier:@"customSegue" sender:nil];
    [actionSh dismissWithClickedButtonIndex:1 animated:YES];
}


-(IBAction)cancelAction:(id)sender{
    [actionSh dismissWithClickedButtonIndex:2 animated:YES];
}

- (IBAction)backButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
    [sender setTitleColor:RGBA(255, 255, 255, .4) forState:UIControlStateNormal];
    [sender setTitleColor:RGBA(255, 255, 255, .4) forState:UIControlStateHighlighted];
}

- (IBAction)backButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

@end
