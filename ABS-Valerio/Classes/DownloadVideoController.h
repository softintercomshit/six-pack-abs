#import <UIKit/UIKit.h>

@protocol DownloadVideosDelegate <NSObject>

@optional
-(void)didFinishDownloadingWithPath:(NSString *)path;

@end

@interface DownloadVideoController : UIViewController

-(instancetype) init NS_UNAVAILABLE;
+(instancetype) new NS_UNAVAILABLE;

-(instancetype)initWithArrayOfVideoNames:(NSArray<NSString*> *)array containerController:(UIViewController *)containerController;
-(instancetype)initWithVideoName:(NSString *)videoName containerController:(UIViewController *)containerController;
-(instancetype)initWithAllVideosAndContainerController:(UIViewController *)containerController;

-(void)startDownload;

@property(weak, nonatomic) id<DownloadVideosDelegate>delegate;

@end
