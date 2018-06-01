#import "AdviceTableViewCell.h"

@interface AdviceTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *smallDescriptionLabel;

@property (weak, nonatomic) IBOutlet UIImageView *fullImageView;
@property (weak, nonatomic) IBOutlet UILabel *descritptionLabel;



@end


@implementation AdviceTableViewCell


-(void)awakeFromNib{
    [super awakeFromNib];
    
    [_titleLabel setBebasFontWithType:Bold size:isIpad? 27 : 20];
    [_descritptionLabel setBebasFontWithType:Regular size:isIpad? 17 : 14];
    [_smallDescriptionLabel setBebasFontWithType:Regular size:isIpad? 15 : 12];
    
    [_titleLabel setTextColor:RGBA(65, 62, 62, 1)];
    [_descritptionLabel setTextColor:RGBA(65, 62, 62, 1)];
//    [_descritptionLabel setTextColor:RGBA(147, 147, 147, 1)];
    [_smallDescriptionLabel setTextColor:RGBA(147, 147, 147, 1)];
//    if(isIpad){
//        _titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:22];
//        _descritptionLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
//        _smallDescriptionLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
//    }
}

-(void)setAdviceValues:(NSDictionary*)adviceValuesDictioanry isExpandable:(BOOL)expandableValue{
    _descritptionLabel.text = expandableValue ? adviceValuesDictioanry[@"description"] : @"";
    _titleLabel.text =  adviceValuesDictioanry[@"title"];
    _iconImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",adviceValuesDictioanry[@"imagePrefixName"]]];
    if(expandableValue){
        _fullImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_opened.jpg",adviceValuesDictioanry[@"imagePrefixName"]]];
    }
    _fullImageView.hidden = !expandableValue;
    _smallDescriptionLabel.hidden = YES;
}


- (IBAction)openBlogButtonAction:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_blogUrl]];
}


@end
