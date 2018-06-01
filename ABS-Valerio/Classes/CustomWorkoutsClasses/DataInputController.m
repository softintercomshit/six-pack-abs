#import "DataInputController.h"
#import "RecoveryViewController.h"
#import "Workout.h"

#import "EditExercisesController.h"

#import "TTAlertView.h"


@interface DataInputController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, RecoveryViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UIPickerView *setRepeatsPickerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *expolanationlLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSArray<Workout*> *fetchArray;
@property (weak, nonatomic) IBOutlet UIButton *recoveryButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;


@end

@implementation DataInputController


int selectedRow;
int recoveryMode;


- (void)viewDidLoad{
    [super viewDidLoad];
    _navigationViewHeightConstraint.constant = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    selectedRow = 2;
    [self.titleTextField setDelegate:self];
    
    self.managedObjectContext = [[DataAccessLayer sharedInstance] managedObjectContext];
    self.fetchArray = [GeneralDAO getAllexercises];
    int k =  [self getTheExercise];
    if (k == 0) {
        _titleTextField.text = _titleLabel.text = @"New Superset".localized;
    }else
        _titleTextField.text = _titleLabel.text = [@"New Superset".localized stringByAppendingString:[NSString stringWithFormat:@" %d", k]];
    _titleTextField.layer.borderColor =[UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1].CGColor;
    [self setBebasFonts];
    
    [self setTextFieldClearButton];
    [self setDoneButtonImagesState];
    
//    if(isIpad)
//        _titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:26];
    
}

-(void)setBebasFonts{
    [_titleLabel setBebasFontWithType:Bold size:29];
    [_titleTextField setBebasFontWithType:Regular size:18];
    [_recoveryButton setBebasFontWithType:Regular size:18];
    [_expolanationlLabel setBebasFontWithType:Regular size:18];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
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
     _titleTextField.rightViewMode = UITextFieldViewModeAlways;
    [ _titleTextField setRightView:clearButton];
}



-(void)clearButtonSelected:(id)sender{
    self.titleTextField.text = @"";
}


-(int)getTheExercise{
    int k = 0;
    for (int i = 0; i < [self.fetchArray count]; i++) {
        Workout *work = (Workout*)[self.fetchArray objectAtIndex:i];
        NSString *newString = [[work.title componentsSeparatedByCharactersInSet: [[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
        NSString *numberString = [[work.title componentsSeparatedByCharactersInSet: [NSCharacterSet letterCharacterSet]] componentsJoinedByString:@""];
        if ([newString isEqualToString:@"NewSuperset"]) {
            k = [numberString intValue]+1;
        }
    }
    return k;
}

#pragma mark - UITextFieldDelegate


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - UIPickerDataSource


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 10;
}

#pragma mark - UIPickerViewDelegate


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    selectedRow = (int)row+1;
}



- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1];
    label.font = [UIFont fontWithName:@"BebasNeueRegular" size:18];
    [label setTextAlignment:NSTextAlignmentCenter];
    NSString *time = [@"timeKey".localized stringByReplacingOccurrencesOfString:@":" withString:@""];
    label.text = [NSString stringWithFormat:@"%d %@", (int)row+1, row==0 ? time : @"timesKey".localized];
    return label;
}



#pragma mark - UITextfieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}


#pragma mark - Recovery View Controller Delegate

-(void)choseRecovery:(int)recovery{
    recoveryMode = recovery;
    [self.recoveryButton setTitle:RECOVERY_TYPES[recovery] forState:UIControlStateNormal];
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
                [alertView setButtonBackgroundImage:redButtonImageOff  forState:UIControlStateNormal withSize:CGSizeMake(180, 30) atIndex:i ];
                [alertView setButtonBackgroundImage:redButtonImageOn forState:UIControlStateHighlighted withSize:CGSizeMake(180, 30) atIndex:i];
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

#pragma mark -
#pragma mark - Navigation

-(IBAction)popBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"recoverySegue"]){
        RecoveryViewController* controller = segue.destinationViewController;
        controller.selectedRow = recoveryMode;
        [controller setDelegate:self];
    }else{
        EditExercisesController *controller = segue.destinationViewController;
        Workout *workout = [NSEntityDescription insertNewObjectForEntityForName:@"Workout"
                                                         inManagedObjectContext:self.managedObjectContext];
        workout.title = self.titleTextField.text;
        workout.circles = [NSNumber numberWithInt:selectedRow];
        workout.exercise = [NSSet new];
        workout.recoveryMode = [NSNumber numberWithInt:recoveryMode];
        NSError *error;
        if ([self.managedObjectContext save:&error]) {
            //        NSLog(@"Error %@", error);
        }
        controller.title = self.titleTextField.text;
        controller.workoutTitle = self.titleTextField.text;
        controller.isNew = YES;
        [controller setWorkout:workout];
    }
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"editSegue"]){
        if (([[self.titleTextField text] length] == 0)||(self.titleTextField.text == nil)){
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"attentionKey".localized message:@"fillUpTitleKey".localized delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [self styleCustomAlertView:alert];
            [self addButtonsWithBackgroundImagesToAlertView:alert];
            [[self titleTextField] resignFirstResponder];
            [alert show];
            return NO;
        }
    }
    return YES;
}

- (IBAction)backButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)backButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}

@end
