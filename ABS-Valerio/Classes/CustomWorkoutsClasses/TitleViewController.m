#import "TitleViewController.h"

@interface TitleViewController ()

@end

@implementation TitleViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    [self setEditing:YES animated:YES];
    [self setTitle:@"titleKey".localized];
    [self.navigationController.navigationBar setBebasFont];
    
    _titleView.text = _titleString;
    [_titleView becomeFirstResponder];
    [_titleView setRightViewMode:UITextFieldViewModeAlways];
    _titleView.layer.borderColor = [UIColor colorWithRed:232/255.0 green:232/255.0  blue:232/255.0  alpha:1].CGColor;
    [self setTextFieldClearButton];
    
    [_titleView setBebasFontWithType:Regular size:16];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}



-(void)setTextFieldClearButton{
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"btnClearTextField"] forState:UIControlStateNormal];
    [clearButton setBackgroundColor:[UIColor clearColor]];
    [clearButton setFrame:CGRectMake(0, 0, 30, 30)];
    [clearButton addTarget:self action:@selector(clearButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    _titleView.rightViewMode = UITextFieldViewModeAlways;
    [ _titleView setRightView:clearButton];
}


#pragma mark - IBactions


-(void)clearButtonSelected:(id)sender{
    self.titleView.text = @"";
}


-(IBAction)back:(id)sender{
    if ([self.titleView.text length] == 0) {
        TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"attentionKey".localized message:@"fillUpKey".localized delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self styleCustomAlertView:alert];
        [self addButtonsWithBackgroundImagesToAlertView:alert];
        [self.titleView resignFirstResponder];
        [alert show];
        [sender setTintColor:[UIColor whiteColor]];
    }else{
        [self.delegate goBack:self.titleView.text];
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

- (IBAction)backButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)backButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}
@end
