#import <Foundation/Foundation.h>
#import "ZipArchive.h"

@protocol UnZipperDelegate <NSObject>

-(void)setUnZipProgressInPercents:(int)zipPercents andNumOfFiles:(int)numberOfFiles andFilePath:(NSString *)filePath;
-(void)didFinishedUnZipingFileWithValue:(BOOL)isUnZiped;

@end


@interface UnZipper : NSObject


@property(nonatomic, assign)id <UnZipperDelegate>delegate;

+(UnZipper*) instance;
-(void)startUnZipingWithFilePath:(NSString *)zipFilePath;
-(void)startUnZipingWithFilePath:(NSString *)zipFilePath toPath:(NSString *)destpath;

@end
