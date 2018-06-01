#import "DescriptionViewController.h"

@interface DescriptionViewController ()

@end

@implementation DescriptionViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"descriptionKey".localized;
    _descriptionView.text = _descrString.localized;
    _descriptionView.layer.borderColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1].CGColor;
    [_descriptionView setBebasFontWithType:Regular size:16];
    [self setPlaceHolder];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}



-(void)setPlaceHolder{
    if (![self.descriptionView hasText]) {
        lbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0,self.descriptionView.frame.size.width - 10.0, 34.0)];
        [lbl setText:@"addDescriptionKey".localized];
//        [lbl setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
        [lbl setBebasFontWithType:Regular size:16];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setTextColor:[UIColor lightGrayColor]];
        [self.descriptionView addSubview:lbl];
    }
}


#pragma mark - TextField delegate


- (void)textViewDidEndEditing:(UITextView *)theTextView{
    if (![theTextView hasText]) {
        lbl.hidden = NO;
    }
}


- (void) textViewDidChange:(UITextView *)textView{
    if(![textView hasText]) {
        lbl.hidden = NO;
    }else{
        lbl.hidden = YES;
    }
}


#pragma mark - IBActions


-(IBAction)back:(id)sender{
    [self.delegate returnDescription:self.descriptionView.text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)backButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}
@end
