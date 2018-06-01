#import "ImagesGuideInterfaceController.h"
#import "Utils.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"


@interface ImagesGuideInterfaceController ()
@property (weak, nonatomic) IBOutlet WKInterfaceImage *exerciseGuideImageView;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *exerciseNameLabel;

@end
NSString* exTypeName;
NSArray<NSString *>* imagesNameArray;
NSString* mainAppBundle;
NSString* exerciseName;
@implementation ImagesGuideInterfaceController{
    NSInteger currentImageIndex;
    NSTimer *animationTimer;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self setValuesOnAwake:context];
}

-(void)setValuesOnAwake:(id)context{
    exerciseName=context[@"exerciseName"];
    [self setTitle:@"backKey".localized];
    exTypeName=context[@"typeName"];
    imagesNameArray=context[@"exerciseInfo"];
    [self setExerciseImage:imagesNameArray];
    
//    NSString* imagesPath=[NSString stringWithFormat:@"/Default/%@/%@",exTypeName,exerciseName];
//    [[Utils sharedInstance]getImagesFromMainAPP:imagesPath withBlock:^(id result) {
//        [self setExerciseImage:result];
//    }];
}

- (void)willActivate {
    [super willActivate];
    [self.exerciseNameLabel setText:exerciseName.localized];
    
    if (!animationTimer.isValid && imagesNameArray.count != 0) {
        [self setExerciseImage:imagesNameArray];
    }
}

- (void)didDeactivate {
    [super didDeactivate];
    [animationTimer invalidate];
}

-(void)setExerciseImage:(NSArray<NSString *> *)imagesName{
    NSMutableArray* arrayWithImages=[NSMutableArray new];
    for (NSString *imageName in imagesName) {
        UIImage *image= [UIImage imageNamed:[imageName stringByAppendingString:@"@2x.jpg"]];
        if(image)
            [arrayWithImages addObject:image];
    }

    [self.exerciseGuideImageView setImage:arrayWithImages[0]];
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animateImages:) userInfo:arrayWithImages repeats:true];
}

-(void)animateImages:(NSTimer *)timer{
    NSArray<UIImage *> *arrayWithImages = timer.userInfo;
    
    currentImageIndex++;
    if (currentImageIndex == arrayWithImages.count) {
        currentImageIndex = 0;
    }
    
    [self.exerciseGuideImageView setImage:arrayWithImages[currentImageIndex]];
}

/* pocemuto images animations dosen't work
-(void)setExerciseImage:(NSArray<NSString *> *)imagesName{
    NSMutableArray* arrayWithImages=[NSMutableArray new];
    for (NSString *imageName in imagesName) {
        UIImage *image= [UIImage imageNamed:[imageName stringByAppendingString:@"@2x.jpg"]];
        if(image)
            [arrayWithImages addObject:image];
    }
    UIImage* animatedImage=[UIImage animatedImageWithImages:arrayWithImages duration:0];
    [self.exerciseGuideImageView setImage:animatedImage];
    long numberOfImages=[arrayWithImages count];
    [self.exerciseGuideImageView startAnimatingWithImagesInRange:NSMakeRange(0, numberOfImages) duration:numberOfImages repeatCount:-1];
}*/

//-(void)setExerciseImage:(NSDictionary*)dictImagesInfo{
//    NSMutableArray* arrayWithImages=[NSMutableArray new];
//    for(int i = 0; i < [imagesName count]; i++){
//        UIImage *image= [UIImage imageWithData:dictImagesInfo[imagesName[i]]];
//        if(image)
//            [arrayWithImages addObject:image];
//    }
//    UIImage* animatedImage=[UIImage animatedImageWithImages:arrayWithImages duration:0];
//    [self.exerciseGuideImageView setImage:animatedImage];
//    long numberOfImages=[arrayWithImages count];
//    [self.exerciseGuideImageView startAnimatingWithImagesInRange:NSMakeRange(0, numberOfImages) duration:numberOfImages repeatCount:-1];
//   // [self.exerciseGuideImageView startAnimating];
//}

@end



