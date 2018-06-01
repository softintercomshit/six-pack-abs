#import <CoreData/CoreData.h>

@interface DataAccessLayer : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *storeCoordinator;

+ (DataAccessLayer *)sharedInstance;
- (void)saveContext;

@end
