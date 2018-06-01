#import "UnZipper.h"

@implementation UnZipper
@synthesize delegate;

static UnZipper *instance_;

static void singleton_remover() {

}

+ (UnZipper*)instance {
    @synchronized(self) {
        if( instance_ == nil ) {
            [[self alloc] init];
        }
    }
    
    return instance_;
}

- (id)init {
    self = [super init];
    instance_ = self;
    
    atexit(singleton_remover);
    
    return self;
}

-(void)startUnZipingWithFilePath:(NSString *)zipFilePath
{
    if ([NSThread currentThread].isMainThread)
    {
        [self performSelectorInBackground:@selector(startUnZipingWithFilePath:) withObject:zipFilePath];
        return;
    }
    ZipArchive *zip = [[ZipArchive alloc] init];
    
    ZipArchiveProgressUpdateBlock progressBlock = ^ (int percentage, int filesProcessed, int numFiles) {
//        NSLog(@"total %d, filesProcessed %d of %d", percentage, filesProcessed, numFiles);
       
         [delegate setUnZipProgressInPercents:percentage andNumOfFiles:filesProcessed andFilePath:zipFilePath];
    };
    
    zip.progressBlock = progressBlock;
    
    //open file
    [zip UnzipOpenFile:zipFilePath];
    
    //unzip file to
    
    [zip UnzipFileTo:[zipFilePath stringByDeletingLastPathComponent] overWrite:YES];
//    NSLog(@"Unzipping");

}
-(void)startUnZipingWithFilePath:(NSString *)zipFilePath toPath:(NSString *)destpath
{
    if ([NSThread currentThread].isMainThread)
    {
        [self performSelectorInBackground:@selector(startUnZipingWithFilePath:) withObject:zipFilePath];
        return;
    }
    ZipArchive *zip = [[ZipArchive alloc] init];
    
    ZipArchiveProgressUpdateBlock progressBlock = ^ (int percentage, int filesProcessed, int numFiles) {
        NSLog(@"total %d, filesProcessed %d of %d", percentage, filesProcessed, numFiles);
        
        [delegate setUnZipProgressInPercents:percentage andNumOfFiles:filesProcessed andFilePath:zipFilePath];
    };
    
    zip.progressBlock = progressBlock;
    
    //open file
    [zip UnzipOpenFile:zipFilePath];
    
    //unzip file to
    
    [zip UnzipFileTo:[destpath stringByAppendingPathComponent:@"path"] overWrite:YES];
    NSLog(@"Unzipping to file: %@", destpath);
    
}

@end
