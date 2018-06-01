#import "NewWorkoutController.h"
#import "WorkoutData.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"

typedef NS_ENUM(NSInteger, SelectedSegue){
    RecoveryTime,
    Repeats
};

@interface NewWorkoutController()

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *recoveryTimeButton;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *repeatsButton;

@end

@implementation NewWorkoutController{
    NSMutableArray<WKPickerItem*> *pickerItems;
    SelectedSegue selectedSegue;
    WorkoutData *newWorkout;
}

-(void)awakeWithContext:(id)context{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pickerControllerCallback:) name:@"pickerControllerCallback" object:nil];
    
    newWorkout = [WorkoutData new];
    [self createWorkoutName];
}

-(void)createWorkoutName{
#warning need to create workout name
    newWorkout.name = @"some workout";
}

-(id)contextForSegueWithIdentifier:(NSString *)segueIdentifier{
    pickerItems = [NSMutableArray array];
    
    if ([segueIdentifier isEqualToString:@"repeatsIdentifier"]) {
        for (int i=0; i<10; i++) {
            NSString *title = [NSString stringWithFormat:@"%d %@", i+1, i==0 ? @"timeKey".localized : @"timesKey".localized];
            WKPickerItem *pickerItem = [WKPickerItem new];
            [pickerItem setTitle:title];
            [pickerItems addObject:pickerItem];
        }
        
        selectedSegue = Repeats;
        return pickerItems;
    }
    
    NSArray *titlesArray = @[@"Every 2 exercises", @"Every 3 exercises", @"Every circle", @"No recovery at all"];
    for (NSString *title in titlesArray) {
        WKPickerItem *pickerItem = [WKPickerItem new];
        [pickerItem setTitle:title.localized];
        [pickerItems addObject:pickerItem];
    }
    
    selectedSegue = RecoveryTime;
    return pickerItems;
}

-(void)pickerControllerCallback:(NSNotification *)notification{
    NSInteger selectedIndex = [notification.object integerValue];
    NSString *buttonNewTitle = pickerItems[selectedIndex].title.localized;
    
    switch (selectedSegue) {
        case Repeats:
            [_repeatsButton setTitle:buttonNewTitle];
            newWorkout.repeats = selectedIndex+1;
            break;
        case RecoveryTime:
            [_recoveryTimeButton setTitle:buttonNewTitle];
            newWorkout.recoveryMode = selectedIndex;
            break;
        default:
            break;
    }
}

@end
