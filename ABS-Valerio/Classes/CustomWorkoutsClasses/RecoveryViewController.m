#import "RecoveryViewController.h"
#import "MSCellAccessory.h"


@interface RecoveryViewController ()

@end

@implementation RecoveryViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    [self setTitle:@"chooseRecoveryModeKey".localized];
    [self.navigationController.navigationBar setBebasFont];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(_delegate && [_delegate respondsToSelector:@selector(choseRecovery:)]){
        [_delegate choseRecovery:_selectedRow];
    }
}


#pragma mark - Table view data source




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = RECOVERY_TYPES[indexPath.row];
    cell.accessoryView= nil;
    if (indexPath.row == _selectedRow) {
        cell.titleLabel.textColor = [UIColor colorWithRed:69/255.0 green:199/255.0 blue:123/255.0 alpha:1.0];
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:[UIColor colorWithRed:69/255.0 green:199/255.0 blue:123/255.0 alpha:1.0] highlightedColor:[UIColor whiteColor]];
    }else{
        cell.titleLabel.textColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1.0];
    }
    return cell;
}


#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return isIpad ? 120 : 80;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedRow = (int)indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadData];
}


#pragma mark - IBActions


-(IBAction)moveBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonTouchDown:(UIButton *)sender{
    [sender setTintColor:RGBA(255, 255, 255, .4)];
}

- (IBAction)backButtonTouchCancel:(UIButton *)sender{
    [sender setTintColor:[UIColor whiteColor]];
}


@end
