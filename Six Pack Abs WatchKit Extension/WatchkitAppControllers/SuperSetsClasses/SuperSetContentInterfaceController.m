#import "SuperSetContentInterfaceController.h"
#import "SuperSetContentRow.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"


@interface SuperSetContentInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *setContentTable;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *startButton;

@end

@implementation SuperSetContentInterfaceController
NSString* superSetsContentTitle;
NSDictionary* workoutInfo;
NSArray* exercisesArray;
- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    workoutInfo=context;
    exercisesArray=context[@"exercises"];
    superSetsContentTitle=workoutInfo[@"workout"][@"name"];
}

- (void)willActivate {
    [super willActivate];
    [self setTitle:superSetsContentTitle];
    [self configureTableWithData:exercisesArray];
}

- (void)configureTableWithData:(NSArray*)dataObjects {
    [self.setContentTable setNumberOfRows:[dataObjects count] withRowType:@"SuperSetContentRow"];
    for (NSInteger i = 0; i < self.setContentTable.numberOfRows; i++) {
        SuperSetContentRow* setContentRow = [self.setContentTable rowControllerAtIndex:i];
        NSString *exerciseName = dataObjects[i][@"name"];
        [setContentRow.exerciseNameLabel setText:exerciseName.localized];
        NSString* exerciseInfo = [NSString stringWithFormat:@"%@ %@",workoutInfo[@"workout"][@"circles"], @"circlesKey".localized];
        [setContentRow.exerciseInfoLabel setText:exerciseInfo];
    }
}

- (IBAction)startButtonAction{
    [self pushControllerWithName:@"SuperSetImagesGuideInterfaceController" context:workoutInfo];
}

@end



