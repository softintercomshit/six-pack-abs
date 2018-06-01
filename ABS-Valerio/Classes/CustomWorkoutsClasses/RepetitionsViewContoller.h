#import <UIKit/UIKit.h>


@protocol RepetitionsViewContollerDelegate <NSObject>

@optional
-(void)returnRepetitions:(NSArray*)circlesArray;

@end

@interface RepetitionsViewContoller : UIViewController

@property (weak, nonatomic) IBOutlet UIPickerView *persPicker;
@property (nonatomic, readwrite) int circles;
@property (nonatomic, retain)NSMutableArray* repsArray;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (nonatomic, retain) id <RepetitionsViewContollerDelegate> delegate;

-(IBAction)moveBack:(id)sender;


@end
