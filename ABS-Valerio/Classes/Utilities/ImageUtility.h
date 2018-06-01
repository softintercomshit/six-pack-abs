#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageUtility : NSObject

+ (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize;
+ (UIImage *)imageWithColor:(UIColor *)color ;
@end
