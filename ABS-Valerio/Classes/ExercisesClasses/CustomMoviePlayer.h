#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@protocol CustomMoviePlayerDelegate <NSObject>

-(void)playerRemoved;

@end

@interface CustomMoviePlayer : MPMoviePlayerViewController

@property (nonatomic , weak) id <CustomMoviePlayerDelegate> delegate;
@property (nonatomic, strong) NSString* videoPath;
@property (nonatomic) CGSize screenSize;

@end
