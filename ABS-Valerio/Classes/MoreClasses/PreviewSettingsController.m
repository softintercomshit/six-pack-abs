#import "PreviewSettingsController.h"
#import "PreviewSettingsCell.h"

static NSString *const cellWithIdentifier = @"PreviewSettingsCell";

@interface PreviewSettingsController ()

@end

@implementation PreviewSettingsController{
    PreviewType previewType;
    NSInteger selectedRow;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        previewType = [defaults integerForKey:kExercisePreviewKey];
        switch (previewType) {
            case FullPreview:
                selectedRow = 0;
                break;
            case ShortPreview:
                selectedRow = 1;
                break;
            case NoPreview:
                selectedRow = 2;
            default:
                break;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:cellWithIdentifier bundle:nil] forCellReuseIdentifier:cellWithIdentifier];
    [self.tableView setTableFooterView:[UIView new]];
    [self setTitle:@"settingsPreviewOptions".localized];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PreviewSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellWithIdentifier forIndexPath:indexPath];
    [cell setIndexPath:indexPath];
    if (indexPath.row == selectedRow) {
        [tableView selectRowAtIndexPath:indexPath animated:false scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch (indexPath.row) {
        case 0:
            previewType = FullPreview;
            break;
        case 1:
            previewType = ShortPreview;
            break;
        case 2:
            previewType = NoPreview;
            break;
        default:
            break;
    }
    [defaults setInteger:previewType forKey:kExercisePreviewKey];
    [defaults synchronize];
    
    if (selectedRow != indexPath.row) {
        PreviewSettingsCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell didSelect];
    }
    selectedRow = indexPath.row;
}
@end
