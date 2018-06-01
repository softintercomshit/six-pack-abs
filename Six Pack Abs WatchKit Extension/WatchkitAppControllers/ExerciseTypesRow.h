#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>
@interface ExerciseTypesRow : NSObject
    
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *exerciseName;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *rowGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *exerciseImageGroup;

@end
