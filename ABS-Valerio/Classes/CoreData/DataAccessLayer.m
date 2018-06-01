#import "DataAccessLayer.h"

@interface DataAccessLayer ()

- (NSURL *)applicationDocumentsDirectory;

@end

@implementation DataAccessLayer

@synthesize storeCoordinator;
@synthesize managedObjectModel;
@synthesize managedObjectContext;

+ (DataAccessLayer *)sharedInstance {
    __strong static DataAccessLayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DataAccessLayer alloc] init];
        sharedInstance.storeCoordinator = [sharedInstance persistentStoreCoordinator];
        sharedInstance.managedObjectContext = [sharedInstance managedObjectContext];
    });
    return sharedInstance;
}

#pragma mark - Core Data

- (void)saveContext {
    @synchronized(self) {
        NSError *error = nil;
        if (managedObjectContext != nil){
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]){
                NSLog(@"DataAccessLayer saveContext error : %@, %@", error, [error userInfo]);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"oopsKey".localized message:@"Something has gone terribly wrong! You need to reinstall the app in order for it to work properly.".localized delegate:nil cancelButtonTitle:@"Close.".localized otherButtonTitles:nil, nil];
                [alert show];
            }
        }
    }
}

#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willSaveContext:)
                                                 name:NSManagedObjectContextWillSaveNotification
                                               object:nil];
    if (managedObjectContext != nil){
        return managedObjectContext;
    }
    
    if (storeCoordinator != nil){
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:storeCoordinator];
    }
    
    return managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (managedObjectModel != nil){
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ABS-VAlerio-DB" withExtension:@"momd"];
    self.managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (storeCoordinator != nil){
        return storeCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ABS-Valerio-DB.sqlite"];
    NSLog(@"%@", [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ABS-Valerio-DB.sqlite"]);
    
    NSError *error = nil;
    self.storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]){
        NSLog(@"DataAccesLayer persistentStoreCoordinator error : %@, %@", error, [error userInfo]);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"oopsKey".localized message:@"Something has gone terribly wrong! You need to reinstall the app in order for it to work properly.".localized delegate:nil cancelButtonTitle:@"Close.".localized otherButtonTitles:nil, nil];
        [alert show];
    }
    
    return storeCoordinator;
}

- (void)willSaveContext:(NSNotification *)notification{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:timeStamp forKey:kLastCoreDataChangeKey];
    [defaults synchronize];
}

#pragma mark Application's Documents directory


- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
