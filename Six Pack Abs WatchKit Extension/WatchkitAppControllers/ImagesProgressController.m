#import "ImagesProgressController.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "Utils.h"
#import "Six_Pack_Abs_WatchKit_Extension-Swift.h"


@interface ImagesProgressController()<WCSessionDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *progressGroup;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *percentsLabel;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;

@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView1;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView2;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView3;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView4;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView5;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView6;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView7;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView8;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView9;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView10;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView11;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView12;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView13;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView14;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView15;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView16;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView17;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView18;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView19;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *imageView20;

@end

@implementation ImagesProgressController{
    NSInteger numberOfImages, initialNumberOfImages;
    NSArray<WKInterfaceImage*> *imageViews;
    NSInteger timerTime;
    NSTimer *timer;
    NSString *downloadingContentText;
}

-(void)awakeWithContext:(id)context{
    [self openWatchConnection];
    downloadingContentText = @"Downloading images".localized;
//    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hreni:) userInfo:nil repeats:true];
    
    imageViews = @[_imageView1, _imageView2, _imageView3, _imageView4, _imageView5, _imageView6, _imageView7, _imageView8, _imageView9, _imageView10, _imageView11, _imageView12, _imageView13, _imageView14, _imageView15, _imageView16, _imageView17, _imageView18, _imageView19, _imageView20];
    
    UIImage *image = [self imageWithColor:[UIColor lightGrayColor]];
    for (WKInterfaceImage *imageView in imageViews) {
        [imageView setImage: image];
    }
    
    NSArray *imagesToCopy = context;
    numberOfImages = initialNumberOfImages = imagesToCopy.count;
    
    [_titleLabel setText:[NSString stringWithFormat:@"%@ 0/%d",downloadingContentText, numberOfImages]];
    
    [_progressGroup setWidth:0];
    
    
    [[WCSession defaultSession] sendMessage:@{@"getImages": @(true), @"imagesNameArray": imagesToCopy} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
    } errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

//-(void)hreni:(NSTimer*)localTimer{
//    timerTime++;
//    
//    switch (timerTime%5) {
//        case 1:
//            [_titleLabel setText:@"Downloading\nimages\n.."];
//            break;
//        case 2:
//            [_titleLabel setText:@"Downloading\nimages\n..."];
//            break;
//        case 3:
//            [_titleLabel setText:@"Downloading\nimages\n...."];
//            break;
//        case 4:
//            [_titleLabel setText:@"Downloading\nimages\n....."];
//            break;
//        case 0:
//            [_titleLabel setText:@"Downloading\nimages\n."];
//            break;
//        default:
//            break;
//    }
//}

-(void)openWatchConnection{
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = self;
        if (session.activationState != WCSessionActivationStateActivated) {
            [session activateSession];
        }
    }
}

-(void)session:(WCSession *)session didReceiveFile:(WCSessionFile *)file {
    NSString *fileType = file.metadata[@"fileType"];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileType isEqualToString:@"image"]) {
        [fileManager createDirectoryAtPath:[documentsPath stringByAppendingPathComponent:@"images"] withIntermediateDirectories:false attributes:nil error:nil];
        
        NSString *imageName = file.metadata[@"name"];
        NSData *imageData = [NSData dataWithContentsOfURL:file.fileURL];
        [imageData writeToFile:[documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"images/%@", imageName]] atomically:YES];
        
        numberOfImages--;
        NSInteger downloadedImages = initialNumberOfImages - numberOfImages;
        
//        CGRect watchScreenRect=[[WKInterfaceDevice currentDevice] screenBounds];
//        CGFloat screenWidth = watchScreenRect.size.width;
//        CGFloat currentProgress = downloadedImages * screenWidth / initialNumberOfImages;
//        [_progressGroup setWidth:currentProgress];
        
        [_titleLabel setText:[NSString stringWithFormat:@"%@ %d/%d",downloadingContentText, downloadedImages, initialNumberOfImages]];
        
        NSInteger downloadedPercents = downloadedImages*100/initialNumberOfImages;
        [_percentsLabel setText:[NSString stringWithFormat:@"%d %%", downloadedPercents]];
        NSInteger numberOfImagesToColor = 20*downloadedPercents/100;
        
        UIImage *image = [self imageWithColor:[UIColor colorWithRed:226/255.f green:46/255.f blue:47/255.f alpha:1]];
        [imageViews enumerateObjectsUsingBlock:^(WKInterfaceImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setImage: image];
            if (idx+1 == numberOfImagesToColor) {
                *stop = true;
            }
        }];
        
        if (numberOfImages <= 0) {
            [timer invalidate];
            [self dismissController];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"progressControllerDismissed" object:nil];
        }
        [fileManager removeItemAtURL:file.fileURL error:nil];
        NSLog(@"downloaded photo !!!!!!!!");
    }else{
        NSArray *array = [NSArray arrayWithContentsOfURL:file.fileURL];
        for (NSDictionary *dict in array) {
            NSString *fileName = dict[@"name"];
            NSData *sqlData = dict[@"data"];
            [sqlData writeToFile:[documentsPath stringByAppendingPathComponent:fileName] atomically:YES];
        }
        [fileManager removeItemAtURL:file.fileURL error:nil];
        NSLog(@"sql downloaded !!!!!!!!");
    }
}

-(UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
