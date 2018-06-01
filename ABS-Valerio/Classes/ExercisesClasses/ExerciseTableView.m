#import "ExerciseTableView.h"
#import "ExercisePrevController.h"
#import "CustomCell.h"

@interface ExerciseTableView ()
//@property (weak, nonatomic) IBOutlet UILabel *titlelLabel;

@end

@implementation ExerciseTableView


- (void)viewDidLoad{
    [super viewDidLoad];
    [self fetchExercises];
}


-(NSMutableArray*)imagesForTable{
    NSMutableArray *imageArr = [NSMutableArray array];
    for (int i = 0; i< [_exerciseArray count]; i++) {
        NSFileManager *manager = [NSFileManager defaultManager];
        NSArray *fileList = [manager contentsOfDirectoryAtPath:[self.exerciseArray objectAtIndex:i] error:nil];
        fileList = [fileList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSString *exercisepath = self.exerciseArray[i];
        NSString *imageName = fileList[0];
        NSString *imagePath = [exercisepath stringByAppendingPathComponent: imageName];
        
        [imageArr addObject: imagePath];
    }
    return imageArr;
}

-(void)fetchExercises{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:_exercisePath error:nil];
    fileList = [fileList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    _exerciseArray= [NSMutableArray array];
    for (int i =0 ; i<fileList.count; i++){
        [_exerciseArray addObject:[_exercisePath stringByAppendingPathComponent:[fileList objectAtIndex:i]]];
    }
    arrWithImages = [NSArray arrayWithArray:[self imagesForTable]];
}


#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _exerciseArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  isIpad ? 120 : 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *title = [[self.exerciseArray objectAtIndex:indexPath.row] lastPathComponent];
    cell.titleLabel.text = title.localized;
    cell.cellImage.image = [UIImage imageWithContentsOfFile:[arrWithImages objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - Table view Delegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"    " style:UIBarButtonItemStylePlain target:nil action:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ExercisePrevController *destViewController = segue.destinationViewController;
    CustomCell *cell = (CustomCell*)sender;
    // Hide bottom tab bar in the detail view
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSString *title = [[self.exerciseArray objectAtIndex:indexPath.row] lastPathComponent];
    destViewController.titleString = title;
    NSString *path = [self.exercisePath stringByAppendingString:[NSString stringWithFormat:@"/%@", title]];
//    destViewController.navigationItem.backBarButtonItem.title = self.title;
    destViewController.exercisePath = path;
    destViewController.custom = 0;
    destViewController.isWithVideo = 1;
    //    NSLog(@"PATH: %@",path );
    destViewController.hidesBottomBarWhenPushed = YES;
    
    
    
    destViewController.custom = _customType;
    destViewController.circles = _circles;
    
    
    
    
//    
//    destViewController.custom = 1;
//    destViewController.circles = self.circles;
    
    
    
    
    
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - IBActions

- (IBAction)goback:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)backButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}

@end
