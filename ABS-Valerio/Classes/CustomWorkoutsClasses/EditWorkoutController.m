#import "EditWorkoutController.h"


@interface EditWorkoutController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, RecoveryViewControllerDelegate>


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UILabel *navigationTitleLabel;
//@property (nonatomic, retain) NSArray *fetchArray;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;


@end



@implementation EditWorkoutController{
    IBOutletCollection(UIButton) NSArray *buttons;
    BOOL needToCancelSaves;
}


int recoveryMode;


- (void)viewDidLoad{
    [super viewDidLoad];
//    [self.circlesPicker setDataSource:self];
//    [self.circlesPicker setDelegate:self];
    self.managedObjectContext = [[DataAccessLayer sharedInstance] managedObjectContext];
//    self.fetchArray = [GeneralDAO getAllexercises];
    [self getTheExercise];
    
    [_titleInput setDelegate:self];
    [_titleInput setBebasFontWithType:Regular size:16];
    
    _navigationTitleLabel.text = @"editSupersetKey".localized;
    _titleInput.layer.borderColor =[UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1].CGColor;
    [self setTextFieldClearButton];
    [self setDoneButtonImagesState];

    [_navigationTitleLabel setBebasFontWithType:Bold size:29];
    
    for (UIButton *button in buttons) {
        [button setBebasFontWithType:Regular size:16];
    }
//    if(isIpad)
//        _navigationTitleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:26];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
//    [[UIApplication sharedApplication].keyWindow setBackgroundColor:RGBA(223, 49, 53, 1)];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (!needToCancelSaves) {
//        for (int i = 0; i < [self.fetchArray count]; i++) {
//            Workout *work = (Workout*)[self.fetchArray objectAtIndex:i];
//            if ([work.title isEqualToString:self.workoutTitle]) {
//                work.title = [self.titleInput text];
//                work.recoveryMode = [NSNumber numberWithInt:recoveryMode];
//            }
//        }
        _workout.title = self.titleInput.text;
        _workout.recoveryMode = [NSNumber numberWithInt:recoveryMode];

        NSError *error;
        [self.managedObjectContext save:&error];
    }
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    _navigationViewHeightConstraint.constant = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
}

-(void)setDoneButtonImagesState{
    _doneButton.layer.borderColor = GREEN_COLOR.CGColor;
    [_doneButton setBackgroundImage:[ImageUtility imageWithColor:GREEN_COLOR] forState:UIControlStateNormal];
    [_doneButton setBackgroundImage:[ImageUtility imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
}


-(void)setTextFieldClearButton{
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"btnClearTextField"] forState:UIControlStateNormal];
    [clearButton setBackgroundColor:[UIColor clearColor]];
    [clearButton setFrame:CGRectMake(0, 0, 30, 30)];
    [clearButton addTarget:self action:@selector(clearButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    _titleInput.rightViewMode = UITextFieldViewModeAlways;
    [_titleInput setRightView:clearButton];
}


#pragma mark - data for exercise


-(void) getTheExercise{
    self.titleInput.text = self.workoutTitle;
    recoveryMode = _workout.recoveryMode.intValue;
    
//    for (int i = 0; i < [self.fetchArray count]; i++) {
//        Workout *work = (Workout*)[self.fetchArray objectAtIndex:i];
//        if ([work.title isEqualToString:self.workoutTitle]) {
//            self.titleInput.text = self.workoutTitle;
//            recoveryMode =[[(Workout*)[self.fetchArray objectAtIndex:i] recoveryMode] intValue];
////            [self.circlesPicker selectRow:[work.circles integerValue] inComponent:0 animated:YES];
////            [self.circlesPicker reloadComponent:0];
//        }
//    }
}


#pragma mark - IBActions


-(void)clearButtonSelected:(id)sender{
    self.titleInput.text = @"";
}


-(IBAction)goBack:(id)sender{
    if ([self.titleInput.text length] == 0) {
        TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Attention!" message:@"Fill the title field!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [self styleCustomAlertView:alert];
        [self addButtonsWithBackgroundImagesToAlertView:alert];
        [alert show];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - TTAlertView


- (void)styleCustomAlertView:(TTAlertView *)alertView{
    [alertView.containerView setImage:[[UIImage imageNamed:@"alert.bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(11.0f, 13.0f, 14.0f, 13.0f)]];
    [alertView.containerView setBackgroundColor:[UIColor clearColor]];
    [alertView.titleLabel setTextColor:[UIColor colorWithRed:255.0f/255.0f green:37.0f/255.0f blue:58.0f/255.0f alpha:1.0f]];
    [alertView.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [alertView.messageLabel setTextColor:[UIColor colorWithRed:255.0f/255.0f green:37.0f/255.0f blue:58.0f/255.0f alpha:1.0f]];
    alertView.buttonInsets = UIEdgeInsetsMake(alertView.buttonInsets.top, alertView.buttonInsets.left + 4.0f, alertView.buttonInsets.bottom + 6.0f, alertView.buttonInsets.right + 4.0f);
}


- (void)addButtonsWithBackgroundImagesToAlertView:(TTAlertView *)alertView{
    UIImage *redButtonImageOff = [UIImage imageNamed:@"actionSheet_cancel@2x.png"];
    UIImage *redButtonImageOn = [UIImage imageNamed:@"actionSheet_frame@2x.png"];
    
    UIImage *greenButtonImageOff = [[UIImage imageNamed:@"actionSheet_frame@2x.png"] stretchableImageWithLeftCapWidth:2.0 topCapHeight:2.0];
    UIImage *greenButtonImageOn = [[UIImage imageNamed:@"actionSheet_cancel@2x.png"] stretchableImageWithLeftCapWidth:2.0 topCapHeight:2.0];
    
    for(int i = 0; i < [alertView numberOfButtons]; i++) {
        if (i == 0) {
            if (i+1 == [alertView numberOfButtons]) {
                [alertView setButtonBackgroundImage:redButtonImageOff  forState:UIControlStateNormal withSize:CGSizeMake(192, 26) atIndex:i ];
                [alertView setButtonBackgroundImage:redButtonImageOn forState:UIControlStateHighlighted withSize:CGSizeMake(192, 26) atIndex:i];
            }else{
                [alertView setButtonBackgroundImage:redButtonImageOff  forState:UIControlStateNormal withSize:CGSizeMake(120, 22) atIndex:i ];
                [alertView setButtonBackgroundImage:redButtonImageOn forState:UIControlStateHighlighted withSize:CGSizeMake(120, 22) atIndex:i];
            }
        } else {
            [alertView setButtonBackgroundImage:greenButtonImageOff forState:UIControlStateNormal withSize:CGSizeMake(120, 22) atIndex:i];
            [alertView setButtonBackgroundImage:greenButtonImageOn forState:UIControlStateHighlighted withSize:CGSizeMake(120, 22 ) atIndex:i];
        }
    }
}


#pragma mark - UITextFieldDelegate


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UIPIckerViewDaaSource


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 30;
}


#pragma mark - UIPickerview Delegate


- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%d", (int)row];
}


#pragma mark - Recovery View Controller Delegate


-(void)choseRecovery:(int)recovery{
    recoveryMode = recovery;
    [self.recoveryButton setTitle:RECOVERY_TYPES[recovery] forState:UIControlStateNormal];
}


#pragma mark - Navigation


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"recoverySegue"]) {
        RecoveryViewController *controller = segue.destinationViewController;
        controller.selectedRow = recoveryMode;
        [controller setDelegate:self];
    }else{
        EditWorkoutController *controller = segue.destinationViewController;
        controller.title = self.workoutTitle;
        [controller setWorkout:_workout];
        controller.workoutTitle = self.workoutTitle;
    }
}

- (IBAction)backButtonAction:(id)sender {
    needToCancelSaves = true;
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)backButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)backButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}

@end
