#import "SuperSetsInterfaceController.h"
#import "Utils.h"
#import "ExerciseTypesRow.h"
@interface SuperSetsInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceTable *superSetsTable;

@end

@implementation SuperSetsInterfaceController

NSString* superSetsControllerTitle;
NSArray* workoutArray;
- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    superSetsControllerTitle=context;
    [[Utils sharedInstance]getSuperSetsValues:^(id result) {
        workoutArray=result;
    }];
}

- (void)willActivate {
    [super willActivate];
    [self setTitle:superSetsControllerTitle];
    [self initTableWithData:^(NSArray *tableComponents) {
         [self configureTableWithData:tableComponents];
    }];
}

-(void)initTableWithData:(void(^)(NSArray* tableComponents))completionMethod{
    completionMethod(workoutArray);
}

- (void)configureTableWithData:(NSArray*)dataObjects {
    [self.superSetsTable setNumberOfRows:[dataObjects count] withRowType:@"SuperSetsRow"];
    for (NSInteger i = 0; i < self.superSetsTable.numberOfRows; i++) {
        ExerciseTypesRow* exerciseRow = [self.superSetsTable rowControllerAtIndex:i];
        NSDictionary* workoutData=dataObjects[i][@"workout"];
        [exerciseRow.exerciseName setText:workoutData[@"name"]];
    }
}


-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    //NSMutableDictionary* dictWithValuesForSend=exercisesTypesArray[rowIndex];
    NSDictionary* dictWithValuesForTransfer=workoutArray[rowIndex];
    [self pushInterfaceController:dictWithValuesForTransfer];
}

-(void)pushInterfaceController:(NSDictionary*)content{
    [self pushControllerWithName:@"SuperSetContentInterfaceController" context:content];
}

@end



