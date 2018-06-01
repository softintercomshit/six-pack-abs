#import "ExercisesProgressContainerViewController.h"
#import "PlayerExerciseCollectionViewCell.h"


@interface ExercisesProgressContainerViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIProgressView *completWorkoutProgressView;
@property (weak, nonatomic) IBOutlet UIProgressView *currentExerciseProgressView;

@property (weak, nonatomic) IBOutlet UIImageView *nextExerciseImageView;
@property (weak, nonatomic) IBOutlet UILabel *nextExerciseLabel;
@property (weak, nonatomic) IBOutlet UIView *exerciseInformationComponentsView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftDistancePorgressConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightDistanceProgressConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topDistanceProgressConstraint;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *currentExerciseNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *separatorView;

@end

@implementation ExercisesProgressContainerViewController{
    __weak IBOutlet NSLayoutConstraint *progressBar2Height;
    __weak IBOutlet NSLayoutConstraint *progressBar1Height;
    __weak IBOutlet NSLayoutConstraint *progressBarViewHeight;
    int _newIndex, _currentRound;
}

int totalExercises;
int currentExerciseCount;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentExerciseCount = 0;
    // Do any additional setup after loading the view.
    [_currentExercisesCollectionView registerNib:[UINib nibWithNibName:@"PlayerExerciseCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"PlayerExerciseCollectionViewCell"];
    totalExercises = ((int)_exercisesArray.count - 1) * _numberOfCirles;
    [self updateCompletWorkoutProgressView];
    
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 4.0f);
    _completWorkoutProgressView.transform = _currentExerciseProgressView.transform = transform;
    _collectionViewWidthConstraint.constant = self.view.frame.size.width;
    
//    [_currentExerciseNameLabel setBebasFontWithType:Regular size:isIpad? 21 : 18];
//    [_nextExerciseLabel setBebasFontWithType:Regular size:isIpad? 21 : 18];

    [_currentExerciseNameLabel setBebasFontWithType:Regular size:isIpad? 17 : 14];
    [_nextExerciseLabel setBebasFontWithType:Regular size:isIpad? 17 : 14];
}


-(void)setExerciseImage:(int)index{
    UIImage *image;
    if (index == 0) {
        image = [UIImage imageWithContentsOfFile:_exercisesArray[index+1][@"imagePath"]];
    }else{
        image = [UIImage imageWithContentsOfFile:_exercisesArray[index][@"imagePath"]];
    }
    _nextExerciseImageView.image = [self replaceColor:[UIColor whiteColor] inImage:image withTolerance:100];
}

- (UIImage*)replaceColor:(UIColor*)color inImage:(UIImage*)image withTolerance:(float)tolerance {
    CGImageRef imageRef = [image CGImage];
    
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bitmapByteCount = bytesPerRow * height;
    
    unsigned char *rawData = (unsigned char*) calloc(bitmapByteCount, sizeof(unsigned char));
    
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    CGColorRef cgColor = [color CGColor];
    const CGFloat *components = CGColorGetComponents(cgColor);
    float r = components[0];
    float g = components[1];
    float b = components[2];
    //float a = components[3]; // not needed
    
    r = r * 255.0;
    g = g * 255.0;
    b = b * 255.0;
    
    const float redRange[2] = {
        MAX(r - (tolerance / 2.0), 0.0),
        MIN(r + (tolerance / 2.0), 255.0)
    };
    
    const float greenRange[2] = {
        MAX(g - (tolerance / 2.0), 0.0),
        MIN(g + (tolerance / 2.0), 255.0)
    };
    
    const float blueRange[2] = {
        MAX(b - (tolerance / 2.0), 0.0),
        MIN(b + (tolerance / 2.0), 255.0)
    };
    
    int byteIndex = 0;
    
    while (byteIndex < bitmapByteCount) {
        unsigned char red   = rawData[byteIndex];
        unsigned char green = rawData[byteIndex + 1];
        unsigned char blue  = rawData[byteIndex + 2];
        
        if (((red >= redRange[0]) && (red <= redRange[1])) &&
            ((green >= greenRange[0]) && (green <= greenRange[1])) &&
            ((blue >= blueRange[0]) && (blue <= blueRange[1]))) {
            // make the pixel transparent
            //
            rawData[byteIndex] = 0;
            rawData[byteIndex + 1] = 0;
            rawData[byteIndex + 2] = 0;
            rawData[byteIndex + 3] = 0;
        }
        
        byteIndex += 4;
    }
    
    CGImageRef imgref = CGBitmapContextCreateImage(context);
    UIImage *result = [UIImage imageWithCGImage:imgref];
    
    CGImageRelease(imgref);
    CGContextRelease(context);
    free(rawData);
    
    return result;
}

#pragma mark - Progress Views

-(void)updateCurrentExerciseProgressView:(float)currentTime withTotalExerciseTime:(float)exerciseTime{
    float currentExerciseProgress = (float)(currentExerciseCount)/(totalExercises/1.0);
    float progressPass = (float)1.0/totalExercises;
    _currentExerciseProgressView.progress = currentExerciseProgress + (currentTime/exerciseTime * progressPass);
}


-(void)updateCompletWorkoutProgressView{
    _completWorkoutProgressView.progress = (float)(currentExerciseCount + 1)/(totalExercises/1.0);
    _currentExerciseProgressView.progress = (float)(currentExerciseCount)/(totalExercises/1.0);
}


#pragma mark - CollectionView DataSource


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _exercisesArray.count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PlayerExerciseCollectionViewCell* exerciseCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlayerExerciseCollectionViewCell" forIndexPath:indexPath];
    [self setExerciseImage:(int)indexPath.row];
//    [self hideElementsIfLast: indexPath.row == _exercisesArray.count - 2];
    
    if (_isLastExercise) {
        [exerciseCell setExercisesInfo:_exercisesArray[indexPath.row][@"exerciseName"] andNextExercise:_isLastCircle ? @"workout done".localized : @"rest30secKey".localized];
        if (_isLastCircle) {
            [_nextExerciseLabel setText:@"next".localized];
            [_separatorView layoutIfNeeded];
        }else
            [_nextExerciseLabel setText: @"up next".localized];
        [_nextExerciseImageView setHidden:true];
        [exerciseCell setLabelOnCenter:true];
    }else{
        [exerciseCell setLabelOnCenter:false];
        NSInteger nextExerciseIndex = indexPath.row + 1;
        if (nextExerciseIndex >= _exercisesArray.count-1) {
            nextExerciseIndex = _exercisesArray.count-1;
        }
        [exerciseCell setExercisesInfo:_exercisesArray[indexPath.row][@"exerciseName"] andNextExercise:_exercisesArray[nextExerciseIndex][@"exerciseName"]];
        if (_isLastCircle) {
            if (indexPath.row == totalExercises/2-2 || indexPath.row == totalExercises/2-1) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_nextExerciseLabel setText:@"last exercise".localized];
                });
            }else
                [_nextExerciseLabel setText:@"nextExerciseKey".localized];
        }else{
            [_nextExerciseLabel setText:@"nextExerciseKey".localized];
        }
        [_nextExerciseImageView setHidden:false];
    }
    
    return exerciseCell;
}


-(void)hideElementsIfLast:(BOOL)hideValue{
    _nextExerciseLabel.hidden = hideValue;
    _nextExerciseImageView.hidden = hideValue;
}


//#pragma mark - IBActions
//
//
//- (IBAction)nextButtonAction:(id)sender {
//    if(_delegate && [_delegate respondsToSelector:@selector(nextCollectionExercise)]){
//        [_delegate nextCollectionExercise];
//    }
//    [self scrollCollectionView: 1];
//}
//

#pragma mark - Scroll Collection View

-(void)scrollCollectionView:(int)newIndex withRound:(int)currentRound animated:(BOOL)animated {
    _newIndex = newIndex;
    _currentRound = currentRound;
    
    currentExerciseCount = newIndex + (((int)_exercisesArray.count -1) * currentRound);
    NSLog(@"%d %d %d", currentExerciseCount, newIndex , currentRound);
    [self updateCompletWorkoutProgressView];
//    NSIndexPath *newIndexPath = [_currentExercisesCollectionView indexPathForItemAtPoint:CGPointMake(newIndex * _currentExercisesCollectionView.frame.size.width, 0)];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
    [_currentExercisesCollectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
}


#pragma mark - Collection FlowLayout Delegate


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    NSArray<NSNumber *> *screenSizes = @[@(CGRectGetWidth(screenBounds)), @(CGRectGetHeight(screenBounds))];
    NSNumber *minNumber = [screenSizes valueForKeyPath:@"@min.self"];
    return CGSizeMake(minNumber.floatValue, collectionView.frame.size.height);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}


#pragma mark -  Orientation change handlers

-(void)hideViewsOnOrientationChange:(BOOL)portraitOrientation withConstraint:(float)constraintConstant {
    
    [[UIApplication sharedApplication] setStatusBarHidden:!portraitOrientation];
    _exerciseInformationComponentsView.hidden = !portraitOrientation;
    
    _leftDistancePorgressConstraint.constant = portraitOrientation ? 0 : constraintConstant;
    _rightDistanceProgressConstraint.constant = portraitOrientation ? 0 : 0;
    _topDistanceProgressConstraint.constant = portraitOrientation ? 5 : 0;
    
    [self scrollCollectionView:_newIndex withRound:_currentRound animated:false];
}


@end
