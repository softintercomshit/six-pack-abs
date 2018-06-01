#import "PreviewSettingsCell.h"

@implementation PreviewSettingsCell{
    __weak IBOutlet UILabel *cellTitleLabel;
    __weak IBOutlet UIImageView *checkBoxImage;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    UIImage *newImage = [UIImage imageNamed:@"ic_check"];
    newImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [checkBoxImage setImage:newImage];
    [checkBoxImage setImage:selected ? newImage : [UIImage imageNamed:@"ic_uncek"]];
    [checkBoxImage setTintColor:RED_COLOR];
//    [checkBoxImage setImage:[UIImage imageNamed:selected ? @"ic_check" : @"ic_uncek"]];
}

-(void)setIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [self setTitleLabel:@"settingsPreviewFullKey".localized];
            break;
        case 1:
            [self setTitleLabel:@"settingsPreviewShortKey".localized];
            break;
        case 2:
            [self setTitleLabel:@"settingsPreviewNoneKey".localized];
            break;
        default:
            break;
    }
}

-(void)setTitleLabel:(NSString *)text{
    [cellTitleLabel setText:text];
    [cellTitleLabel setBebasFontWithType:Regular size:18];
}

-(void)didSelect{
    [UIView transitionWithView:checkBoxImage
                      duration:0.4
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [checkBoxImage setImage:checkBoxImage.image];
                    } completion:nil];
}
@end
