#import "WorkoutPickerController.h"

@interface WorkoutPickerController()

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfacePicker *pickerOutlet;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *selectedItemLabel;

@end

@implementation WorkoutPickerController{
    NSArray<WKPickerItem*> *pickerItems;
    NSInteger selectedPickerIndex;
}

-(void)awakeWithContext:(id)context{
    pickerItems = context;
    
    [_pickerOutlet setItems:pickerItems];
    [_pickerOutlet setSelectedItemIndex:0];
    [_selectedItemLabel setText:pickerItems[0].title];
}

- (IBAction)pickerAction:(NSInteger)value {
    selectedPickerIndex = value;
    [_selectedItemLabel setText:pickerItems[value].title];
}

- (IBAction)selectItemAction {
    NSNotification *notification = [[NSNotification alloc] initWithName:@"pickerControllerCallback" object:@(selectedPickerIndex) userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self dismissController];
}

@end
