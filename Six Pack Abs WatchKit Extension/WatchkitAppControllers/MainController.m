#import "MainController.h"
#import "ExerciseTypesRow.h"
#import "Utils.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"


@interface MainController()

@property (weak, nonatomic) IBOutlet WKInterfaceTable *exercisesTypesTable;

@end

@implementation MainController

-(void)awakeWithContext:(id)context{
    NSArray *categoriesArray = @[@"exercisesItemKey".localized.capitalizedString, @"workouts".localized.capitalizedString, @"customItemKey".localized.capitalizedString];
    [self configureTableWithData: categoriesArray];
    [self setTitle:@"Main".localized];
}

//- (void)willActivate {
//    [super willActivate];
//    NSArray *categoriesArray = @[@"exercisesItemKey".localized.capitalizedString, @"Workouts".localized.capitalizedString, @"customItemKey".localized.capitalizedString];
//    [self configureTableWithData: categoriesArray];
//    [self setTitle:@"Main".localized];
//}

- (void)configureTableWithData:(NSArray*)dataObjects {
    [self.exercisesTypesTable setNumberOfRows:[dataObjects count] withRowType:@"ExerciseTypesRow"];
//    NSArray* imagesNameArray = [self getCellImages];
    for (NSInteger i = 0; i < self.exercisesTypesTable.numberOfRows; i++) {
        ExerciseTypesRow* exerciseRow = [self.exercisesTypesTable rowControllerAtIndex:i];
        NSString *exerciseName = dataObjects[i];
        [exerciseRow.exerciseName setText:exerciseName];
        [exerciseRow.rowGroup setBackgroundImage:[UIImage imageNamed:@"exerciseCellRed"]];
//        [exerciseRow.rowGroup setBackgroundImage:[UIImage imageNamed:imagesNameArray[i]]];
    }
}

//-(NSArray*)getCellImages{
//    if([[Utils sharedInstance] isWatch48MM]){
//        return @[@"easy.png", @"medium.png", @"hard.png"];
//    }
//    return @[@"easy.png", @"medium.png", @"hard.png"];
//}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    switch (rowIndex) {
        case 0:
            [self pushControllerWithName:@"InterfaceController" context:nil];
            break;
        case 1:
            [self pushControllerWithName:@"WorkoutsController" context:nil];
            break;
        case 2:
            [self pushControllerWithName:@"CustomWorkoutsController" context:nil];
            break;
        default:
            break;
    }
}

@end
