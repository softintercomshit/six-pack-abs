#import "UIImage+LaunchImage.h"

@implementation UIImage (LaunchImage)

+(UIImage *)launchImage{
    NSArray *allPngImageNames = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:nil];

    for (NSString *imgName in allPngImageNames) {
        // Find launch images
        if ([imgName containsString:@"LaunchImage"]){
            UIImage *img = [UIImage imageNamed:imgName];
            // Has image same scale and dimensions as our current device's screen?
            if (img.scale == [UIScreen mainScreen].scale && CGSizeEqualToSize(img.size, [UIScreen mainScreen].bounds.size)) {
                return img;
            }
        }
    }

    return nil;
}

@end
