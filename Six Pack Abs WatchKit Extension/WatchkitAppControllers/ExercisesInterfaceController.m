#import "ExercisesInterfaceController.h"
#import "ExerciseTypesRow.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"
#import "Utils.h"


@interface ExercisesInterfaceController ()
@property (weak,nonatomic)IBOutlet WKInterfaceTable* exercisesTable;
@end

@implementation ExercisesInterfaceController
NSString* typeName;
NSDictionary *contentsTypeDict;
NSArray *exercisesNames;
- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    typeName=[context allKeys][0];
    contentsTypeDict=context[typeName];
    exercisesNames=[[contentsTypeDict allKeys]sortedArrayUsingSelector: @selector(compare:)];
}

- (void)willActivate {
    [super willActivate];
    [self configureTableWithData:exercisesNames];
    [self setTitle:typeName.localized];
}

- (void)configureTableWithData:(NSArray*)dataObjects {
    [self.exercisesTable setNumberOfRows:[dataObjects count] withRowType:@"ExerciseRow"];
    for (NSInteger i = 0; i < self.exercisesTable.numberOfRows; i++) {
        ExerciseTypesRow* exerciseRow = [self.exercisesTable rowControllerAtIndex:i];
        NSString *exerciseName = dataObjects[i];
        [exerciseRow.exerciseName setText:exerciseName.localized];
//        [exerciseRow.rowGroup setBackgroundImage:[UIImage imageNamed:@"exerciseCell.png"]];
        
        NSString *imageName = contentsTypeDict[exerciseName][0];
        UIImage *image = [UIImage imageNamed:[imageName stringByAppendingString:@"@2x.jpg"]];
//        if ([imageName isEqualToString:@"2starsitup"]) {
//            NSLog(@"%@", image);
//        }
//        image = [Utils changeWhiteColorTransparent:image];
        [exerciseRow.exerciseImageGroup setBackgroundImage:image];
    }
}

-(void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex{
    NSString* exerciseName=exercisesNames[rowIndex];
    NSDictionary* dictWithValuesForTransfer=[NSDictionary dictionaryWithObjectsAndKeys:typeName,@"typeName",exerciseName,@"exerciseName",contentsTypeDict[exerciseName],@"exerciseInfo",nil];
    [self pushInterfaceController:dictWithValuesForTransfer];
}

-(void)pushInterfaceController:(NSDictionary*)content{
    [self pushControllerWithName:@"ImagesGuideInterfaceController" context:content];
}

@end



