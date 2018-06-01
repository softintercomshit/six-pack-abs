#import "RepetitionsViewContoller.h"

@interface RepetitionsViewContoller () <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation RepetitionsViewContoller{
    __weak IBOutlet UILabel *infoLabel;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    [infoLabel setBebasFontWithType:Regular size:17];
    self.navigationItem.title = @"timeKey".localized;
    if ([self.repsArray count]!=0){
        for (int k = 0;  k < self.circles; k ++ ) {
            [_persPicker  selectRow:[[self.repsArray objectAtIndex:k] intValue]-1  inComponent:k animated:NO];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}


#pragma mark - UipickerViewDataSource


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return _circles;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 100;
}


#pragma mark - UIPickerViewDelegate


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1];
//    label.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    [label setBebasFontWithType:Regular size:22];
    [label setTextAlignment:NSTextAlignmentCenter];
    label.text = [NSString stringWithFormat:@"%d", (int)(row+1)*2];
    return label;
}


#pragma mark - Navigation


-(void)viewWillDisappear:(BOOL)animated{
    self.repsArray = [NSMutableArray array];
    for (int i = 0; i < _circles; i++) {
        [_repsArray addObject:[NSNumber numberWithInt:(int)[_persPicker selectedRowInComponent:i] + 1]];
    }
    
    [self.delegate returnRepetitions:_repsArray];
}


-(IBAction)moveBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)backButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}

@end
