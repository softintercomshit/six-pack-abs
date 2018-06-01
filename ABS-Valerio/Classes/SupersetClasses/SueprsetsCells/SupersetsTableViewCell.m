 #import "SupersetsTableViewCell.h"

@interface SupersetsTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *supersetNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *supersetDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *separatorImageView;

@end

@implementation SupersetsTableViewCell


-(void)awakeFromNib{
    [super awakeFromNib];
//    [_supersetNameLabel setBebasFontWithType:Bold size:isIpad? 31 : 24];
//    [_supersetDescriptionLabel setBebasFontWithType:Regular size:isIpad? 17 : 14];
    [_supersetNameLabel setBebasFontWithType:Bold size:isIpad? 35 : 28];
    [_supersetDescriptionLabel setBebasFontWithType:Regular size:isIpad? 21 : 18];
//    if(isIpad){
//        _supersetNameLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:30];
//        _supersetDescriptionLabel.font = [UIFont fontWithName:@"Roboto-Medium" size:17];
//    }
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if(highlighted){
      //  _separatorImageView.image = [UIImage imageNamed:@"SupersetKeylinePresed.png"];
        [_supersetNameLabel setTextColor:RED_COLOR];
        [_supersetDescriptionLabel setTextColor:RED_COLOR];
    }else{
       // _separatorImageView.image = [UIImage imageNamed:@"SupersetKeyline.png"];
//        [_supersetNameLabel setTextColor:GRAY_MAIN_TEXT_COLOR];
        [_supersetNameLabel setTextColor:RGBA(65, 62, 62, 1)];
        [_supersetDescriptionLabel setTextColor:RGBA(151, 151, 151, 1)];
//        [_supersetDescriptionLabel setTextColor:GRAY_COLOR];
    }
}


-(void)setSupersetValues:(NSDictionary*)supersetInfoDictionary withInformation:(NSDictionary*)supersetInformationDictionary{
    NSString *title = [[supersetInfoDictionary[@"path"] lastPathComponent] substringFromIndex:2];
    _supersetNameLabel.text = title.localized;
//    _supersetDescriptionLabel.text = [NSString stringWithFormat:@"%@ MIN     %@ EXERCISES     %@ KCAL",supersetInformationDictionary[@"totalTime"],supersetInformationDictionary[@"exerciseNumber"],supersetInformationDictionary[@"calories"]];
    _supersetDescriptionLabel.text = [NSString stringWithFormat:@"%@ %@     %@ %@     %@ %@",supersetInformationDictionary[@"totalTime"], @"minKEY".localized, supersetInformationDictionary[@"exerciseNumber"], @"exercisesKEY".localized, supersetInformationDictionary[@"calories"], @"kcalKEY".localized];
}


@end
