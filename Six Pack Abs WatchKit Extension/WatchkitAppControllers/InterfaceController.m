#import "InterfaceController.h"
#import "ExerciseTypesRow.h"
#import "Utils.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"


@interface InterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *exercisesTypesTable;
@end
@implementation InterfaceController

NSArray* exercisesTypesArray;


- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    exercisesTypesArray=[Utils extractDataFromPlist];
    [self configureTableWithData:exercisesTypesArray];
    [self setTitle:@"exercisesItemKey".localized];
}


- (void)willActivate {
    [super willActivate];
}

- (void)configureTableWithData:(NSArray*)dataObjects {
    [self.exercisesTypesTable setNumberOfRows:[exercisesTypesArray count]-1 withRowType:@"ExerciseTypesRow"];
    NSArray* imagesNameArray=[self getCellImages];
    for (NSInteger i = 0; i < self.exercisesTypesTable.numberOfRows; i++) {
        ExerciseTypesRow* exerciseRow = [self.exercisesTypesTable rowControllerAtIndex:i];
        NSString *exerciseName = [exercisesTypesArray[i] allKeys][0];
        [exerciseRow.exerciseName setText: exerciseName.localized];
        [exerciseRow.rowGroup setBackgroundImage:[UIImage imageNamed:imagesNameArray[i]]];
    }
}

-(NSArray*)getCellImages{
    if([[Utils sharedInstance] isWatch48MM]){
        return @[@"easy.png",@"medium.png",@"hard.png",@"accessories.png"];
    }
    return @[@"easy.png",@"medium.png",@"hard.png",@"accessories.png"];
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    [self pushInterfaceController:exercisesTypesArray[rowIndex]];
}


-(void)pushInterfaceController:(NSDictionary*)content{
    [self pushControllerWithName:@"ExercisesInterfaceController" context:content];
}

@end
