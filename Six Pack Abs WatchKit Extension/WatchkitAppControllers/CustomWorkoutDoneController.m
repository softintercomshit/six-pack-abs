#import "CustomWorkoutDoneController.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"


@interface CustomWorkoutDoneController()

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *workoutLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *doneLabel;

@end

@implementation CustomWorkoutDoneController

-(void)awakeWithContext:(id)context{
    [_workoutLabel setText:@"workout".localized];
    [_doneLabel setText:@"done".localized];
    
    [self performSelector:@selector(dismissController) withObject:nil afterDelay:3];
}

-(void)willDisappear{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"workoutDoneControllerDismissed" object:nil];
}

@end
