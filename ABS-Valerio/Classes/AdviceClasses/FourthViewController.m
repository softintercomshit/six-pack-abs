#import "FourthViewController.h"
//#import "CustomCell.h"
#import "AdviceTableViewCell.h"


#define ADVICE_PLIST @"AdviceInfo"
#define FACTS_PLIST @"FactsInfo"

@interface FourthViewController() <UITableViewDelegate, UITableViewDataSource>

@end


@implementation FourthViewController

NSArray *fetchArray;
NSArray *factsArray;


#pragma mark - View Controller Life cycle

- (void)viewDidLoad{
    [super viewDidLoad];
    fetchArray = [self gestArrayFromPlist:ADVICE_PLIST withKey:@"AdviceValues"];
    factsArray =  [self gestArrayFromPlist:FACTS_PLIST withKey:@"FactsValues"];
    [self registerTableViewCells];
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedRowHeight = 140;
    self.title = @"adviceItemKey".localized;
    [self.navigationController.navigationBar setBebasFont];
}


#pragma mark - Initialize


-(void)registerTableViewCells{
    [_tableView registerNib:[UINib nibWithNibName:@"ExpandableAdviceTableViewCell" bundle:nil] forCellReuseIdentifier:@"ExpandableAdviceTableViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"MainAdviceTableViewCell" bundle:nil] forCellReuseIdentifier:@"MainAdviceTableViewCell"];
}


-(NSArray*)gestArrayFromPlist:(NSString*)fileName withKey:(NSString*)key{
    NSDictionary * values=[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"]];
    return [[NSArray alloc] initWithArray:[values valueForKey:key]];
}

#pragma mark  - UitableView DataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = section == 0 ? [fetchArray count] : [factsArray count];
    return count;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return section == 0 ? @"" : [@" " stringByAppendingString:@"surprisingKey".localized];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [tableView headerViewForSection:section];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont fontWithName:@"BebasNeueBold" size:20]];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BOOL isExpanded = indexPath.row == _selectedIndexPath.row && indexPath.section == _selectedIndexPath.section && _selectedIndexPath != nil;
    NSString* cellIdentifier =  isExpanded ? @"ExpandableAdviceTableViewCell" : @"MainAdviceTableViewCell";
    NSLog(@"%d", indexPath.row == _selectedIndexPath.row && indexPath.section == _selectedIndexPath.section);
    AdviceTableViewCell* adviceCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if(indexPath.section == 0 ){
        NSString *title = fetchArray[indexPath.row][@"title"];
        NSString *description = [title stringByAppendingString:@" description"]; //fetchArray[indexPath.row][@"description"]
        [adviceCell setAdviceValues:@{@"imagePrefixName":fetchArray[indexPath.row][@"imageName"], @"title": title.localized, @"description": description.localized} isExpandable:isExpanded];
        
        adviceCell.blogUrl = fetchArray[indexPath.row][@"url"];
    }else{
        NSString *title = factsArray[indexPath.row][@"title"];
        NSString *description = [title stringByAppendingString:@" description"]; //factsArray[indexPath.row][@"description"]
        [adviceCell setAdviceValues:@{@"imagePrefixName":[NSString stringWithFormat:@"f%d",(int)indexPath.row + 1], @"title":title.localized, @"description": description.localized} isExpandable:isExpanded];
    }
    adviceCell.openBlogButton.hidden = indexPath.section == 1;
    
    return adviceCell;
}

#pragma mark  - UitableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
        if ( self.selectedIndexPath != nil && [self.selectedIndexPath compare: indexPath] == NSOrderedSame ){
            return  isIpad ? 418 : 310;
        }
        return isIpad ? 120 : 90;
    }else
        return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 0 : 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray* toReload = [NSArray arrayWithObjects: indexPath, self.selectedIndexPath, nil];
    
    if (indexPath.row == _selectedIndexPath.row && indexPath.section == _selectedIndexPath.section && _selectedIndexPath){
        self.selectedIndexPath = nil;
    }else
        self.selectedIndexPath = indexPath;
    
    CGSize contentSize = tableView.contentSize;
    contentSize.height += 1000;
    [tableView setContentSize:contentSize];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
        [tableView reloadData];
    }else
        [tableView reloadRowsAtIndexPaths:toReload withRowAnimation: UITableViewRowAnimationFade];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:true];
}
@end
