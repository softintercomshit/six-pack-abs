#import "CustomProgramCreatorViewController.h"
#import "TitleViewController.h"
#import "DescriptionViewController.h"
#import "RepetitionsViewContoller.h"

@interface CustomProgramCreatorViewController ()
@property (weak, nonatomic) IBOutlet UITableView *customExerciseTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationViewHeightConstraint;

@end

@implementation CustomProgramCreatorViewController{
    __weak IBOutlet UILabel *navigationLabel;
    __weak IBOutlet UILabel *exercisesLabel;
}
@synthesize exerciseTitle;


- (void)viewDidLoad{
    [super viewDidLoad];
    imagePickerController = [[UIImagePickerController alloc]init];
    [imagePickerController setDelegate:self];
    photoArray = [[NSMutableArray alloc] init];
    
    [exercisesLabel setBebasFontWithType:Regular size:20];
    [navigationLabel setBebasFontWithType:Bold size:29];
    
    if (self.editing) {
        self.managedObjectContext = [[DataAccessLayer sharedInstance] managedObjectContext];
        self.fetchArray = [GeneralDAO getAllexercises];
        exercise = [self getExerciseFromWorkout:_workout];
        [self getExerciseData];
    }
    
    _navigationViewHeightConstraint.constant = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [_customExerciseTableView reloadData];
}


-(void) deleteExercise : (Eercise*)exercise1{
    NSManagedObjectContext *context = [[DataAccessLayer sharedInstance] managedObjectContext];
    [context deleteObject:exercise1];
    NSError *error;
    [context save:&error];
}


-(IBAction)saveExercise:(id)sender{
    if ((exerciseTitle == nil) || (repsArray == nil) || !photoArray.count) {
        TTAlertView *alert1 = [[TTAlertView alloc] initWithTitle:@"attentionKey".localized message:@"fillUpKey".localized delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [self styleCustomAlertView:alert1];
        [self addButtonsWithBackgroundImagesToAlertView:alert1];
        [alert1 show];
        return;
    }
    [self writeFile:exerciseTitle data:descriptionString];
    [self addScrollViewContent:photoArray withScrollView:_imageScrollView];
    if (photoArray.count == 0) {
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"no-photo.png"];
        [photoArray addObject:path];
    };
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:exerciseTitle forKey:@"title"];
    [dictionary setObject:photoArray forKey:@"photo"];
    [dictionary setObject:repsArray forKey:@"reps"];
    [dictionary setObject:descriptionPath forKey:@"descriptionPath"];
    [dictionary setObject:@"custom" forKey:@"isCustom"];
    
    if (self.editing) {
        exercise.title = exerciseTitle;
        NSMutableSet* set = [[NSMutableSet alloc] init];
        //        NSLog(@"*****Photo array: %@", photoArray);
        for (int i = 0; i < [photoArray count]; i++) {
            
            Photos *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:self.managedObjectContext];
            photo.photoLink = [photoArray objectAtIndex:i];
            photo.sort = [NSNumber numberWithInt:i];
            [set addObject:photo];
        }
        exercise.photos = set;
        
        set = [[NSMutableSet alloc] init];
        for (int i = 0; i < [repsArray count]; i++) {
            Repetitions *reps = [NSEntityDescription insertNewObjectForEntityForName:@"Repetitions" inManagedObjectContext:self.managedObjectContext];
            reps.repetitions = [repsArray objectAtIndex:i];
            reps.sort = [NSNumber numberWithInt:i];
            [set addObject:reps];
        }
        exercise.reps = set;
        NSError *error;
        if ([self.managedObjectContext save:&error]) {
            NSLog(@"Error %@", error);
        }
        
    }
    
    [self.delegate sendExercise:dictionary];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)cancelAlert{
    //    [UIView animateWithDuration:0.5 animations:^{
    //        [alert setAlpha:0.0];
    //    }completion:^(BOOL finished) {
    //        [alert removeFromSuperview];
    //        alert = nil;
    //    }];
}


-(void)writeFile:(NSString *)fileName data:(id)data{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSError *error=NULL;
    [data writeToFile:appFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    descriptionPath = appFile;
}


-(NSString *)readFile:(NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:appFile]){
        NSError *error= NULL;
        id resultData=[NSString stringWithContentsOfFile:appFile encoding:NSUTF8StringEncoding error:&error];
        if (error == NULL){
            return resultData;
        }
    }
    return NULL;
}


#pragma mark - Open Exercise Data to Edit


-(Eercise*) getExerciseFromWorkout: (Workout*)workout{
    for (int i = 0; i < [[workout.exercise allObjects] count]; i++) {
        Eercise* exercise1 = [[workout.exercise allObjects] objectAtIndex:i];
        if ([exercise1.title isEqualToString:self.exerciseTitle]) {
            return  exercise1;
        }
    }
    return nil;
}


-(void)getExerciseData{
    exerciseTitle = exercise.title;
    NSError *error;
    descriptionString = [NSString stringWithContentsOfFile:exercise.descriptionLink encoding:NSUTF8StringEncoding error:&error];
    descriptionPath = exercise.descriptionLink;
    
    repsArray = [NSArray arrayWithArray:[self getrepsArray]];
    self.circles = (int)[repsArray count];
    repsString = [NSString stringWithFormat:@"%d %@ ", self.circles, @"circleAndKey".localized];
    for (int i = 0; i < [repsArray count]-1; i++)
    {
        repsString = [repsString stringByAppendingString:[NSString stringWithFormat:@"%d/",[[repsArray objectAtIndex:i] intValue]*2]];
    }
    repsString = [repsString stringByAppendingString:[NSString stringWithFormat:@"%d %@", [[repsArray lastObject] intValue]*2, @"secondsKey".localized]];
    photoArray = [NSMutableArray arrayWithArray:[self getPhotoarray]];
    [self addScrollViewContent:[self getPhotoarray] withScrollView:_imageScrollView];
}


-(NSMutableArray *)getPhotoarray{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < [[exercise.photos allObjects] count]; i++){
        Photos *photos = [[exercise.photos allObjects] objectAtIndex:i];
        if(![[photos.photoLink lastPathComponent] isEqualToString:@"no-photo.png"])
            [array addObject:photos];
    }
    NSArray *sortedArray = [self sortArray:array];
    [array removeAllObjects];
    for (int i = 0;  i < [sortedArray count]; i++) {
        NSString *path;
        NSArray *comps = [[[sortedArray objectAtIndex:i] photoLink] pathComponents];
        if ([comps containsObject:@"Library"]) {
            NSLog(@"1 - %@", [comps objectAtIndex:5]);
            path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            //                path = [path stringByDeletingLastPathComponent];
            //                path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-3]];
            path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-2]];
            path = [path stringByAppendingPathComponent:[comps objectAtIndex:[comps count]-1]];
        }
        [array addObject:path];
    }
    return array;
}


-(NSArray*) getrepsArray{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < [[exercise.reps allObjects] count]; i++) {
        Repetitions *reps = [[exercise.reps allObjects] objectAtIndex:i];
        [array addObject:reps];
    }
    NSArray *sortedArray = [self sortArray:array];
    [array removeAllObjects];
    for (int i = 0; i < [sortedArray count]; i++) {
        [array addObject:[[sortedArray objectAtIndex:i] repetitions]];
    }
    return array;
}


-(NSArray *)sortArray: (NSArray *)array{
    NSArray *sortedArray = [array sortedArrayUsingComparator: ^(id obj1, id obj2) {
        if ([[obj1 sort] integerValue] > [[obj2 sort] integerValue]){
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([[obj1 sort] integerValue] < [[obj2 sort] integerValue]){
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return sortedArray;
}


#pragma mark - Table view data source


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}


- (CustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    CustomCell *cell = (CustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.row == 0) {
        [[cell textLabel] setText:@"exerciseNameKEY".localized];
        if (exerciseTitle != nil) {
            [[cell detailTextLabel] setText:exerciseTitle];
        }else{
            [[cell detailTextLabel] setText:nil];
        }
    }else if(indexPath.row == 1){
        [[cell textLabel] setText:@"descriptionKey".localized];
        if (descriptionString != nil){
            [[cell detailTextLabel] setText:descriptionString];
        }else{
            [[cell detailTextLabel] setText:nil];
        }
    }else if(indexPath.row == 2){
        [[cell textLabel] setText:@"timeKey".localized];
        if (repsString !=nil){
            [[cell detailTextLabel] setText:repsString];
        }else{
            [[cell detailTextLabel] setText:nil];
        }
    }
    
    [cell.detailTextLabel setBebasFontWithType:Regular size:20];
    [cell.textLabel setBebasFontWithType:Regular size:22];
    [cell.detailTextLabel setTextColor:RGBA(65, 62, 62, 1)];
    [cell.textLabel setTextColor:RGBA(65, 62, 62, 1)];
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Did select");
    //    self.editing = NO;
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"titleSegue" sender:nil];
    }else
        if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"descriptionSegue" sender:nil];
        }else
        {
            [self performSegueWithIdentifier:@"repetitionsSegue" sender:nil];
        }
}


#pragma mark - Navigation

-(IBAction)popBack :(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"titleSegue"]) {
        TitleViewController *controller = segue.destinationViewController;
        [controller setDelegate:self];
        controller.title = @"titleKey".localized;
        controller.titleString = exerciseTitle;
    }else if ( [segue.identifier isEqualToString:@"descriptionSegue"])
    {
        DescriptionViewController *controller = segue.destinationViewController;
        [controller setDelegate:self];
        controller.title = @"Description";
        controller.descrString = descriptionString;
    }else if ([segue.identifier isEqualToString:@"repetitionsSegue"]){
        RepetitionsViewContoller *controller = segue.destinationViewController;
        [controller setDelegate:self];
        controller.circles = self.circles;
        NSLog(@"*********  %@", repsArray);
        controller.repsArray = [NSMutableArray arrayWithArray:repsArray];
        controller.title = @"repsKey".localized;
    }
}


#pragma mark - ImagePicker


-(IBAction)openImagePickerController:(id)sender{
    //     self.editing = NO;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
        //        [imagePickerController setDelegate:self];
        [imagePickerController setShowsCameraControls:YES];
        [imagePickerController.navigationBar setBebasFont];
        [self presentViewController:imagePickerController animated:YES completion:nil];// presentModalViewController:imagePickerController animated:YES];
    }else{
        TTAlertView *alert1 = [[TTAlertView alloc]initWithTitle:@"noCameraSupportKey".localized message:@"cameraFeatureKey".localized delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [self styleCustomAlertView:alert1];
        [self addButtonsWithBackgroundImagesToAlertView:alert1];
        [alert1 show];
    }
}


-(IBAction)LibraryPicture:(id)sender{
    //    self.editing = NO;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *picker= [[UIImagePickerController alloc]init];
        [picker.navigationBar setBebasFont];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
        //		[self presentModalViewController:picker animated:YES];
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];//dismissModalViewControllerAnimated:YES];
}


- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withSourceImage:(UIImage *)sourceImages{
    UIImage *sourceImage = sourceImages;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        
        
        //pop the context to get back to the default
        UIGraphicsEndImageContext();
    return newImage;
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        pickedImage = [self imageByScalingAndCroppingForSize:CGSizeMake(450, 450) withSourceImage:pickedImage];
    }else{
        pickedImage = [self imageByScalingAndCroppingForSize:CGSizeMake(350, 450) withSourceImage:pickedImage];
    }
    NSData *imageData = UIImagePNGRepresentation(pickedImage);
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"myPick%@.png",pickedImage]];
    NSError *error = nil;
    [imageData writeToFile:path options:NSDataWritingAtomic error:&error];
    [photoArray addObject:path];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
        [picker dismissViewControllerAnimated:YES completion:nil];//dismissModalViewControllerAnimated:YES];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];//dismissModalViewControllerAnimated:YES];
    [self addScrollViewContent:photoArray withScrollView:_imageScrollView];
}


-(void)addScrollViewContent:(NSMutableArray *)contentArray withScrollView:(UIScrollView *)scrollView{
    NSArray *viewsToRemove = [scrollView subviews];
    for (UIView *v in viewsToRemove) {
        if ([v isKindOfClass:[UIImageView class]]){
            [v removeFromSuperview];
        }else if ([v isKindOfClass:[UIButton class]]){
            [v removeFromSuperview];
        }
    }
    
    for (int i = 0; i<[contentArray count]; i++) {
        CGRect superframe;
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[contentArray objectAtIndex:i]];
        NSLog(@"image path: %d", (int)fileExists );
        UIImage *imgs = [UIImage imageWithContentsOfFile:[contentArray objectAtIndex:i]];
        
              int photoWidth = isIpad ? 200 : 130;
        imgs = [self imageByScalingAndCroppingForSize:CGSizeMake(photoWidth * 2, scrollView.frame.size.height * 2) withSourceImage:imgs];
        
        UIImageView *contentImageView = [[UIImageView alloc]initWithImage:imgs];
        
        
  
        
        
        
        superframe.origin.x = (photoWidth+10) * i;
        superframe.origin.y = 3;
        
        superframe.size = CGSizeMake(photoWidth, scrollView.frame.size.height);
        [contentImageView setFrame:superframe];
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setImage:[UIImage imageNamed:@"closeBtn@2x.png"] forState:UIControlStateNormal];
        [deleteBtn setImage:[UIImage imageNamed:@"pressed_closeBtn@2x.png"] forState:UIControlStateHighlighted];
        [deleteBtn addTarget:self
                      action:@selector(deleteImage:)
            forControlEvents:UIControlEventTouchDown];
        deleteBtn.tag = i;
        [deleteBtn setFrame:CGRectMake(-10, -10, 20, 20)];
        [deleteBtn setFrame:CGRectMake(superframe.origin.x+2, superframe.origin.y+2, deleteBtn.frame.size.width, deleteBtn.frame.size.height)];
        [scrollView addSubview:contentImageView];
        [scrollView addSubview:deleteBtn];
        
        scrollView.contentSize = CGSizeMake((superframe.size.width +10) *[contentArray count], contentImageView.frame.size.height);
    }
}


-(void)deleteImage:(UIButton*)sender{
    if ([photoArray count]!=0) {
        _imageScrollView.contentSize = CGSizeMake(0, 0);
        NSMutableArray *arr = [NSMutableArray array];
        for (int i =0; i<[photoArray count]; i++) {
            if ((UIImage*)[UIImage imageWithContentsOfFile:[photoArray objectAtIndex:i]]!=nil) {
                [arr addObject:[photoArray objectAtIndex:i]];
            }
        }
        if([photoArray count] > sender.tag)
            [photoArray removeObjectAtIndex:sender.tag];
        [arr removeObjectAtIndex:sender.tag];
        [self addScrollViewContent:arr withScrollView:_imageScrollView];
        [sender removeFromSuperview];
    }
}


#pragma mark - TitleViewControllerDelegate


-(void)goBack:(NSString*)title{
    exerciseTitle = title;
}


#pragma mark - DescriptionVuewControllerDelegate


-(void)returnDescription:(NSString *)description{
    descriptionString = description;
}


#pragma mark - RepetiotionsViewControllerDelegate


-(void) returnRepetitions:(NSArray *)circlesArray{
    repsArray = circlesArray;
    repsString = [NSString stringWithFormat:@"%d %@ ", self.circles, @"circleWithKey".localized];
    for (int i = 0; i < [circlesArray count]-1; i++) {
        repsString = [repsString stringByAppendingString:[NSString stringWithFormat:@"%d/",[[circlesArray objectAtIndex:i] intValue]*2]];
    }
    repsString = [repsString stringByAppendingString:[NSString stringWithFormat:@"%d %@", [[circlesArray lastObject] intValue]*2, @"secondsKey".localized]];
}


#pragma mark - TTAlertView


- (void)styleCustomAlertView:(TTAlertView *)alertView
{
    [alertView.containerView setImage:[[UIImage imageNamed:@"alert.bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(11.0f, 13.0f, 14.0f, 13.0f)]];
    [alertView.containerView setBackgroundColor:[UIColor clearColor]];
    [alertView.titleLabel setTextColor:[UIColor colorWithRed:255.0f/255.0f green:37.0f/255.0f blue:58.0f/255.0f alpha:1.0f]];
    [alertView.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [alertView.messageLabel setTextColor:[UIColor colorWithRed:255.0f/255.0f green:37.0f/255.0f blue:58.0f/255.0f alpha:1.0f]];
    alertView.buttonInsets = UIEdgeInsetsMake(alertView.buttonInsets.top, alertView.buttonInsets.left + 4.0f, alertView.buttonInsets.bottom + 6.0f, alertView.buttonInsets.right + 4.0f);
}


- (void)addButtonsWithBackgroundImagesToAlertView:(TTAlertView *)alertView{
    UIImage *redButtonImageOff = [UIImage imageNamed:@"actionSheet_cancel@2x.png"];
    UIImage *redButtonImageOn = [UIImage imageNamed:@"actionSheet_frame@2x.png"];
    
    UIImage *greenButtonImageOff = [[UIImage imageNamed:@"actionSheet_frame@2x.png"] stretchableImageWithLeftCapWidth:2.0 topCapHeight:2.0];
    UIImage *greenButtonImageOn = [[UIImage imageNamed:@"actionSheet_cancel@2x.png"] stretchableImageWithLeftCapWidth:2.0 topCapHeight:2.0];
    
    for(int i = 0; i < [alertView numberOfButtons]; i++) {
        if (i == 0) {
            if (i+1 == [alertView numberOfButtons]) {
                [alertView setButtonBackgroundImage:redButtonImageOff  forState:UIControlStateNormal withSize:CGSizeMake(192, 26) atIndex:i ];
                [alertView setButtonBackgroundImage:redButtonImageOn forState:UIControlStateHighlighted withSize:CGSizeMake(192, 26) atIndex:i];
            }else{
                [alertView setButtonBackgroundImage:redButtonImageOff  forState:UIControlStateNormal withSize:CGSizeMake(120, 22) atIndex:i ];
                [alertView setButtonBackgroundImage:redButtonImageOn forState:UIControlStateHighlighted withSize:CGSizeMake(120, 22) atIndex:i];
            }
        } else {
            [alertView setButtonBackgroundImage:greenButtonImageOff forState:UIControlStateNormal withSize:CGSizeMake(120, 22) atIndex:i];
            [alertView setButtonBackgroundImage:greenButtonImageOn forState:UIControlStateHighlighted withSize:CGSizeMake(120, 22 ) atIndex:i];
        }
    }
}

- (IBAction)backButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)backButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}

@end
