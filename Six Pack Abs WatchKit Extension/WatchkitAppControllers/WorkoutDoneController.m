#import "WorkoutDoneController.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"


@interface WorkoutDoneController()

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *workoutLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *doneLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *kcalLabel;

@end

@implementation WorkoutDoneController

-(void)awakeWithContext:(id)context{
    [_workoutLabel setText:@"workout".localized];
    [_doneLabel setText:@"done".localized];
    [_kcalLabel setText:[NSString stringWithFormat:@"%@ %@", context, @"kcalKEY".localized]];
    
    [self performSelector:@selector(dismissController) withObject:nil afterDelay:3];
}

-(void)willDisappear{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"workoutDoneControllerDismissed" object:nil];
}

@end
